{pkgs ? import <nixpkgs> {}}: let
  pythonEnv = pkgs.python3.withPackages (ps:
    with ps; [
      requests
      flask
      pytest
    ]);
in
  pkgs.mkShell {
    buildInputs = [
      pythonEnv
      pkgs.postgresql
      pkgs.redis
    ];

    shellHook = ''
      export DATABASE_URL="postgresql://localhost/myapp"
      export REDIS_URL="redis://localhost:6379"
      echo "웹 개발 환경 준비 완료"
    '';
  }
