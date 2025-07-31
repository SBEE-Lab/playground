{
  description = "데이터 분석 프로젝트";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = {nixpkgs, ...}: let
    # for linux user
    # system = "x86_64-linux";
    # for darwin user
    system = "aarch64-darwin";

    pkgs = nixpkgs.legacyPackages.${system};

    mkPythonEnv = extraPackages:
      pkgs.mkShell {
        buildInputs = with pkgs;
          [
            python311
            python311Packages.pandas
            python311Packages.numpy
          ]
          ++ extraPackages;
      };
  in {
    devShells.${system} = {
      # 기본 분석 환경
      default = mkPythonEnv (with pkgs; [
        python311Packages.matplotlib
      ]);

      # 기계학습 환경
      ml = mkPythonEnv (with pkgs; [
        python311Packages.pytorch
        python311Packages.scikit-learn
      ]);

      # 웹 개발 환경
      web = mkPythonEnv (with pkgs; [
        python311Packages.flask
        python311Packages.requests
      ]);
    };
  };
}
