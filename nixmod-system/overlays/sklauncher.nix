# SKLauncher - Minecraft launcher with offline/cracked account support
# Uses manually downloaded JAR (skmedix.pl doesn't allow automated fetch)
# Download from: https://skmedix.pl/downloads → put JAR in ~/.local/share/sklauncher/

self: super: let
  runtimeLibs = [
    super.libGL
    super.gtk3
    super.glib
    super.xorg.libXxf86vm
    super.xorg.libXtst
    super.xorg.libXi
    super.xorg.libXrender
    super.xorg.libXrandr
    super.xorg.libXext
    super.xorg.libX11
  ];
  libPath = super.lib.makeLibraryPath runtimeLibs;
in {
  sklauncher = super.stdenv.mkDerivation rec {
    pname = "sklauncher";
    version = "wrapper";

    dontUnpack = true;

    buildInputs = [ super.jdk21 ] ++ runtimeLibs;

    installPhase = ''
      mkdir -p $out/bin $out/share/applications

      cat > $out/bin/sklauncher << WRAPPER
#!/usr/bin/env bash
JAR="\$HOME/.local/share/sklauncher/SKLauncher.jar"
if [[ ! -f "\$JAR" ]]; then
  echo "SKLauncher not found. Download from https://skmedix.pl/downloads"
  echo "Save SKLauncher.jar to: \$JAR"
  exit 1
fi
export LD_LIBRARY_PATH="${libPath}:\${LD_LIBRARY_PATH:-}"
export GSETTINGS_SCHEMA_DIR="${super.gtk3}/share/gsettings-schemas/${super.gtk3.name}/glib-2.0/schemas"
exec ${super.jdk21}/bin/java -jar "\$JAR" "\$@"
WRAPPER
      chmod +x $out/bin/sklauncher

      cat > $out/share/applications/sklauncher.desktop << 'DESKTOP'
[Desktop Entry]
Type=Application
Name=SKLauncher
Comment=Minecraft launcher with offline/cracked account support
Exec=sklauncher
Icon=minecraft
Categories=Game;
DESKTOP
    '';

    meta = with super.lib; {
      description = "Minecraft launcher with offline/cracked account support";
      homepage = "https://skmedix.pl/";
      maintainers = [];
      platforms = platforms.linux;
    };
  };
}
