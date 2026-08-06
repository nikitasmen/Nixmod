{ pkgs, ... }:

let
  wallpaperDirectory = "/home/nikmen/Pictures/wallpapers";
  fallbackBackground = ./assets/aurora-login.png;
  loginBackground = "/run/regreet-background";

  # ReGreet runs as an unprivileged user, which may not be able to traverse the
  # user's home directory. Copy a random wallpaper into /run before it starts.
  selectLoginBackground = pkgs.writeShellScript "select-login-background" ''
    set -eu

    selected="$(${pkgs.findutils}/bin/find ${wallpaperDirectory} -maxdepth 1 -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
      -print0 2>/dev/null | ${pkgs.coreutils}/bin/shuf -z -n 1 | ${pkgs.coreutils}/bin/tr -d '\0')"

    if [ -n "$selected" ]; then
      ${pkgs.coreutils}/bin/cp -- "$selected" ${loginBackground}
    else
      ${pkgs.coreutils}/bin/cp -- ${fallbackBackground} ${loginBackground}
    fi

    ${pkgs.coreutils}/bin/chmod 0644 ${loginBackground}
  '';
in
{
  # ReGreet provides a graphical GTK greeter while keeping greetd lightweight.
  # Its NixOS module also creates the state/log directories with safe ownership.
  programs.regreet = {
    enable = true;
    cageArgs = [ "-s" "-d" "-m" "last" ];

    font = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
      size = 15;
    };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };

    settings = {
      background = {
        path = loginBackground;
        fit = "Cover";
      };

      GTK = {
        application_prefer_dark_theme = true;
        cursor_blink = true;
      };

      appearance.greeting_msg = "Welcome home, nikmen";

      widget.clock = {
        format = "%H:%M  •  %A, %d %B";
        resolution = "1s";
        label_width = 360;
      };

      commands = {
        reboot = [ "systemctl" "reboot" ];
        poweroff = [ "systemctl" "poweroff" ];
      };
    };

    extraCss = ''
      @define-color base #24273a;
      @define-color mantle #1e2030;
      @define-color crust #181926;
      @define-color text #cad3f5;
      @define-color subtext #b8c0e0;
      @define-color surface0 #363a4f;
      @define-color surface1 #494d64;
      @define-color overlay0 #6e738d;
      @define-color blue #8aadf4;
      @define-color teal #8bd5ca;
      @define-color mauve #c6a0f6;
      @define-color red #ed8796;

      window.background {
        background-color: @crust;
        color: @text;
      }

      frame.background {
        background-color: alpha(@mantle, 0.92);
        color: @text;
        border: 1px solid alpha(@mauve, 0.5);
        border-radius: 22px;
        box-shadow:
          0 18px 48px alpha(@crust, 0.72),
          inset 0 1px alpha(white, 0.08);
      }

      frame.background > grid {
        margin: 18px;
      }

      frame.background > label {
        color: @text;
        font-size: 18px;
        font-weight: 700;
        letter-spacing: 1px;
        padding: 12px 24px;
        text-shadow: 0 2px 8px alpha(@crust, 0.8);
      }

      grid > label {
        color: @subtext;
        font-weight: 600;
      }

      entry,
      passwordentry,
      combobox button {
        min-height: 44px;
        color: @text;
        background: alpha(@surface0, 0.9);
        border: 1px solid alpha(@overlay0, 0.7);
        border-radius: 12px;
        box-shadow: inset 0 1px alpha(white, 0.04);
      }

      entry:focus,
      passwordentry:focus-within,
      combobox button:focus {
        border-color: @mauve;
        box-shadow: 0 0 0 3px alpha(@mauve, 0.2);
      }

      button {
        min-height: 42px;
        padding: 0 18px;
        color: @text;
        background: alpha(@surface0, 0.88);
        border: 1px solid alpha(@surface1, 0.9);
        border-radius: 12px;
        transition: 180ms ease;
      }

      button:hover {
        background: @surface1;
        border-color: alpha(@mauve, 0.75);
        box-shadow: 0 6px 18px alpha(@crust, 0.45);
      }

      button.suggested-action {
        color: @crust;
        background: linear-gradient(135deg, @mauve, @blue);
        border-color: alpha(white, 0.22);
        font-weight: 800;
      }

      button.suggested-action:hover {
        background: linear-gradient(135deg, @blue, @teal);
      }

      button.destructive-action {
        min-width: 120px;
        color: @text;
        background: alpha(@mantle, 0.82);
        border-color: alpha(@red, 0.45);
      }

      button.destructive-action:hover {
        color: @crust;
        background: @red;
        border-color: @red;
      }

      popover contents {
        color: @text;
        background: @mantle;
        border: 1px solid @surface1;
        border-radius: 12px;
      }

      selection {
        color: @crust;
        background: @mauve;
      }
    '';
  };

  services.greetd = {
    enable = true;
    settings.default_session.user = "greeter";
  };

  systemd.services.greetd = {
    unitConfig.RequiresMountsFor = wallpaperDirectory;
    serviceConfig.ExecStartPre = [ selectLoginBackground ];
  };
}
