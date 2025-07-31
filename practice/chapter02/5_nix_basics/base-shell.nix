{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "dev-environment";

  buildInputs = with pkgs; [
    python310
    nodejs
    git
    curl
  ];

  shellHook = ''
    echo "개발 환경 준비 완료"
    echo "Python: $(python --version)"
    echo "Node: $(node --version)"
  '';
}
