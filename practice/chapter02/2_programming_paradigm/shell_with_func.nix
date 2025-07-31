{pkgs ? import <nixpkgs> {}}: let
  mkPythonEnv = version: packages:
    version.withPackages (ps: map (pkg: ps.${pkg}) packages);

  # 예: Python 3.12 환경에서 사용할 패키지
  myPythonEnv = mkPythonEnv pkgs.python312 [
    "numpy"
    "matplotlib"
    "pandas"
  ];
in
  pkgs.mkShell {
    buildInputs = [myPythonEnv];
  }
