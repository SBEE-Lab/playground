{pkgs}: let
  infinite-task = pkgs.writeShellScriptBin "infinite-task" ''
    exec ${pkgs.python312}/bin/python3 ${./scripts/infinite_task.py} "$@"
  '';

  long-task = pkgs.writeShellScriptBin "long-task" ''
    exec ${pkgs.python312}/bin/python3 ${./scripts/long_task.py} "$@"
  '';

  monitor = pkgs.writeShellScriptBin "monitor" ''
    export PATH=${pkgs.lib.makeBinPath [
      pkgs.coreutils
      pkgs.procps
      pkgs.gawk
      pkgs.findutils
    ]}:$PATH
    exec ${pkgs.bash}/bin/bash ${./scripts/monitor.sh} "$@"
  '';

  chapter01-scripts = pkgs.symlinkJoin {
    name = "chapter01-scripts";
    paths = [infinite-task long-task monitor];
  };
in {
  inherit infinite-task long-task monitor chapter01-scripts;
}
