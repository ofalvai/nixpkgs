{
  autoPatchelfHook,
  fetchurl,
  glib,
  glib-networking,
  gtk3,
  lib,
  libsecret,
  makeDesktopItem,
  openjdk21,
  stdenvNoCC,
  webkitgtk_4_1,
  wrapGAppsHook3,
  gitUpdater,
  maven,
  fetchFromGitHub,
  stdenv,
  makeWrapper,
  jre,
}:
let
  desktopItem = makeDesktopItem {
    name = "Portfolio";
    exec = "portfolio";
    icon = "portfolio";
    comment = "Calculate Investment Portfolio Performance";
    desktopName = "Portfolio Performance";
    categories = [ "Office" ];
    startupWMClass = "Portfolio Performance";
  };

  runtimeLibs = lib.makeLibraryPath [
    glib
    glib-networking
    gtk3
    libsecret
    webkitgtk_4_1
  ];
in
maven.buildMavenPackage rec {
  pname = "PortfolioPerformance";
  version = "0.77.3";

  src = fetchFromGitHub {
    owner = "portfolio-performance";
    repo = "portfolio";
    rev = version;
    sha256 = "sha256-z6sLHKOx19O8iD5/BvYCPGPOUPHuZqjPNxYkw+xqFuU=";
  };

  mvnHash = "sha256-FbkdsyaRSYv4SLIyTHZAeC7RTXvaHWJilt19il8nGF8=";
  mvnParameters = "-f portfolio-app/pom.xml";

  nativeBuildInputs = [
    makeWrapper
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    wrapGAppsHook3
  ];

  installPhase =
    ''
        runHook preInstall


        mkdir -p $out/bin $out/share/portfolio

        mkdir -p $out/Applications
        mv portfolio-product/target/products/name.abuchen.portfolio.product/macosx/cocoa/aarch64/PortfolioPerformance.app/Contents/Eclipse/plugins/* $out/share/portfolio/
        mv portfolio-product/target/products/name.abuchen.portfolio.product/macosx/cocoa/aarch64/PortfolioPerformance.app $out/Applications/
        ln -s $out/Applications/PortfolioPerformance.app/Contents/MacOS/PortfolioPerformance $out/bin/portfolio

        makeWrapper ${jre}/bin/java $out/bin/portfolio \
          --add-flags "-jar $out/share/portfolio/name.abuchen.portfolio.bootstrap_${version}.jar"

      #   # Remove all jna plugins that does not match the system
      #   rm -fR $out/portfolio/plugins/com.sun.jna*/com/sun/jna/{\
      #   aix-ppc,\
      #   aix-ppc64,\
      #   darwin-aarch64,\
      #   darwin-x86-64,\
      #   dragonflybsd-x86-64,\
      #   freebsd-aarch64,\
      #   freebsd-x86,\
      #   freebsd-x86-64,\
      #   linux-aarch64,\
      #   linux-arm,\
      #   linux-armel,\
      #   linux-loongarch64,\
      #   linux-mips64el,\
      #   linux-ppc,\
      #   linux-ppc64le,\
      #   linux-riscv64,\
      #   linux-s390x,\
      #   linux-x86,\
      #   openbsd-x86,\
      #   openbsd-x86-64,\
      #   sunos-sparc,\
      #   sunos-sparcv9,\
      #   sunos-x86,\
      #   sunos-x86-64,\
      #   win32,\
      #   win32-aarch64,\
      #   win32-x86,\
      #   win32-x86-64\
      #   }



      runHook postInstall
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      # Create desktop item
      mkdir -p $out/share/applications
      cp ${desktopItem}/share/applications/* $out/share/applications
      mkdir -p $out/share/pixmaps
      ln -s $out/portfolio/icon.xpm $out/share/pixmaps/portfolio.xpm

    '' + lib.optionalString stdenv.hostPlatform.isDarwin ''

    '';


          #   makeWrapper $out/portfolio/PortfolioPerformance $out/bin/portfolio \
      #     --prefix LD_LIBRARY_PATH : "${runtimeLibs}" \
      #     --prefix PATH : ${openjdk21}/bin

  # TODO: mvnHash calc
  passthru.updateScript = gitUpdater { url = "https://github.com/buchen/portfolio.git"; };

  meta = {
    description = "Simple tool to calculate the overall performance of an investment portfolio";
    homepage = "https://www.portfolio-performance.info/";
    license = lib.licenses.epl10;
    maintainers = with lib.maintainers; [
      kilianar
      oyren
      shawn8901
    ];
    mainProgram = "portfolio";
    platforms = lib.platforms.unix;
  };
}
