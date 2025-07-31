{
  mkChapterShell,
  pkgs,
}:
mkChapterShell {
  chapter = "chapter1";
  extraNativeBuildInputs = with pkgs; [
    tree
    htop
    tmux
    python312
    gawk
    gnugrep
    gnused
    procps
  ];
  extraShellHook = ''
  '';
}
