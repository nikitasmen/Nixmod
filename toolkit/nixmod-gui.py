#!/usr/bin/env python3
"""NixMod GUI: edit the modules' *.packages.json package lists and run toolkit/nixmod.sh actions."""
import codecs
import glob
import json
import os
import re
import shutil
import subprocess
import threading
import time

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Gdk", "4.0")
gi.require_version("Pango", "1.0")
from gi.repository import Gdk, Gio, GLib, Gtk, Pango  # noqa: E402

REPO = os.environ.get("NIXMOD_REPO") or os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
TOOLKIT = os.path.join(REPO, "toolkit", "nixmod.sh")
STATE_DIR = os.path.join(os.environ.get("XDG_STATE_HOME") or os.path.expanduser("~/.local/state"), "nixmod-gui")
STATE_FILE = os.path.join(STATE_DIR, "state.json")  # package lists as of the running generation + UI prefs
CACHE_DIR = os.path.join(os.environ.get("XDG_CACHE_HOME") or os.path.expanduser("~/.cache"), "nixmod-gui")
SUDO = "/run/wrappers/bin/sudo"  # setuid wrapper; NixOS ships no setuid pkexec by default
NIX = ["nix", "--extra-experimental-features", "nix-command flakes"]
ANSI = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")
MAX_RESULTS = 100


def toolkit(cmd):
    return ["bash", TOOLKIT, cmd]


# Every action keeps one name through its whole flow: button → running title → result.
ACTIONS = {
    "apply": dict(argv=toolkit("update"), root=True, running="Applying changes…",
                  done="Changes applied", fail="Applying changes failed"),
    "rebuild": dict(argv=toolkit("update"), root=True, running="Rebuilding system…",
                    done="System rebuilt", fail="Rebuild failed"),
    "try": dict(argv=toolkit("test"), root=True, running="Activating configuration…",
                done="Configuration active until the next reboot", fail="Activation failed"),
    "update": dict(argv=toolkit("flake-update"), root=False, running="Updating package versions…",
                   done="Package versions updated. Rebuild to install them.", fail="Updating versions failed",
                   followup=("Rebuild now", "rebuild")),
    "check": dict(argv=NIX + ["flake", "check", f"path:{REPO}"], root=False, running="Checking configuration…",
                  done="No errors found", fail="The configuration has errors"),
    "clean": dict(argv=toolkit("clean"), root=True, running="Freeing disk space…",
                  done="Disk space freed", fail="Cleanup failed",
                  confirm="Delete system generations older than 14 days? You won't be able to boot into them "
                          "afterwards."),
}

SYSTEM_ROWS = [  # (action, title, explanation, button label)
    ("rebuild", "Rebuild system", "Apply the configuration as it is on disk, e.g. after editing .nix files.",
     "Rebuild"),
    ("try", "Try configuration", "Activate it now without making it the boot default. Reboot to go back.", "Try"),
    ("update", "Update package versions", "Pull newer nixpkgs and inputs into flake.lock. Rebuild afterwards "
                                          "to install them.", "Update"),
    ("check", "Check configuration", "Evaluate the configuration for errors without changing anything.", "Check"),
    ("clean", "Free up disk space", "Delete generations older than 14 days and unused store paths.", "Clean up"),
]

# Catppuccin Macchiato
CSS = """
window, .view { background: #24273a; color: #cad3f5; }
headerbar { background: #1e2030; color: #cad3f5; box-shadow: none; border: none; min-height: 46px; }
stackswitcher button { padding: 4px 18px; }
stackswitcher button:checked { background: #363a4f; color: #c6a0f6; }
.page { padding: 20px 28px 12px 28px; }
list, row { background: transparent; color: #cad3f5; }
row { border-radius: 8px; padding: 10px 12px; }
row.pkg { padding: 7px 12px; min-height: 34px; }
row.pkg button { padding: 3px 12px; min-height: 0; }
row.pkg .on-hover { opacity: 0; }
row.pkg:hover .on-hover, row.pkg:focus-within .on-hover, row.pkg .on-hover:focus-visible { opacity: 1; }
.sidebar row { padding: 8px 12px; margin-bottom: 2px; }
.sidebar row:selected { background: #363a4f; }
.sidebar row:selected label { color: #c6a0f6; }
.sidebar row:selected label.count { color: #a5adcb; }
.sidebar row label.pending-dot, .pending-dot { color: #eed49f; font-size: 0.7em; }
.count { font-feature-settings: "tnum"; }
.small { font-size: 0.88em; }
.sidebar row.side-heading, .sidebar row.side-heading:hover { background: transparent; padding: 18px 12px 4px 12px; }
row:hover { background: #1e2030; }
row:focus-visible { outline: 2px solid #c6a0f6; outline-offset: -2px; }
entry { background: #363a4f; color: #cad3f5; border-radius: 10px; border: none; box-shadow: none; }
entry:focus-within { outline: 2px solid #c6a0f6; outline-offset: -2px; }
.search { min-height: 44px; font-size: 1.08em; padding: 0 12px; }
button { background: #363a4f; background-image: none; color: #cad3f5; border: none; border-radius: 8px;
         box-shadow: none; padding: 6px 16px; min-width: 64px; }
button:hover { background: #494d64; }
button:focus-visible { outline: 2px solid #c6a0f6; outline-offset: 1px; }
button:disabled { background: #1e2030; color: #6e738d; }
button.flat { background: transparent; color: #a5adcb; }
button.flat:hover { background: #363a4f; color: #cad3f5; }
button.destructive { color: #ed8796; }
button.add { color: #a6da95; }
.title { font-size: 1.25em; font-weight: 700; }
.name { font-weight: 600; }
.dim { color: #a5adcb; }
.faint { color: #6e738d; }
.gone { color: #6e738d; text-decoration-line: line-through; }
.chip { border-radius: 99px; padding: 2px 10px; font-size: 0.88em; font-weight: 600; }
.chip.install { background: alpha(#a6da95, 0.15); color: #a6da95; }
.chip.remove { background: alpha(#ed8796, 0.15); color: #ed8796; }
.empty-state { color: #a5adcb; padding: 48px 0; }  /* not ".empty": GTK gives level bars an "empty" block */
.mono { font-family: monospace; font-size: 0.92em; }
.refs { background: #1e2030; border-radius: 10px; padding: 10px 12px; }
.chip.dep { background: #363a4f; color: #cad3f5; font-weight: 400; }
.link { padding: 0; color: #8aadf4; }
.group { color: #c6a0f6; font-weight: 700; }
row.group-row, row.group-row:hover { background: transparent; padding-bottom: 2px; }
.stat-value { font-size: 1.2em; font-weight: 700; font-feature-settings: "tnum"; }
levelbar, levelbar trough { min-height: 6px; padding: 0; border: none; }
levelbar trough { background: #363a4f; border-radius: 99px; }
levelbar block { min-height: 6px; border: none; border-radius: 99px; background: #8aadf4; }
levelbar block.empty { background: transparent; }
levelbar block.warn { background: #eed49f; }
levelbar block.crit { background: #ed8796; }
.card { background: #1e2030; border-radius: 12px; padding: 16px 18px; }
.sep { background: #363a4f; min-height: 1px; }

/* The changes bar: the one loud element */
.changes { background: #c6a0f6; color: #181926; padding: 12px 28px; }
.changes > label { color: #181926; font-weight: 600; }
.changes button { background: alpha(#181926, 0.12); color: #181926; }
.changes button:hover { background: alpha(#181926, 0.22); }
.changes button.primary { background: #181926; color: #c6a0f6; font-weight: 700; }
.changes button.primary:hover { background: #24273a; }

.runpanel { background: #1e2030; padding: 12px 28px; }
.runpanel .ok { color: #a6da95; }
.status-mark { font-size: 1.3em; font-weight: 700; min-width: 18px; }
.runpanel .err { color: #ed8796; }
textview, textview text { background: #181926; color: #cad3f5; font-family: monospace; }
textview { padding: 10px; border-radius: 8px; }
.dialog-error { color: #ed8796; }
"""


