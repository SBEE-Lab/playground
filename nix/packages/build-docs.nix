{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "build-docs";
  src = pkgs.lib.cleanSource ./../..;

  nativeBuildInputs = with pkgs; [
    mdbook
    mdbook-admonish
    mdbook-mermaid
  ];

  buildPhase = ''
    ${pkgs.mdbook}/bin/mdbook build docs/
  '';

  installPhase = ''
    mkdir -p $out
    cp -r docs/book/* $out/
  '';

  meta.description = "Built mdBook documentation for SBEE playground";
}
