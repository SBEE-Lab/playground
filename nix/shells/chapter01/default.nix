{
  mkChapterShell,
  pkgs,
}: let
  scripts = import ./packages.nix {inherit pkgs;};
in
  mkChapterShell {
    chapter = "chapter01";
    extraNativeBuildInputs = with pkgs; [
      gawk
      gnugrep
      tree
      gnused
      htop
      tmux
      python312
      procps

      # session scripts
      scripts.chapter01-scripts
    ];
    extraShellHook = ''
    '';
  }