# ---------- package lists: modules/**/<module>.packages.json (single source of truth) ----------
# Each module loads its file with `nixmod.readPackages` (configuration.nix); `nixmod.sh packages` edits the
# same files with jq. Both write jq's default format (2-space indent, raw UTF-8) so diffs stay clean.
def scan_lists():
    """→ (lists, packages). lists: [{id, path, rel, label}], packages: {name: {list, index, note}}."""
    lists, packages = [], {}
    pattern = os.path.join(REPO, "nixmod-system", "modules", "**", "*.packages.json")
    for path in sorted(glob.glob(pattern, recursive=True)):
        rel = os.path.relpath(path, REPO)
        stem = os.path.basename(path)[:-len(".packages.json")]
        lst = dict(id=rel, path=path, rel=rel, error=None, label=f"User {stem}" if "/users/" in rel
                   else stem.replace("-", " ").capitalize())
        lists.append(lst)
        try:
            entries = read_list(path).get("packages", [])
        except ListError as e:
            lst["error"], entries = str(e), []
        for i, entry in enumerate(entries):
            if isinstance(entry, dict) and "name" in entry:
                packages.setdefault(entry["name"], dict(list=rel, index=i, note=entry.get("note", "")))
    return lists, packages


class ListError(Exception):
    """A package list file can't be read; editing it would overwrite the user's packages."""


def read_list(path):
    try:
        with open(path) as f:
            data = json.load(f)
    except ValueError as e:
        raise ListError(f"{os.path.relpath(path, REPO)} isn't valid JSON ({e}). Fix it in an editor first.") from e
    if not isinstance(data, dict) or not isinstance(data.get("packages", []), list):
        raise ListError(f"{os.path.relpath(path, REPO)} should look like {{\"packages\": [...]}}.")
    return data


def edit_list(lst, change):
    data = read_list(lst["path"])  # raises instead of defaulting, so a typo can't wipe the list
    change(data.setdefault("packages", []))
    write_json(lst["path"], data)


def add_package(lst, name, note="", index=None):
    entry = {"name": name, **({"note": note} if note else {})}
    edit_list(lst, lambda ps: ps.insert(len(ps) if index is None else min(index, len(ps)), entry))


def remove_package(lst, name):
    def change(ps):
        ps[:] = [e for e in ps if e.get("name") != name]
    edit_list(lst, change)


def current_generation():
    return re.sub(r"\D", "", os.readlink("/nix/var/nix/profiles/system"))


def read_json(path, default):
    try:
        with open(path) as f:
            return json.load(f)
    except (FileNotFoundError, ValueError):
        return default


