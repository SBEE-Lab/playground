{pkgs ? import <nixpkgs> {}}: let
  # python version 과 shell 에 정의할 packages 를 입력으로
  # 받아 환경을 출력하는 함수 정의
  mkPythonEnv = version: packages:
    version.withPackages (ps: map (pkg: ps.${pkg}) packages);

  # 두 패키지 리스트 basePkgs 와 webPkgs 의 조합을
  # 환경 정의 시점에 선언
  basePkgs = ["pandas" "numpy"];
  webPkgs = ["flask" "requests"];

  allPkgs = basePkgs ++ webPkgs;

  # 실제 실행 시점에는 하나의 interpreter 만 사용
  env = mkPythonEnv pkgs.python313 allPkgs;
in
  pkgs.mkShell {
    buildInputs = [env];
  }
