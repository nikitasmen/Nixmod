# SKLauncher - Minecraft launcher with offline/cracked account support
# Uses manually downloaded JAR (skmedix.pl doesn't allow automated fetch)
# Download from: https://skmedix.pl/downloads → put JAR in ~/.local/share/sklauncher/

self: super: {
  sklauncher = super.stdenv.mkDerivation rec {
    pname = "sklauncher";
    version = "wrapper";

    dontUnpack = true;

    buildInputs = [ super.jdk21 ];

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