def write_json(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    os.replace(tmp, path)


def load_index():
    """{attr: (version, description)} for every package in the nixpkgs commit flake.lock pins, cached per commit.
    (Overlay-only packages aren't searchable; `nix search` can't walk the configured package set.)"""
    locks = json.loads(subprocess.run(NIX + ["flake", "metadata", f"path:{REPO}", "--json"],
                                      capture_output=True, text=True, check=True).stdout)["locks"]
    locked = locks["nodes"][locks["nodes"][locks["root"]]["inputs"]["nixpkgs"]]["locked"]
    if locked.get("type") == "github":
        ref = f"github:{locked['owner']}/{locked['repo']}/{locked['rev']}"
    else:
        ref = locked.get("url") or "nixpkgs"
    key = re.sub(r"[^A-Za-z0-9]", "", locked["narHash"])[:32]
    cache = os.path.join(CACHE_DIR, f"index-{key}.json")
    if not os.path.exists(cache):
        raw = subprocess.run(NIX + ["search", ref, "^", "--json"],
                             capture_output=True, text=True, check=True).stdout
        compact = {k.split(".", 2)[2]: [v.get("version", ""), v.get("description", "")]
                   for k, v in json.loads(raw).items()}
        for old in os.listdir(CACHE_DIR) if os.path.isdir(CACHE_DIR) else []:
            os.remove(os.path.join(CACHE_DIR, old))
        write_json(cache, compact)
    with open(cache) as f:
        return {k: tuple(v) for k, v in json.load(f).items()}


def search_table(index):
    """Lowercased (attr, name, description) rows, built once so each keystroke is a plain scan."""
    return [(a, a.lower(), d.lower()) for a, (_, d) in index.items()]


def search(table, query):
    q = query.lower().strip()
    names = [(a, al) for a, al, _ in table if q in al]
    names.sort(key=lambda x: (x[1] != q, not x[1].startswith(q), "." in x[0], len(x[0]), x[0]))
    names = [a for a, _ in names]
    if len(names) < MAX_RESULTS:  # top up with description matches
        seen = set(names)
        names += [a for a, al, dl in table if q in dl and a not in seen][:MAX_RESULTS - len(names)]
    return names[:MAX_RESULTS]


def system_facts():
    gen_link = os.readlink("/nix/var/nix/profiles/system")
    built = time.time() - os.lstat(os.path.join("/nix/var/nix/profiles", gen_link)).st_mtime
    disk = shutil.disk_usage("/")
    mem = {}
    with open("/proc/meminfo") as f:
        for line in f:
            k, v = line.split(":")
            mem[k] = int(v.split()[0]) * 1024
    with open("/run/current-system/nixos-version") as f:
        version = f.read().strip()
    return dict(version=version, generation=re.sub(r"\D", "", gen_link), built=humanize_age(built),
                disk=(disk.total - disk.free, disk.total),
                mem=(mem["MemTotal"] - mem["MemAvailable"], mem["MemTotal"]))


# ---------- package details ----------
# Evaluated from this config's own pkgs (same pinned nixpkgs, overlays, allowUnfree), not the registry.
DETAILS_EXPR = """p: let
  m = p.meta or {};
  str = x: if builtins.isAttrs x then (x.spdxId or x.fullName or x.name or x.github or "") else toString x;
  list = x: if builtins.isList x then x else [ x ];
  out = builtins.tryEval (p.outPath or "");
in {
  version = p.version or "";
  description = m.description or "";
  longDescription = m.longDescription or "";
  homepage = builtins.head (list (m.homepage or "") ++ [ "" ]);
  license = map str (list (m.license or [ ]));
  mainProgram = m.mainProgram or "";
  maintainers = map str (m.maintainers or [ ]);
  out = if out.success then out.value else "";
  buildInputs = map (d: d.name or "") (builtins.filter builtins.isAttrs
    ((p.buildInputs or [ ]) ++ (p.propagatedBuildInputs or [ ])));
}"""
# Store paths that reference everything and say nothing about who uses a package.
PLUMBING = re.compile(r"^(system-path|nixos-system|etc|user-environment|home-manager|hm_|man-paths|unit-|X-|"
                      r"profile|dbus-1|.*\.desktop$|.*-fhs|.*-env$|.*wrapped)")
_system_closure = None


def store_name(path):
    return os.path.basename(path)[33:]  # drop "<32-char hash>-"


def nix_store(*args):
    return subprocess.run(["nix-store", *args], capture_output=True, text=True).stdout.split()


def package_details(attr, target=None):
    """Everything the details dialog shows. Runs in a worker thread (nix eval takes a few seconds).
    `target` is the flake attribute to inspect (default: pkgs.<attr>); programs pass their own package,
    which is often a wrapped or overridden build (programs.steam), not plain pkgs.<attr>."""
    global _system_closure
    target = target or f"nixosConfigurations.nixos.pkgs.{attr}"
    proc = subprocess.run(NIX + ["eval", "--json", f"path:{REPO}#{target}", "--apply", DETAILS_EXPR],
                          capture_output=True, text=True)
    if proc.returncode:
        lines = [l for l in proc.stderr.splitlines() if l.strip().startswith("error")] or proc.stderr.splitlines()
        msg = (lines[-1] if lines else "nix eval failed").strip()
        if "does not provide attribute" in msg:
            msg = f"There's no package called '{attr}' in this configuration's nixpkgs."
        return dict(error=msg)
    d = json.loads(proc.stdout)
    out = d["out"]
    d["installed"] = bool(out) and os.path.exists(out)
    d["bins"], d["deps"], d["needed_by"], d["closure"] = [], [], [], 0
    if d["installed"]:
        bindir = os.path.join(out, "bin")
        d["bins"] = sorted(os.listdir(bindir)) if os.path.isdir(bindir) else []
        d["deps"] = sorted({store_name(p) for p in nix_store("-q", "--references", out) if p != out})
        size = subprocess.run(NIX + ["path-info", "-S", out], capture_output=True, text=True).stdout.split()
        d["closure"] = int(size[-1]) if size else 0
        if _system_closure is None:
            _system_closure = set(nix_store("-qR", "/run/current-system"))
        d["needed_by"] = sorted({store_name(p) for p in nix_store("-q", "--referrers", out)
                                 if p in _system_closure and p != out and not PLUMBING.match(store_name(p))})
    d["usage"] = find_usage(attr, d["mainProgram"], d["bins"])
    return d


def find_usage(attr, main_program, bins):
    """Lines in the repo that mention the package: its name in .nix files, its programs anywhere.
    (A name like `bottom` is also an everyday word, so dotfiles are only searched for program names.)"""
    def regex(words):
        words = sorted(w for w in words if len(w) > 1)
        return re.compile(r"(?<![\w.-])(" + "|".join(map(re.escape, words)) + r")(?![\w-])") if words else None
    programs = {main_program} | (set(bins) if len(bins) <= 5 else set())
    in_nix, in_dotfiles = regex(programs | {attr.split(".")[-1]}), regex(programs)
    hits = []
    for top in ("nixmod-system", "nixmod-dotfiles"):
        for dirpath, dirs, files in os.walk(os.path.join(REPO, top)):
            dirs[:] = [x for x in dirs if x not in ("wallpapers", ".git")]
            for name in sorted(files):
                pattern = in_nix if name.endswith(".nix") else in_dotfiles
                if not pattern or name.endswith((".packages.json", ".lock", ".md", ".png", ".jpg", ".svg", ".ttf")):
                    continue
                path = os.path.join(dirpath, name)
                try:
                    with open(path, errors="strict") as f:
                        for n, line in enumerate(f, 1):
                            if pattern.search(line):
                                hits.append((os.path.relpath(path, REPO), n, line.strip()[:140]))
                except (UnicodeDecodeError, OSError):
                    continue
    return hits[:40]


# ---------- programs turned on with an option (programs.<name>.enable) ----------
PROGRAMS_EXPR = r"""flakeRef: let
  sys = (builtins.getFlake flakeRef).nixosConfigurations.nixos;
  lib = sys.pkgs.lib;
  try = x: let r = builtins.tryEval x; in if r.success then r.value else null;
  pname = p: if p == null then null else try (p.pname or (lib.getName p));
  # NixOS: programs.<name>.enable set to true by a file in this repo (option defaults don't count)
  ours = d: lib.hasInfix "/nixmod-system/" (toString d.file);
  nixos = lib.concatMap (name: let
      o = sys.options.programs.${name};
      whole = lib.isOption o;  # some flake modules declare programs.<name> as one option holding { enable, ... }
      e = if whole then o else try (o.enable or null);
      on = d: try (if whole then (d.value.enable or false) else d.value) == true;
      pkg = if whole then try (o.value.package or null) else try (o.package.value or null);
    in
    if e == null || !(lib.isOption e) || try (if whole then (e.value.enable or false) else e.value) != true then [ ]
    else map (d: { inherit name; scope = "system"; file = toString d.file; package = pname pkg; })
      (builtins.filter (d: ours d && on d) (try e.definitionsWithLocations or [ ])))
    (builtins.attrNames sys.options.programs);
  # Home Manager: enabled in the user's config; the GUI drops ones no file mentions (HM's own defaults)
  users = sys.config.home-manager.users;
  hm = lib.concatMap (user: lib.concatMap (name: let p = try users.${user}.programs.${name}; in
    if !(builtins.isAttrs p) || try (p.enable or false) != true then [ ]
    else [ { inherit name; scope = "home:${user}"; file = ""; package = pname (try (p.package or null)); } ])
    (builtins.attrNames users.${user}.programs)) (builtins.attrNames users);
in nixos ++ hm"""


def enabled_programs():
    """[{name, scope, rel, line, code, package}] for programs turned on with an option in this repo."""
    proc = subprocess.run(NIX + ["eval", "--impure", "--json", "--expr", f"({PROGRAMS_EXPR}) \"path:{REPO}\""],
                          capture_output=True, text=True, check=True)
    found = []
    for e in json.loads(proc.stdout):
        if e["scope"] == "system":
            candidates = [os.path.join(REPO, "nixmod-system", e["file"].split("/nixmod-system/", 1)[1])]
        else:  # Home Manager config files
            user = e["scope"].split(":", 1)[1]
            candidates = sorted(glob.glob(os.path.join(REPO, "nixmod-system", "**", f"{user}-home*.nix"),
                                          recursive=True))
        line = find_program_line(candidates, e["name"])
        if line:
            found.append(dict(name=e["name"], scope=e["scope"], package=e["package"], **line))
    return sorted(found, key=lambda e: (e["scope"], e["name"]))


def find_program_line(paths, name):
    pattern = re.compile(rf"^\s*programs\.{re.escape(name)}(\.enable)?\s*=")
    for path in paths:
        try:
            with open(path) as f:
                for n, line in enumerate(f, 1):
                    if pattern.match(line):
                        return dict(rel=os.path.relpath(path, REPO), line=n, code=line.strip())
        except OSError:
            continue
    return None


# ---------- flake inputs (read-only; updated one at a time) ----------
def flake_inputs():
    """Root inputs of the repo's flake with what flake.lock pins them to."""
    proc = subprocess.run(NIX + ["flake", "metadata", f"path:{REPO}", "--json"],
                          capture_output=True, text=True, check=True)
    locks = json.loads(proc.stdout)["locks"]
    nodes = locks["nodes"]
    found = []
    for name, ref in sorted(nodes[locks["root"]]["inputs"].items()):
        if not isinstance(ref, str):  # `follows` another input: nothing of its own to update
            continue
        node = nodes[ref]
        orig, locked = node.get("original", {}), node.get("locked", {})
        if orig.get("type") == "github":
            source = f"github:{orig['owner']}/{orig['repo']}" + (f"/{orig['ref']}" if orig.get("ref") else "")
            url = f"https://github.com/{orig['owner']}/{orig['repo']}"
        else:
            source = url = orig.get("url", orig.get("type", ""))
        found.append(dict(name=name, source=source, url=url, rev=(locked.get("rev") or "")[:7],
                          modified=locked.get("lastModified"), is_flake=node.get("flake", True)))
    # Inputs named "<input>-…" (passman-tags) only describe <input>, so they update together with it.
    names = {f["name"] for f in found}
    for f in found:
        f["companions"] = sorted(n for n in names if n.startswith(f["name"] + "-"))
        f["companion_of"] = next((n for n in names if f["name"].startswith(n + "-")), None)
    return found


def fmt_size(n):
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024 or unit == "GB":
            return f"{n:.0f} {unit}" if unit in ("B", "KB") else f"{n:.1f} {unit}"
        n /= 1024


def humanize_age(seconds):
    for unit, size in (("day", 86400), ("hour", 3600), ("minute", 60)):
        if seconds >= size:
            n = int(seconds // size)
            return f"{n} {unit}{'s' if n != 1 else ''} ago"
    return "just now"


def label(text="", *classes, wrap=False, xalign=0.0, ellipsize=False):
    lbl = Gtk.Label(label=text, xalign=xalign, wrap=wrap, css_classes=list(classes))
    if ellipsize:
        lbl.set_ellipsize(Pango.EllipsizeMode.END)
    return lbl


# ---------- package rows ----------
class PkgRow(Gtk.ListBoxRow):
    """One line: name, version, note/description; Remove shows on hover, pending states always show."""
    def __init__(self, win, attr):
        super().__init__(activatable=True, tooltip_text="Show details", css_classes=["pkg"])
        self.win, self.attr = win, attr
        box = Gtk.Box(spacing=10)
        self.name = label(attr, "name")
        version, desc = win.index.get(attr, ("", "")) if win.index else ("", "")
        info = win.desired.get(attr) or win.applied.get(attr)
        desc = (info or {}).get("note") or desc
        box.append(self.name)
        if version:
            v = label(version, "faint", ellipsize=True)
            v.set_max_width_chars(14)
            box.append(v)
        note = label(desc, "dim", ellipsize=True)
        note.set_hexpand(True)
        box.append(note)
        self.chip = label("", "chip")
        self.chip.set_valign(Gtk.Align.CENTER)
        self.button = Gtk.Button(valign=Gtk.Align.CENTER)
        self.button.connect("clicked", lambda *_: win.toggle(attr))
        box.append(self.chip)
        box.append(self.button)
        self.set_child(box)
        self.update()

    def update(self):
        state = self.win.state_of(self.attr)
        style_state(state, self.attr, self.chip, self.button, self.name)
        if state[2] == "Remove":  # the everyday state: keep the list calm, reveal on hover/focus
            self.button.set_css_classes(["destructive", "on-hover"])


class ProgramRow(Gtk.ListBoxRow):
    """A program turned on with an option: read-only, shows where it's turned on."""
    def __init__(self, win, prog):
        super().__init__(activatable=True, tooltip_text="Show details", css_classes=["pkg"])
        self.prog = prog
        box = Gtk.Box(spacing=10)
        box.append(label(prog["name"], "name"))
        pkg = prog["package"] or prog["name"]
        version, desc = win.index.get(pkg, ("", "")) if win.index else ("", "")
        if version:
            v = label(version, "faint", ellipsize=True)
            v.set_max_width_chars(14)
            box.append(v)
        note = label(desc, "dim", ellipsize=True)
        note.set_hexpand(True)
        box.append(note)
        where = label(f"{os.path.basename(prog['rel'])}:{prog['line']}", "faint", "mono")
        where.set_tooltip_text(f"{prog['code']}\nin {prog['rel']}")
        box.append(where)
        self.set_child(box)


class FlakeRow(Gtk.ListBoxRow):
    """A flake input: where it comes from, what flake.lock pins, and an Update button."""
    def __init__(self, win, flake):
        super().__init__(activatable=False, css_classes=["pkg"])
        box = Gtk.Box(spacing=10)
        box.append(label(flake["name"], "name"))
        src = label(flake["source"], "dim", ellipsize=True)
        src.set_hexpand(True)
        src.set_tooltip_text(flake["url"])
        box.append(src)
        if flake["modified"]:
            box.append(label(f"locked {humanize_age(time.time() - flake['modified'])}", "faint"))
        if flake["rev"]:
            box.append(label(flake["rev"], "faint", "mono"))
        if flake["companion_of"]:
            box.append(label(f"updates with {flake['companion_of']}", "faint"))
        else:
            btn = Gtk.Button(label="Update", valign=Gtk.Align.CENTER, css_classes=["flat"])
            btn.set_tooltip_text(f"Update {flake['name']} to its latest commit in flake.lock")
            btn.connect("clicked", lambda *_: win.update_input(flake))
            win.flake_buttons.append(btn)
            box.append(btn)
        self.set_child(box)


def program_box(program):
    """Where an option-enabled program is turned on: the option, file:line and the line itself."""
    box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
    box.append(label(f"Turned on with programs.{program['name']}", "name"))
    box.append(label(f"{program['rel']}:{program['line']}", "faint"))
    box.append(label(program["code"], "mono", "dim"))
    return box


def style_state(state, attr, chip, button, name=None):
    text, chip_cls, btn, btn_cls, gone = state
    chip.set_text(text)
    chip.set_visible(bool(text))
    chip.set_css_classes(["chip", chip_cls] if chip_cls else ["chip"])
    button.set_label(btn)
    button.set_css_classes([btn_cls])
    button.set_tooltip_text(f"{btn} {attr}")
    if name is not None:
        name.set_css_classes([*name.get_css_classes()[:1], "gone"] if gone else name.get_css_classes()[:1])


# ---------- window ----------
class Window(Gtk.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app, title="NixMod", default_width=1040, default_height=780)
        self.rescan()
        # `applied` = the package lists the running system was built from. A rebuild from anywhere (this app
        # or `nixmod.sh` in a terminal) changes the generation, and then the files on disk are what's live.
        self.state = read_json(STATE_FILE, {})
        if self.state.get("generation") != current_generation():
            self.state.update(generation=current_generation(), packages=self.desired)
            write_json(STATE_FILE, self.state)
        self.applied = self.state["packages"]
        self.index = None
        self.index_error = None
        self.programs = None  # None = still loading; [] = none found
        self.flakes, self.flakes_error = None, None
        self.flake_buttons = []
        self.programs_error = None
        self.followup_action = None
        self.result_rows = []
        self.running = False

        changes_bar, run_panel = self.build_changes_bar(), self.build_run_panel()  # pages' signals refer to these
        self.stack = Gtk.Stack(transition_type=Gtk.StackTransitionType.CROSSFADE, vexpand=True)
        self.stack.add_titled(self.build_packages(), "packages", "Packages")
        self.stack.add_titled(self.build_system(), "system", "System")
        self.stack.connect("notify::visible-child-name", lambda *_: self.refresh_facts())
        header = Gtk.HeaderBar(decoration_layout=":close")  # only the close button, whatever the desktop default
        header.set_title_widget(Gtk.StackSwitcher(stack=self.stack))
        self.set_titlebar(header)

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        root.append(self.stack)
        root.append(changes_bar)
        root.append(run_panel)
        self.set_child(root)

        keys = Gtk.ShortcutController()
        keys.add_shortcut(Gtk.Shortcut(trigger=Gtk.ShortcutTrigger.parse_string("<Control>f"),
                                       action=Gtk.CallbackAction.new(self.focus_search)))
        self.add_controller(keys)

        self.refresh_packages()
        self.refresh_facts()
        self.in_background(load_index, "index")
        self.in_background(enabled_programs, "programs")
        self.refresh_flakes()
        self.search.grab_focus()

    # ----- packages page -----
    def build_packages(self):
        page = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16, css_classes=["page"])
        self.search = Gtk.SearchEntry(placeholder_text="Search packages", css_classes=["search"])
        self.search.connect("search-changed", lambda *_: self.refresh_packages())
        self.search.connect("stop-search", lambda e: e.set_text(""))
        page.append(self.search)

        split = Gtk.Box(spacing=24, vexpand=True)
        page.append(split)

        # Sidebar: one entry per package list, plus "All packages"
        side = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10, width_request=210, hexpand=False)
        self.sidebar = Gtk.ListBox(selection_mode=Gtk.SelectionMode.SINGLE, css_classes=["sidebar"])
        self.sidebar.connect("row-selected", self.sidebar_selected)
        self.selected_list = None
        side.append(Gtk.ScrolledWindow(child=self.sidebar, vexpand=True, hscrollbar_policy=Gtk.PolicyType.NEVER))
        split.append(side)

        main = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6, hexpand=True)
        title_row = Gtk.Box(spacing=10)
        self.list_title = label("", "title")
        self.list_path = label("", "faint", ellipsize=True)
        self.list_path.set_hexpand(True)
        self.list_path.set_valign(Gtk.Align.BASELINE)
        self.list_title.set_valign(Gtk.Align.BASELINE)
        self.target = Gtk.DropDown.new_from_strings([l["label"] for l in self.lists])
        ids = [l["id"] for l in self.lists]
        default = next((i for i, l in enumerate(self.lists) if l["rel"].endswith("applications.packages.json")), 0)
        self.target.set_selected(ids.index(self.state["target"]) if self.state.get("target") in ids else default)
        self.target.connect("notify::selected", self.target_changed)
        self.target_box = Gtk.Box(spacing=8, valign=Gtk.Align.CENTER)
        self.target_box.append(label("Add to", "dim"))
        self.target_box.append(self.target)
        for w in (self.list_title, self.list_path, self.target_box):
            title_row.append(w)
        self.list_note = label("", "dim", wrap=True)
        main.append(title_row)
        main.append(self.list_note)

        self.pkg_list = Gtk.ListBox(selection_mode=Gtk.SelectionMode.NONE, margin_top=6)
        self.pkg_list.connect("row-activated", self.row_activated)
        self.pkg_empty = label("", "empty-state", wrap=True, xalign=0.5)
        self.pkg_list.set_placeholder(self.pkg_empty)
        main.append(Gtk.ScrolledWindow(child=self.pkg_list, vexpand=True, hscrollbar_policy=Gtk.PolicyType.NEVER))
        split.append(main)
        return page

    def row_activated(self, _list, row):
        if isinstance(row, PkgRow):
            self.show_details(row.attr)
        elif isinstance(row, ProgramRow):
            self.show_details(row.prog["package"] or row.prog["name"], program=row.prog)

    def refresh_sidebar(self):
        self.sidebar_ready = False
        self.sidebar.remove_all()
        pending = {p["list"] for a, p in self.desired.items() if a not in self.applied}
        pending |= {p["list"] for a, p in self.applied.items() if a not in self.desired}
        entries = [(None, "All packages", len(self.desired), bool(pending))]
        entries += [(l["id"], l["label"], len([a for a in self.desired if self.desired[a]["list"] == l["id"]]),
                     l["id"] in pending) for l in self.lists]
        entries.append(("heading", "Turned on with options", None, False))
        for cat_id, text in self.program_categories():
            scope = cat_id.split(":", 1)[1]
            count = None if self.programs is None else sum(p["scope"] == scope for p in self.programs)
            entries.append((cat_id, text, count, False))
        entries.append(("heading", "Flakes", None, False))
        entries.append(("flakes", "Flake inputs", None if self.flakes is None else len(self.flakes), False))
        for list_id, text, count, changed in entries:
            if list_id == "heading":
                head = Gtk.ListBoxRow(child=label(text, "faint", "small"), activatable=False, selectable=False,
                                      css_classes=["side-heading"])
                self.sidebar.append(head)
                continue
            box = Gtk.Box(spacing=8)
            name = label(text)
            name.set_hexpand(True)
            box.append(name)
            dot = label("●", "pending-dot") if changed else None
            if dot:
                dot.set_tooltip_text("Has changes that aren't applied yet")
                box.append(dot)
            box.append(label("…" if count is None else str(count), "faint", "count"))
            row = Gtk.ListBoxRow(child=box)
            row.list_id = list_id
            self.sidebar.append(row)
            if list_id == self.selected_list:
                self.sidebar.select_row(row)
        self.sidebar_ready = True

    def sidebar_selected(self, _box, row):
        if row is None or not getattr(self, "sidebar_ready", False):
            return
        self.selected_list = row.list_id
        if self.search.get_text():
            self.search.set_text("")  # search-changed refreshes
        else:
            self.refresh_packages()

    def target_changed(self, *_):
        self.state["target"] = self.target_list()["id"]
        write_json(STATE_FILE, self.state)

    def focus_search(self, *_):
        self.stack.set_visible_child_name("packages")
        self.search.grab_focus()
        return True

    def in_background(self, fn, attr):
        """Run fn in a thread; store its result in self.<attr> (or the last stderr line in self.<attr>_error)."""
        def work():
            try:
                result, error = fn(), None
            except (subprocess.CalledProcessError, OSError, ValueError, KeyError) as e:
                lines = (getattr(e, "stderr", None) or str(e)).strip().splitlines()
                result, error = None, (lines[-1] if lines else f"loading {attr} failed")
            GLib.idle_add(self.loaded, attr, result, error)
        threading.Thread(target=work, daemon=True).start()

    def loaded(self, attr, result, error):
        setattr(self, attr, result if error is None else [])
        setattr(self, f"{attr}_error", error)
        if attr == "index":
            self.search_rows = search_table(result) if result else []
            if result:
                self.search.set_placeholder_text(f"Search {len(result):,} packages")
        if attr == "index" or not self.search.get_text().strip():
            self.refresh_packages()

    def refresh_flakes(self):
        self.in_background(flake_inputs, "flakes")

    def update_input(self, flake):
        names = [flake["name"], *flake["companions"]]
        self.start(dict(
            argv=["bash", "-c", 'cd "$1" && shift && nix --extra-experimental-features "nix-command flakes" '
                                'flake update "$@"', "_", REPO, *names],
            root=False, running=f"Updating {flake['name']}…",
            done=f"{flake['name']} updated. Rebuild to use it.", fail=f"Updating {flake['name']} failed",
            followup=("Rebuild now", "rebuild"), after=self.refresh_flakes))

    def program_categories(self):
        """Sidebar entries for option-enabled programs: one per scope (system, each user's Home Manager)."""
        scopes = sorted({p["scope"] for p in self.programs or []}, key=lambda s: (s != "system", s))
        return [(f"programs:{s}", "System programs" if s == "system" else f"Home Manager ({s.split(':', 1)[1]})")
                for s in scopes]

    def refresh_packages(self):
        query = self.search.get_text().strip()
        self.pkg_list.remove_all()
        self.result_rows = []
        self.target_box.set_visible(bool(query))
        self.refresh_sidebar()
        self.list_path.set_text("")
        if not query and self.selected_list == "flakes":
            self.list_title.set_text("Flake inputs")
            self.list_note.set_text("The flakes your system is built from and the commit flake.lock pins each one to. "
                                    "Update moves one input to its latest commit; rebuild afterwards to use it. "
                                    "Inputs are added or removed in flake.nix.")
            self.list_note.set_visible(True)
            self.pkg_empty.set_text("Reading flake.lock…" if self.flakes is None else
                                    f"Couldn't read flake.lock: {self.flakes_error}" if self.flakes_error else
                                    "This flake has no inputs.")
            self.flake_buttons = []
            for flake in self.flakes or []:
                self.pkg_list.append(FlakeRow(self, flake))
            for b in self.flake_buttons:
                b.set_sensitive(not self.running)
            return self.refresh_changes_bar()
        if not query and str(self.selected_list).startswith("programs:"):
            scope = self.selected_list.split(":", 1)[1]
            self.list_title.set_text(dict(self.program_categories()).get(self.selected_list, "Programs"))
            self.list_note.set_text("Turned on with an option in a .nix module, so they're not in a package list. "
                                    "Edit the file shown on the right to turn one off.")
            self.list_note.set_visible(True)
            if self.programs is None:
                self.pkg_empty.set_text("Reading your configuration…")
            elif self.programs_error:
                self.pkg_empty.set_text(f"Couldn't read the configuration: {self.programs_error}")
            else:
                self.pkg_empty.set_text("No programs are turned on with an option here.")
            for prog in [p for p in self.programs or [] if p["scope"] == scope]:
                self.pkg_list.append(ProgramRow(self, prog))
            return self.refresh_changes_bar()
        if not query:
            self.list_note.set_visible(False)
            shown = [l for l in self.lists if self.selected_list in (None, l["id"])]
            single = self.selected_list is not None and shown
            self.list_title.set_text(shown[0]["label"] if single else "All packages")
            self.list_path.set_text(shown[0]["rel"] if single else "")
            self.pkg_empty.set_text(shown[0]["error"] if single and shown[0]["error"] else
                                    "This list is empty. Search above to add a package to it." if single
                                    else "No package lists found in nixmod-system/modules.")
            for lst in shown:
                # what's in the file, then entries removed since the last rebuild
                attrs = [a for a, p in self.desired.items() if p["list"] == lst["id"]]
                attrs += [a for a, p in self.applied.items() if p["list"] == lst["id"] and a not in self.desired]
                if not attrs:
                    continue
                if not single:
                    head = Gtk.Box(spacing=10, margin_top=14)
                    head.append(label(lst["label"], "group"))
                    head.append(label(str(len(attrs)), "faint"))
                    self.pkg_list.append(Gtk.ListBoxRow(child=head, activatable=False, selectable=False,
                                                        css_classes=["group-row"]))
                for attr in attrs:
                    row = PkgRow(self, attr)
                    self.result_rows.append(row)
                    self.pkg_list.append(row)
            return self.refresh_changes_bar()
        elif not self.index:
            attrs = []
            self.list_title.set_text("Results")
            self.list_note.set_text("")
            self.pkg_empty.set_text(
                f"Couldn't load the package list: {self.index_error}" if self.index_error
                else "Loading the package list. The first time takes about 30 seconds.")
        else:
            attrs = search(self.search_rows, query)
            self.list_title.set_text("Results")
            self.list_note.set_text(f"First {MAX_RESULTS} matches. Keep typing to narrow it down."
                                    if len(attrs) == MAX_RESULTS else "")
            self.pkg_empty.set_text(f"No packages match “{query}”.")
        self.list_note.set_visible(bool(self.list_note.get_text()))
        for attr in attrs:
            row = PkgRow(self, attr)
            self.result_rows.append(row)
            self.pkg_list.append(row)
        self.refresh_changes_bar()

    def state_of(self, attr):
        """(chip text, chip class, button label, button class, struck-through) for a package."""
        return {
            (True, True): ("", None, "Remove", "destructive", False),
            (True, False): ("Will be installed", "install", "Undo", "flat", False),
            (False, True): ("Will be removed", "remove", "Undo", "flat", True),
            (False, False): ("", None, "Add", "add", False),
        }[(attr in self.desired, attr in self.applied)]

    # ----- package details dialog -----
    def show_details(self, attr, program=None):
        win = Gtk.Window(transient_for=self, modal=True, title=attr, default_width=780, default_height=660)
        win.set_titlebar(Gtk.HeaderBar(decoration_layout=":close"))
        keys = Gtk.ShortcutController()
        keys.add_shortcut(Gtk.Shortcut(trigger=Gtk.ShortcutTrigger.parse_string("Escape"),
                                       action=Gtk.CallbackAction.new(lambda *_: win.close() or True)))
        win.add_controller(keys)

        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, css_classes=["page"])
        head = Gtk.Box(spacing=14)
        titles = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4, hexpand=True)
        name_row = Gtk.Box(spacing=10)
        name = label(attr, "title")
        version = label("", "faint")
        name_row.append(name)
        name_row.append(version)
        desc = label("", "dim", wrap=True)
        titles.append(name_row)
        titles.append(desc)
        chip = label("", "chip", )
        chip.set_valign(Gtk.Align.CENTER)
        button = Gtk.Button(valign=Gtk.Align.CENTER)

        def toggled(*_):
            self.toggle(attr)
            style_state(self.state_of(attr), attr, chip, button, name)
        button.connect("clicked", toggled)
        style_state(self.state_of(attr), attr, chip, button, name)
        button.set_visible(program is None)
        chip.set_visible(program is None and bool(chip.get_text()))
        for w in (titles, chip, button):
            head.append(w)
        outer.append(head)
        outer.append(Gtk.Box(css_classes=["sep"], margin_top=16))

        body = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20, margin_top=18, margin_bottom=12)
        loading = Gtk.Box(spacing=10, halign=Gtk.Align.CENTER, margin_top=60)
        spinner = Gtk.Spinner(spinning=True)
        loading.append(spinner)
        loading.append(label("Looking up the package…", "dim"))
        body.append(loading)
        outer.append(Gtk.ScrolledWindow(child=body, vexpand=True, hscrollbar_policy=Gtk.PolicyType.NEVER))
        win.set_child(outer)
        win.present()

        info = self.desired.get(attr) or self.applied.get(attr)
        lst = self.list_by_id.get(info["list"]) if info else None

        def work():
            target = None
            if program and program["package"]:
                target = ("nixosConfigurations.nixos.config.programs." if program["scope"] == "system" else
                          f"nixosConfigurations.nixos.config.home-manager.users.{program['scope'].split(':', 1)[1]}"
                          ".programs.") + f"{program['name']}.package"
            d = package_details(attr, target)
            GLib.idle_add(fill, d)

        def fill(d):
            body.remove(loading)
            if "error" in d and program:  # e.g. programs.spicetify: configured by a module, no single package
                box = program_box(program)
                box.append(label("A module sets this program up, so there's no single package to show details "
                                 "for. Its settings are in the file above.", "dim", wrap=True))
                body.append(box)
                return
            if "error" in d:
                body.append(label(d["error"], "dialog-error", wrap=True))
                return
            version.set_text(d["version"])
            desc.set_text(d["description"])
            self.fill_details(body, attr, d, info, lst, program)

        threading.Thread(target=work, daemon=True).start()

    def fill_details(self, body, attr, d, info, lst, program=None):
        def section(title, *widgets, hint=""):
            box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
            head = Gtk.Box(spacing=10)
            head.append(label(title, "group"))
            if hint:
                head.append(label(hint, "faint"))
            box.append(head)
            for w in widgets:
                box.append(w)
            body.append(box)

        def chips(names, limit=60):
            flow = Gtk.FlowBox(selection_mode=Gtk.SelectionMode.NONE, column_spacing=6, row_spacing=6,
                               max_children_per_line=30)
            for n in names[:limit]:
                flow.append(label(n, "chip", "dep"))
            if len(names) > limit:
                flow.append(label(f"{len(names) - limit} more", "faint"))
            return flow

        # About
        grid = Gtk.Grid(column_spacing=18, row_spacing=6)
        facts = [("License", ", ".join(d["license"])),
                 ("Main program", d["mainProgram"]), ("Maintainers", ", ".join(d["maintainers"][:6])),
                 ("Store path", d["out"] if d["installed"] else "Not on this machine yet")]
        row = 0
        for key, value in facts:
            if value:
                grid.attach(label(key, "dim"), 0, row, 1, 1)
                v = label(value, wrap=True)
                v.set_selectable(True)
                grid.attach(v, 1, row, 1, 1)
                row += 1
        if d["homepage"]:
            grid.attach(label("Homepage", "dim"), 0, row, 1, 1)
            link = Gtk.LinkButton(uri=d["homepage"], label=d["homepage"], halign=Gtk.Align.START,
                                  css_classes=["link"])
            grid.attach(link, 1, row, 1, 1)
        about = [grid]
        if d["longDescription"]:
            about.append(label(" ".join(d["longDescription"].split()), "dim", wrap=True))
        section("About", *about)

        # Where and how it's used
        used = []
        if program:
            used.append(program_box(program))
        if lst:
            where = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
            where.append(label(f"In the {lst['label']} list", "name"))
            where.append(label(lst["rel"], "faint"))
            if info.get("note"):
                where.append(label(f"Your note: {info['note']}", "dim", wrap=True))
            used.append(where)
        elif not program:
            used.append(label("Not in any of your package lists.", "dim"))
        if d["usage"]:
            refs = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4, css_classes=["refs"])
            for path, n, line in d["usage"]:
                r = Gtk.Box(spacing=10)
                r.append(label(f"{path}:{n}", "faint", "mono"))
                code = label(line, "mono", ellipsize=True)
                code.set_hexpand(True)
                r.append(code)
                refs.append(r)
            used.append(label("Referenced in your configuration", "dim"))
            used.append(refs)
        elif lst:
            used.append(label("Nothing else in your configuration refers to it by name.", "dim"))
        section("In your configuration", *used)

        if d["bins"]:
            section("Programs it provides", chips(d["bins"], 40), hint=f"{len(d['bins'])}")

        if d["installed"]:
            section("Depends on", chips(d["deps"]) if d["deps"] else label("No runtime dependencies.", "dim"),
                    hint=f"{len(d['deps'])} packages, {fmt_size(d['closure'])} in total")
            section("Needed by", chips(d["needed_by"]) if d["needed_by"]
                    else label("Nothing else in your system depends on it.", "dim"))
        else:
            section("Build inputs", chips(d["buildInputs"]) if d["buildInputs"] else label("None.", "dim"),
                    hint="Runtime dependencies are known once it's installed")

    def show_error(self, text):
        dialog = Gtk.AlertDialog(message=text, buttons=["OK"])
        dialog.show(self)

    def rescan(self):
        self.lists, self.desired = scan_lists()
        self.list_by_id = {l["id"]: l for l in self.lists}

    def target_list(self):
        return self.lists[self.target.get_selected()]

    def restore(self, attr):
        """Undo a removal: put the entry back where it was, note included."""
        info = self.applied[attr]
        add_package(self.list_by_id.get(info["list"], self.target_list()), attr, info["note"], info["index"])

    def toggle(self, attr):
        try:
            if attr in self.desired:
                remove_package(self.list_by_id[self.desired[attr]["list"]], attr)
            elif attr in self.applied:
                self.restore(attr)
            else:
                add_package(self.target_list(), attr)
        except (OSError, ListError) as e:
            self.show_error(f"Couldn't change the package list. {e}")
            return
        self.rescan()
        if self.search.get_text().strip():
            for row in self.result_rows:
                if row.attr == attr:
                    row.update()
            self.refresh_sidebar()
            self.refresh_changes_bar()
        else:
            self.refresh_packages()

    # ----- changes bar -----
    def build_changes_bar(self):
        bar = Gtk.Box(spacing=10, css_classes=["changes"])
        self.changes_text = label()
        self.changes_text.set_hexpand(True)
        discard = Gtk.Button(label="Discard")
        discard.connect("clicked", self.discard_changes)
        apply = Gtk.Button(label="Apply changes", css_classes=["primary"])
        apply.connect("clicked", lambda *_: self.start("apply"))
        for w in (self.changes_text, discard, apply):
            bar.append(w)
        self.changes_bar = Gtk.Revealer(child=bar, transition_type=Gtk.RevealerTransitionType.SLIDE_UP)
        return self.changes_bar

    def refresh_changes_bar(self):
        add, remove = len(self.desired.keys() - self.applied.keys()), len(self.applied.keys() - self.desired.keys())
        parts = [f"{n} package{'s' if n != 1 else ''} to {verb}" for n, verb in ((add, "install"), (remove, "remove"))
                 if n]
        self.changes_text.set_text(", ".join(parts))
        self.changes_bar.set_reveal_child(bool(parts) and not self.run_panel.get_reveal_child())

    def discard_changes(self, *_):
        for attr in self.desired.keys() - self.applied.keys():
            remove_package(self.list_by_id[self.desired[attr]["list"]], attr)
        for attr in sorted(self.applied.keys() - self.desired.keys(), key=lambda a: self.applied[a]["index"]):
            self.restore(attr)
        self.rescan()
        self.refresh_packages()

    # ----- system page -----
    def build_system(self):
        page = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=18, css_classes=["page"])
        facts = Gtk.Box(spacing=12, homogeneous=True)
        self.fact = {}
        for key, title in (("version", "NixOS"), ("generation", "Generation"), ("disk", "Disk"), ("mem", "Memory")):
            card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4, css_classes=["card"])
            value, sub = label("", "stat-value", ellipsize=True), label("", "dim", ellipsize=True)
            card.append(label(title, "dim"))
            card.append(value)
            if key in ("disk", "mem"):
                bar = Gtk.LevelBar(min_value=0, max_value=1, margin_top=6, margin_bottom=2,
                                   valign=Gtk.Align.CENTER)
                for name in ("low", "high", "full"):  # GTK's defaults colour 91% as "full"
                    bar.remove_offset_value(name)
                bar.add_offset_value("ok", 0.8)
                bar.add_offset_value("warn", 0.92)
                bar.add_offset_value("crit", 1.0)
                card.append(bar)
            else:
                bar = None
            card.append(sub)
            self.fact[key] = (value, sub, bar)
            facts.append(card)
        page.append(facts)

        rows = Gtk.ListBox(selection_mode=Gtk.SelectionMode.NONE)
        self.action_buttons = []
        for action, title, desc, btn_label in SYSTEM_ROWS:
            box = Gtk.Box(spacing=14)
            text = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2, hexpand=True)
            text.append(label(title, "name"))
            text.append(label(desc, "dim", wrap=True))
            btn = Gtk.Button(label=btn_label, valign=Gtk.Align.CENTER,
                             css_classes=["destructive"] if action == "clean" else [])
            btn.connect("clicked", lambda _b, a=action: self.start(a))
            self.action_buttons.append(btn)
            box.append(text)
            box.append(btn)
            rows.append(Gtk.ListBoxRow(child=box, activatable=False))
        page.append(rows)
        return Gtk.ScrolledWindow(child=page, hscrollbar_policy=Gtk.PolicyType.NEVER)

    def refresh_facts(self):
        try:
            f = system_facts()
        except (OSError, KeyError, ValueError):
            return
        m = re.match(r"(\d+\.\d+)\.(\d{8})\.(\w+)\s*\(?([^)]*)", f["version"])
        if m:
            release, date, rev, codename = m.groups()
            self.fact["version"][0].set_text(f"{release} {codename}".strip())
            self.fact["version"][1].set_text(
                f"nixpkgs from {time.strftime('%-d %b %Y', time.strptime(date, '%Y%m%d'))}")
        else:
            self.fact["version"][0].set_text(f["version"])
        self.fact["generation"][0].set_text(f"#{f['generation']}")
        self.fact["generation"][1].set_text(f"Built {f['built']}")
        for key in ("disk", "mem"):
            used, total = f[key]
            value, sub, bar = self.fact[key]
            value.set_text(f"{fmt_size(total - used)} free")
            sub.set_text(f"{fmt_size(used)} of {fmt_size(total)} used")
            bar.set_value(used / total)

    # ----- running actions -----
    def build_run_panel(self):
        panel = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10, css_classes=["runpanel"])
        top = Gtk.Box(spacing=12)
        self.run_spinner = Gtk.Spinner()
        self.run_icon = label("", "status-mark")  # a glyph, not a themed icon: works with any icon theme
        text = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, hexpand=True)
        self.run_title = label("", "name")
        self.run_last = label("", "faint", ellipsize=True)
        text.append(self.run_title)
        text.append(self.run_last)
        self.details = Gtk.ToggleButton(label="Details", css_classes=["flat"], valign=Gtk.Align.CENTER)
        self.followup = Gtk.Button(valign=Gtk.Align.CENTER, visible=False)
        self.followup.connect("clicked", lambda *_: self.start(self.followup_action))
        self.close_run = Gtk.Button(label="Close", valign=Gtk.Align.CENTER, css_classes=["flat"])
        self.close_run.connect("clicked", self.hide_run_panel)
        for w in (self.run_spinner, self.run_icon, text, self.details, self.followup, self.close_run):
            top.append(w)
        panel.append(top)

        self.log = Gtk.TextView(editable=False, cursor_visible=False, monospace=True,
                                wrap_mode=Gtk.WrapMode.WORD_CHAR)
        self.log_end = self.log.get_buffer().create_mark(None, self.log.get_buffer().get_end_iter(), False)
        log_reveal = Gtk.Revealer(child=Gtk.ScrolledWindow(child=self.log, min_content_height=220))
        self.details.bind_property("active", log_reveal, "reveal-child", 0)
        panel.append(log_reveal)
        self.run_panel = Gtk.Revealer(child=panel, transition_type=Gtk.RevealerTransitionType.SLIDE_UP)
        return self.run_panel

    def hide_run_panel(self, *_):
        self.run_panel.set_reveal_child(False)
        self.refresh_changes_bar()

    def log_append(self, text):
        buf = self.log.get_buffer()
        buf.insert(buf.get_end_iter(), text)
        self.log.scroll_mark_onscreen(self.log_end)
        last = [l for l in text.splitlines() if l.strip()]
        if last:
            self.run_last.set_text(last[-1].strip())

    def start(self, action):
        if self.running:
            return
        spec = ACTIONS[action] if isinstance(action, str) else action

        def go():
            if spec["root"]:
                self.ask_password(lambda pw: self.run(action, pw))
            else:
                self.run(action, None)

        if "confirm" not in spec:
            return go()
        dialog = Gtk.AlertDialog(message=spec["confirm"], buttons=["Cancel", "Delete"], cancel_button=0,
                                 default_button=0)
        def chosen(d, res):
            try:
                if d.choose_finish(res) == 1:
                    go()
            except GLib.Error:
                pass  # dismissed
        dialog.choose(self, None, chosen)

    def ask_password(self, then):
        win = Gtk.Window(transient_for=self, modal=True, title="Authenticate", default_width=400, resizable=False)
        win.set_titlebar(Gtk.HeaderBar(decoration_layout=":close"))
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10,
                      margin_top=22, margin_bottom=20, margin_start=22, margin_end=22)
        box.append(label("Enter your password", "title"))
        box.append(label("Changing the system needs administrator rights.", "dim", wrap=True))
        entry = Gtk.PasswordEntry(show_peek_icon=True, margin_top=6)
        error = label("", "dialog-error")
        buttons = Gtk.Box(spacing=8, halign=Gtk.Align.END, margin_top=6)
        cancel = Gtk.Button(label="Cancel", css_classes=["flat"])
        ok = Gtk.Button(label="Continue")
        for w in (entry, error, buttons):
            box.append(w)
        buttons.append(cancel)
        buttons.append(ok)
        win.set_child(box)

        def submit(*_):
            pw = entry.get_text()
            if not pw:
                return
            for w in (entry, ok):
                w.set_sensitive(False)
            error.set_css_classes(["dim"])
            error.set_text("Checking…")
            proc = Gio.Subprocess.new([SUDO, "-k", "-S", "-p", "", "-v"],
                                      Gio.SubprocessFlags.STDIN_PIPE | Gio.SubprocessFlags.STDOUT_SILENCE
                                      | Gio.SubprocessFlags.STDERR_SILENCE)
            proc.communicate_utf8_async(pw + "\n", None, checked, pw)

        def checked(proc, res, pw):
            proc.communicate_utf8_finish(res)
            if proc.get_successful():
                win.destroy()
                return then(pw)
            for w in (entry, ok):
                w.set_sensitive(True)
            entry.set_text("")
            entry.grab_focus()
            error.set_css_classes(["dialog-error"])
            error.set_text("Wrong password. Try again.")

        entry.connect("activate", submit)
        ok.connect("clicked", submit)
        cancel.connect("clicked", lambda *_: win.destroy())
        win.present()
        entry.grab_focus()

    def set_running(self, running):
        self.running = running
        for b in self.action_buttons + self.flake_buttons:
            b.set_sensitive(not running)
        self.close_run.set_visible(not running)
        (self.run_spinner.start if running else self.run_spinner.stop)()
        self.run_spinner.set_visible(running)
        self.run_icon.set_visible(not running)

    def run(self, action, password):
        """password=None runs as the user; otherwise the command runs under `sudo -S`
        (like `sudo ./toolkit/nixmod.sh update`), so nixmod.sh's own sudo calls don't prompt."""
        spec = ACTIONS[action] if isinstance(action, str) else action
        argv, flags = list(spec["argv"]), Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_MERGE
        if password is not None:
            # -k: ignore cached credentials so sudo always reads (consumes) the password line; otherwise
            # it would pass through to nixmod.sh and everything it starts.
            argv = [SUDO, "-k", "-S", "-p", "", "/run/current-system/sw/bin/env",
                    f"PATH={os.environ.get('PATH', '')}"] + argv
            flags |= Gio.SubprocessFlags.STDIN_PIPE
        snapshot = dict(self.desired)
        self.log.get_buffer().set_text("")
        self.run_title.set_text(spec["running"])
        self.run_title.set_css_classes(["name"])
        self.run_last.set_text("Starting…")
        self.followup.set_visible(False)
        self.details.set_active(False)
        self.set_running(True)
        self.changes_bar.set_reveal_child(False)
        self.run_panel.set_reveal_child(True)
        try:
            proc = Gio.Subprocess.new(argv, flags)
            if password is not None:
                stdin = proc.get_stdin_pipe()
                stdin.write_all((password + "\n").encode(), None)
                stdin.close(None)
        except GLib.Error as e:
            self.log_append(str(e) + "\n")
            return self.finish(action, False, snapshot)

        # Chunked reads: PyGObject's read_line_finish returns b'' for both EOF and blank lines.
        decoder = codecs.getincrementaldecoder("utf-8")("replace")
        partial = [""]

        def clean(lines):
            return "".join(ANSI.sub("", ln).split("\r")[-1] + "\n" for ln in lines)

        def on_chunk(s, res):
            data = s.read_bytes_finish(res).get_data()
            if not data:
                if partial[0]:
                    self.log_append(clean(partial))
                return proc.wait_async(None, lambda p, r: (p.wait_finish(r),
                                                            self.finish(action, p.get_successful(), snapshot)))
            *lines, partial[0] = (partial[0] + decoder.decode(data)).split("\n")
            self.log_append(clean(lines))
            s.read_bytes_async(65536, GLib.PRIORITY_DEFAULT, None, on_chunk)

        proc.get_stdout_pipe().read_bytes_async(65536, GLib.PRIORITY_DEFAULT, None, on_chunk)

    def finish(self, action, ok, snapshot):
        spec = ACTIONS[action] if isinstance(action, str) else action
        self.set_running(False)
        self.run_title.set_text(spec["done" if ok else "fail"])
        self.run_title.set_css_classes(["name", "ok" if ok else "err"])
        self.run_icon.set_text("✓" if ok else "✕")
        if self.run_last.get_text() == "Starting…":  # the command printed nothing
            self.run_last.set_text("")
        self.run_icon.set_css_classes(["status-mark", "ok" if ok else "err"])
        if not ok:
            self.run_last.set_text("See the details below for the error.")
            self.details.set_active(True)
        if ok and action in ("apply", "rebuild"):  # a switch installs packages.json as it was at launch
            self.applied = snapshot
            self.state.update(generation=current_generation(), packages=snapshot)
            write_json(STATE_FILE, self.state)
            self.refresh_packages()
        if ok and spec.get("after"):
            spec["after"]()
        if ok and "followup" in spec:
            text, self.followup_action = spec["followup"]
            self.followup.set_label(text)
            self.followup.set_visible(True)
        self.refresh_facts()


class App(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="com.nikmen.NixmodGui")

    def do_activate(self):
        css = Gtk.CssProvider()
        css.load_from_string(CSS)
        Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(), css,
                                                  Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        (self.get_active_window() or Window(self)).present()


if __name__ == "__main__":
    App().run()
