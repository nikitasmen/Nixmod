# qutebrowser config, tuned to behave like a normal browser.
# Vim keys still work; the bindings below just add the usual Ctrl shortcuts.
# Reference: :help in qutebrowser, or https://qutebrowser.org/doc/help/settings.html
config.load_autoconfig(False)  # this file is the single source of truth

# --- Behaviour ---
c.tabs.position = "top"
c.tabs.show = "always"
c.tabs.last_close = "default-page"   # closing the last tab keeps the window open
c.url.start_pages = ["https://duckduckgo.com"]
c.url.default_page = "https://duckduckgo.com"
c.url.searchengines = {"DEFAULT": "https://duckduckgo.com/?q={}"}
c.content.blocking.method = "both"   # adblock lists + hosts
c.colors.webpage.preferred_color_scheme = "dark"
c.downloads.location.directory = "~/Downloads"
c.downloads.location.prompt = False
c.zoom.default = "100%"
c.scrolling.smooth = True
c.input.insert_mode.auto_load = True  # start typing if a page focuses a text field on load

# --- Familiar shortcuts ---
bindings = {
    "<Ctrl-l>": "cmd-set-text -s :open",      # edit address
    "<Ctrl-t>": "cmd-set-text -s :open -t",   # new tab, type URL
    "<Ctrl-w>": "tab-close",
    "<Ctrl-Shift-t>": "undo",
    "<Ctrl-Tab>": "tab-next",
    "<Ctrl-Shift-Tab>": "tab-prev",
    "<Ctrl-r>": "reload",
    "<F5>": "reload",
    "<Alt-Left>": "back",
    "<Alt-Right>": "forward",
    "<Ctrl-f>": "cmd-set-text /",
    "<Ctrl-d>": "bookmark-add",
    "<Ctrl-h>": "history",
    "<Ctrl-j>": "download-open",
    "<Ctrl-Shift-p>": "open -p",              # private window
    "<Ctrl-plus>": "zoom-in",
    "<Ctrl-minus>": "zoom-out",
    "<Ctrl-0>": "zoom 100",
}
for key, cmd in bindings.items():
    config.bind(key, cmd)
    config.bind(key, cmd, mode="insert")  # work while typing in a page too

# --- Catppuccin Macchiato (same hex values as waybar/macchiato.css) ---
base, mantle, crust = "#24273a", "#1e2030", "#181926"
text, subtext0 = "#cad3f5", "#a5adcb"
surface0, surface1, overlay0 = "#363a4f", "#494d64", "#6e738d"
blue, mauve, green, yellow, peach, red = "#8aadf4", "#c6a0f6", "#a6da95", "#eed49f", "#f5a97f", "#ed8796"

c.colors.tabs.bar.bg = crust
c.colors.tabs.odd.bg = c.colors.tabs.even.bg = mantle
c.colors.tabs.odd.fg = c.colors.tabs.even.fg = subtext0
c.colors.tabs.selected.odd.bg = c.colors.tabs.selected.even.bg = base
c.colors.tabs.selected.odd.fg = c.colors.tabs.selected.even.fg = text
c.colors.tabs.pinned.odd.bg = c.colors.tabs.pinned.even.bg = surface0
c.colors.tabs.pinned.selected.odd.bg = c.colors.tabs.pinned.selected.even.bg = base
c.colors.tabs.indicator.start = blue
c.colors.tabs.indicator.stop = green
c.colors.tabs.indicator.error = red

c.colors.statusbar.normal.bg = mantle
c.colors.statusbar.normal.fg = text
c.colors.statusbar.insert.bg = green
c.colors.statusbar.insert.fg = crust
c.colors.statusbar.command.bg = mantle
c.colors.statusbar.command.fg = text
c.colors.statusbar.passthrough.bg = blue
c.colors.statusbar.passthrough.fg = crust
c.colors.statusbar.private.bg = mauve
c.colors.statusbar.private.fg = crust
c.colors.statusbar.command.private.bg = mauve
c.colors.statusbar.command.private.fg = crust
c.colors.statusbar.url.fg = text
c.colors.statusbar.url.success.http.fg = text
c.colors.statusbar.url.success.https.fg = green
c.colors.statusbar.url.error.fg = red
c.colors.statusbar.url.warn.fg = yellow
c.colors.statusbar.url.hover.fg = blue
c.colors.statusbar.progress.bg = blue

c.colors.completion.fg = text
c.colors.completion.odd.bg = mantle
c.colors.completion.even.bg = base
c.colors.completion.category.bg = crust
c.colors.completion.category.fg = mauve
c.colors.completion.category.border.top = c.colors.completion.category.border.bottom = crust
c.colors.completion.item.selected.bg = surface1
c.colors.completion.item.selected.fg = text
c.colors.completion.item.selected.border.top = c.colors.completion.item.selected.border.bottom = surface1
c.colors.completion.item.selected.match.fg = peach
c.colors.completion.match.fg = peach
c.colors.completion.scrollbar.bg = crust
c.colors.completion.scrollbar.fg = surface1

c.colors.hints.bg = yellow
c.colors.hints.fg = crust
c.colors.hints.match.fg = overlay0
c.hints.border = "1px solid " + crust

c.colors.downloads.bar.bg = mantle
c.colors.downloads.start.bg = blue
c.colors.downloads.stop.bg = green
c.colors.downloads.error.bg = red

c.colors.messages.info.bg = mantle
c.colors.messages.info.fg = text
c.colors.messages.info.border = mantle
c.colors.messages.warning.bg = peach
c.colors.messages.warning.fg = crust
c.colors.messages.warning.border = peach
c.colors.messages.error.bg = red
c.colors.messages.error.fg = crust
c.colors.messages.error.border = red

c.colors.prompts.bg = mantle
c.colors.prompts.fg = text
c.colors.prompts.border = "1px solid " + surface0
c.colors.prompts.selected.bg = surface1
