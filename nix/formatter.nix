{pkgs}:
pkgs.writeShellApplication {
  name = "treefmt";
  text = ''treefmt "$@"'';
  runtimeInputs = with pkgs; [
    deadnix
    alejandra
    shellcheck
    treefmt
  ];
}
