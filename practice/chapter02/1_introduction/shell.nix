{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python312
    python312Packages.biopython
    python312Packages.pandas
    python312Packages.matplotlib
    python312Packages.numpy
  ];
}
