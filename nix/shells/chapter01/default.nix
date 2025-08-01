{
  mkChapterShell,
  pkgs,
}:
mkChapterShell {
  chapter = "chapter1";
  extraNativeBuildInputs = with pkgs; [
    gawk
    gnugrep
    tree
    gnused
    htop
    tmux
    python312
    procps
  ];
  extraShellHook = ''

  '';
}
