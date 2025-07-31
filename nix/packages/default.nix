{pkgs}: {
  build-docs = import ./build-docs.nix {inherit pkgs;};
  release = pkgs.callPackage ./release.nix {};
  preview = pkgs.callPackage ./changelog-preview.nix {};
  # show-assignment = import ./show-assignment.nix {inherit pkgs;};
}
