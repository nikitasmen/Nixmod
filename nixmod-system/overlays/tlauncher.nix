# TLauncher — manually downloaded JAR (put TLauncher.jar in ~/Downloads/)
# Download from: https://tlauncher.org/

_self: super:

let
  # TLauncher downloads and runs its own JRE. Unlike Java from nixpkgs, that
  # runtime has no Nix RPATH, so AWT needs an explicit path to the X11 libs.
  x11LibraryPath = super.lib.makeLibraryPath (with super.xorg; [
    libX11
    libXext
    libXi
    libXrender
    libXtst
  ]);
in {
  tlauncher = super.stdenvNoCC.mkDerivation rec {
    pname = "tlauncher";
    version = "wrapper";

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin $out/share/applications

      cat > $out/bin/tlauncher << WRAPPER
#!${super.runtimeShell}
JAR="\$HOME/Downloads/TLauncher.jar"
if [[ ! -f "\$JAR" ]]; then
  echo "TLauncher.jar not found. Download from https://tlauncher.org/"
  echo "Save it as: \$JAR"
  exit 1
fi

# Put this assignment inside steam-run's environment so its setup cannot
# replace the path before TLauncher's bundled Java is started.
exec ${super.steam-run}/bin/steam-run ${super.coreutils}/bin/env \
  LD_LIBRARY_PATH="${x11LibraryPath}\''${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}" \
  ${super.jdk17}/bin/java -jar "\$JAR" "\$@"
WRAPPER
      chmod +x $out/bin/tlauncher

      cat > $out/share/applications/tlauncher.desktop << 'DESKTOP'
[Desktop Entry]
Type=Application
Name=TLauncher
Comment=Minecraft launcher
Exec=tlauncher
Icon=minecraft
Categories=Game;
DESKTOP
    '';

    meta = with super.lib; {
      description = "TLauncher Minecraft launcher (user-provided JAR)";
      homepage = "https://tlauncher.org/";
      maintainers = [ ];
      platforms = platforms.linux;
    };
  };
}
