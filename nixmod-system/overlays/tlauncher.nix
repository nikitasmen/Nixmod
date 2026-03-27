# TLauncher — manually downloaded JAR (put TLauncher.jar in ~/Downloads/)
# Download from: https://tlauncher.org/

self: super: {
  tlauncher = super.stdenv.mkDerivation rec {
    pname = "tlauncher";
    version = "wrapper";

    dontUnpack = true;

    buildInputs = [ super.jdk17 super.steam-run ];

    installPhase = ''
      mkdir -p $out/bin $out/share/applications

      cat > $out/bin/tlauncher << WRAPPER
#!/usr/bin/env bash
JAR="\$HOME/Downloads/TLauncher.jar"
if [[ ! -f "\$JAR" ]]; then
  echo "TLauncher.jar not found. Download from https://tlauncher.org/"
  echo "Save it as: \$JAR"
  exit 1
fi
exec ${super.steam-run}/bin/steam-run ${super.jdk17}/bin/java -jar "\$JAR" "\$@"
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
