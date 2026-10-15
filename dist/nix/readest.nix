{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  nss,
  nspr,
  atk,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  gdk-pixbuf,
  glib,
  gtk3,
  libayatana-appindicator,
  libdrm,
  libgbm,
  libpulseaudio,
  librsvg,
  udev,
  libxkbcommon,
  mesa,
  libglvnd,
  pango,
  alsa-lib,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
}:

# Readest ebook reader (traditional tarball from GitHub Release).
# Generated + verified by CI (fork-tarball.yml on branch release/fork):
#   version/url/hash are filled in by CI on every push and uploaded as release
#   asset `readest.nix`. This file in dotfiles is a copy fetched by
#   pkgs/update-fork-tarballs.sh — do not edit hash by hand.
stdenv.mkDerivation rec {
  pname = "readest";
  version = "0.0.0-unset";

  src = fetchurl {
    url = "https://github.com/WantenMN/readest/releases/download/fork-linux-x86_64/readest-linux-x86_64.tar.gz";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    nss
    nspr
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    gdk-pixbuf
    glib
    gtk3
    libayatana-appindicator
    libdrm
    libgbm
    libpulseaudio
    librsvg
    udev
    libxkbcommon
    mesa
    libglvnd
    pango
    alsa-lib
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
  ];

  # Tarball top level is share/ (contents of the Tauri deb payload stage/usr).
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r share $out/share
    mkdir -p $out/bin
    ln -s ../share/Readest/readest $out/bin/.readest-unwrapped

    makeWrapper $out/bin/.readest-unwrapped $out/bin/readest \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --set CEF_DISABLE_SANDBOX 1

    substituteInPlace $out/share/applications/Readest.desktop \
      --replace-fail "Exec=readest" "Exec=$out/bin/readest"

    # chrome-sandbox needs root + setuid which is not available in pure PATH;
    # CEF falls back to the user namespace sandbox.
    chmod -R u+rwX,go+rX $out/share/Readest

    runHook postInstall
  '';

  meta = {
    description = "Readest ebook reader (CEF build)";
    homepage = "https://readest.com";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "readest";
  };
}
