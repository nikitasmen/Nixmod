{
  config,
  pkgs,
  lib,
  passman ? null,
  passman-tags ? null,
  ...
}:

let
  # If is provided as an input from flake.nix, use that
  # Otherwise, fetch it directly (for non-flake usage)
  passManSrc =
    if passman != null then
      passman
    else
      builtins.fetchGit {
        url = "https://github.com/nikitasmen/password-manager-.git";
        # For non-flake usage, we use fetchGit without rev to get latest commit
        # However, this is cached by Nix and doesn't update on every build
        # The flake-based approach is better for getting latest commits
      };

  # Flake inputs have no .git, so upstream's `git describe` would fall back to v0.0 and the updater would
  # always report an update. Use the highest v* tag from GitHub's tag list instead.
  tagsJson =
    if passman-tags != null then
      passman-tags
    else
      builtins.fetchurl "https://api.github.com/repos/nikitasmen/password-manager-/tags?per_page=100";
  version = lib.last (
    lib.sort (a: b: builtins.compareVersions a b < 0) (
      map (t: lib.removePrefix "v" t.name) (
        builtins.filter (t: lib.hasPrefix "v" t.name) (builtins.fromJSON (builtins.readFile tagsJson))
      )
    )
  );

  # Upstream's CMake downloads this pinned header at configure time, which the sandbox blocks; same URL and hash
  # as its CMakeLists.txt (bump both together), placed where it looks first.
  httplibHeader = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/yhirose/cpp-httplib/v0.18.3/httplib.h";
    sha256 = "a0a0c13dc086663863dbe6730a19716f7d3744904b6205496e8301750814dbd5";
  };

  passManPkg = pkgs.stdenv.mkDerivation {
    pname = "passman";
    inherit version;
    src = passManSrc;

    nativeBuildInputs = [ pkgs.cmake pkgs.copyDesktopItems ];
    buildInputs = with pkgs; [
      fltk
      openssl
      curl
      nlohmann_json # found by upstream's find_package; otherwise it downloads json.hpp, which the sandbox blocks
    ];
    # FindFLTK otherwise also requires OpenGL headers and the fluid binary, neither of which the app uses.
    cmakeFlags = [
      "-DFLTK_INCLUDE_DIR=${lib.getDev pkgs.fltk}/include"
      "-DFLTK_SKIP_OPENGL=ON"
      "-DFLTK_SKIP_FLUID=ON"
      "-DPWVAULT_VERSION=v${version}"
    ];

    # cmake's configure phase builds in ./build (cmakeBuildDir); CMake skips the download when the header is there
    preConfigure = ''
      install -Dm644 ${httplibHeader} build/include/httplib/httplib.h
    '';

    # Upstream's binary is `password_manager`; expose it as `passman`.
    postInstall = "mv $out/bin/password_manager $out/bin/passman";

    # drun launchers (wofi) only list .desktop entries.
    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "passman";
        desktopName = "Passman";
        exec = "passman";
        icon = "dialog-password";
        categories = [ "Utility" "Security" ];
      })
    ];

    meta.license = lib.licenses.mit;
  };
in
{
  environment.systemPackages = [ passManPkg ];
}
