{
  config,
  pkgs,
  lib,
  passman ? null,
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

  passManPkg = pkgs.stdenv.mkDerivation {
    pname = "passman";
    version = "unstable";
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
    ];

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
