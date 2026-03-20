# just a "normal packaged" C Program
# The trick was exposing the default inputs for the install phase
{
  stdenv,
  fetchgit,
  pkg-config,
  libxml2,
  curl,
  openssl,
  beaker,
  makeWrapper,
  templates ? null,
  static ? null,
  config ? null,
  lib,
}:
stdenv.mkDerivation rec {
  pname = "omnisearch";
  version = "git";

  src = fetchgit {
    url = "https://git.alovely.space/Mirrors/omnisearch";
    rev = "81ba9021a24254b8c3c4bbb21c6c0a8d07c3de68";
    sha256 = "s+hm6Rtx95Q1tf7NEKfkKpXbul6GfwqX/LsZGaddbgI=";
  };

  nativeBuildInputs = [pkg-config makeWrapper];
  buildInputs = [libxml2 curl openssl beaker];

  patchPhase = ''
    sed -i "s|/usr/include/libxml2|${libxml2.dev}/include/libxml2|g" Makefile
  '';

  buildPhase = "make";

  installPhase = let
    # I can technically remove the defaults here since I input them locally anyways via the flake
    # But this way you could technically copy this file and just import that instead
    templateDir =
      if templates != null
      then templates
      else "${src}/templates";
    staticDir =
      if static != null
      then static
      else "${src}/static";
    configFile =
      if config != null
      then config
      else "${src}/example-config.ini";
  in ''
    # Install binary
    mkdir -p $out/bin
    cp bin/omnisearch $out/bin/omnisearch.bin
    chmod +x $out/bin/omnisearch.bin

    # Install templates
    mkdir -p $out/share/omnisearch/templates
    cp -r ${templateDir}/* $out/share/omnisearch/templates/

    # Install config
    mkdir -p $out/share/omnisearch
    cp ${configFile} $out/share/omnisearch/config.ini

    # Install static assets
    mkdir -p $out/share/omnisearch/static
    cp -r ${staticDir}/* $out/share/omnisearch/static/

    # Wrap binary
    makeWrapper $out/bin/omnisearch.bin $out/bin/omnisearch \
      --set LD_LIBRARY_PATH ${beaker}/lib \
      --run "cd $out/share/omnisearch && exec $out/bin/omnisearch.bin \"\$@\""
  '';

  meta = with lib; {
    description = "Lightweight metasearch engine written in C";
    platforms = platforms.linux;
  };
}
