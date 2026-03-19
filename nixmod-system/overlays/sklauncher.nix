# SKLauncher - Minecraft launcher with offline/cracked account support
# Download: https://skmedix.pl/downloads
# Requires Java 21

self: super: {
  sklauncher = super.stdenv.mkDerivation rec {
    pname = "sklauncher";
    version = "3.2.18";

    src = super.fetchurl {
      url = "https://skmedix.pl/SKLauncher/SKLauncher.jar";
      sha256 = "0kdh9vyamvra9gfag4in7fxm80hr5s0jvzd94zs3vwr8xhfi6gjs";
    };

    dontUnpack = true;

    # Java 21 bundled with SKLauncher only (not installed system-wide)
    buildInputs = [ super.jdk21 ];

    installPhase = ''
      mkdir -p $out/share/sklauncher $out/share/applications $out/bin
      cp $src $out/share/sklauncher/SKLauncher.jar

      cat > $out/bin/sklauncher << EOF
      #!${super.runtimeShell}
      exec ${super.jdk21}/bin/java -jar $out/share/sklauncher/SKLauncher.jar "\$@"
      EOF
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
      license = licenses.asl20;
      maintainers = [];
      platforms = platforms.linux;
    };
  };
}
