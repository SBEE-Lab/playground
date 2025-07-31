{pkgs ? import <nixpkgs> {}}: let
  basePython = pkgs.python312;

  # 도구별 패키지 그룹
  dataTools = ps: with ps; [pandas numpy matplotlib];
  mlTools = ps: with ps; [pytorch scikit-learn];
  bioTools = ps: with ps; [biopython];
in let
  # 필요에 따라 조합
  dataEnv = basePython.withPackages dataTools;
  mlEnv = basePython.withPackages mlTools;

  # 전체 환경 (자동 호환성 해결)
  fullEnv = basePython.withPackages (
    ps:
      dataTools ps ++ mlTools ps ++ bioTools ps
  );
in {
  default = pkgs.mkShell {
    buildInputs = [fullEnv];
  };
}
