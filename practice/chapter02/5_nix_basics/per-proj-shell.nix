{pkgs ? import <nixpkgs> {}}: let
  mkDevEnv = {
    name,
    language,
    packages ? [],
  }:
    pkgs.mkShell {
      inherit name;
      buildInputs = with pkgs;
        [
          git
          (
            if language == "python"
            then python3
            else nodejs
          )
        ]
        ++ packages;

      shellHook = ''
        echo "${name} 환경"
        echo "언어: ${language}"
      '';
    };
in {
  python-env = mkDevEnv {
    name = "python-dev";
    language = "python";
    packages = with pkgs; [python3Packages.requests];
  };

  web-env = mkDevEnv {
    name = "web-dev";
    language = "node";
    packages = with pkgs; [yarn];
  };
}
