# Appendix A. Nix Flakes: 완전한 재현성 보장

## A.1 기존 방식의 한계

### shell.nix의 재현성 문제

```nix
# 목적: 기존 방식의 문제점 파악
# 문제점: nixpkgs 버전 미고정
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.pandas
  ];
}
```

**문제**: `<nixpkgs>`가 시스템 채널에 의존하여 시점에 따라 다른 환경 생성

```bash
# 2023년 10월 실행
$ nix-shell basic-env.nix
Python 3.8.16, pandas 1.5.3

# 2024년 3월 실행 (nixpkgs 업데이트 후)
$ nix-shell basic-env.nix
Python 3.8.18, pandas 2.0.1  # 다른 버전
```

## A.2 Flakes 개념

### 정의와 구조

**Flake**는 프로젝트의 모든 의존성을 명시적으로 선언하고 버전을 정확히 고정하는 시스템입니다.

**핵심 파일**:

- `flake.nix`: 의존성과 출력 정의
- `flake.lock`: 정확한 버전 해시 (자동 생성)

### 기본 구조

```nix
# 목적: Flake 기본 구조 이해
# 핵심 개념: inputs, outputs, 버전 고정
{
  description = "개발 환경 프로젝트";

  # 모든 외부 의존성 명시
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  # 제공할 출력들 정의
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          python38
          python38Packages.pandas
        ];
      };
    };
}
```

## A.3 다중 환경 Flake

### 환경별 구성

```nix
# 목적: 프로젝트 단계별 환경 제공
# 핵심 개념: 다중 출력, 조합성
{
  description = "데이터 분석 프로젝트";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      mkPythonEnv = extraPackages: pkgs.mkShell {
        buildInputs = with pkgs; [
          python38
          python38Packages.pandas
          python38Packages.numpy
        ] ++ extraPackages;
      };
    in {
      devShells.${system} = {
        # 기본 분석 환경
        default = mkPythonEnv (with pkgs; [
          python38Packages.matplotlib
        ]);

        # 기계학습 환경
        ml = mkPythonEnv (with pkgs; [
          python38Packages.tensorflow
          python38Packages.scikit-learn
        ]);

        # 웹 개발 환경
        web = mkPythonEnv (with pkgs; [
          python38Packages.flask
          python38Packages.requests
        ]);
      };
    };
}
```

### 사용법

```bash
# 기본 환경
$ nix develop

# 특정 환경
$ nix develop .#ml
$ nix develop .#web
```

## A.4 실제 프로젝트 구성

### 프로젝트 구조

```text
data-analysis/
├── flake.nix
├── flake.lock
├── src/
│   ├── analysis.py
│   └── utils.py
├── data/
│   └── dataset.csv
└── README.md
```

### 완전한 프로젝트 Flake

```nix
# 목적: 실무 프로젝트 설정
# 핵심 개념: 개발도구 통합, 스크립트 제공
{
  description = "데이터 분석 프로젝트";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Python 환경
          python38
          python38Packages.pandas
          python38Packages.matplotlib
          python38Packages.jupyter

          # 개발 도구
          git
          black  # 코드 포매터
        ];

        shellHook = ''
          echo "데이터 분석 환경"
          echo "데이터: $(ls data/ | wc -l) 파일"
          echo ""
          echo "사용법:"
          echo "  python src/analysis.py"
          echo "  jupyter notebook"
        '';
      };

      # 분석 스크립트를 앱으로 제공
      apps.${system}.analysis = {
        type = "app";
        program = "${pkgs.python38}/bin/python";
        args = [ "src/analysis.py" ];
      };
    };
}
```

## A.5 버전 관리

### flake.lock 파일

```json
{
  "nodes": {
    "nixpkgs": {
      "locked": {
        "lastModified": 1697723726,
        "narHash": "sha256-SaTWPkI8a5xSHX/rrKzUe9...",
        "owner": "NixOS",
        "repo": "nixpkgs",
        "rev": "7816540796e4f6b4f1a1e8c45be6c54f9e1b8db7",
        "type": "github"
      }
    }
  }
}
```

**의미**: 정확한 커밋 해시로 nixpkgs 버전 고정하여 재현성 보장

### 업데이트 관리

```bash
# 현재 버전 확인
$ nix flake metadata

# 의존성 업데이트
$ nix flake update

# 특정 입력만 업데이트
$ nix flake update nixpkgs
```

## A.6 팀 협업

### Git 통합

```bash
# 프로젝트 초기화
$ git init
$ git add flake.nix flake.lock src/ data/
$ git commit -m "프로젝트 초기 설정"
```

### 팀원 환경 구성

```bash
# 저장소 복제
$ git clone https://github.com/team/data-project.git
$ cd data-project

# 환경 즉시 사용
$ nix develop  # flake.lock 기반으로 동일한 환경 구성
```

## A.7 기존 프로젝트 마이그레이션

### shell.nix → flake.nix 변환

**기존**:

```nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [ python38 git ];
}
```

**변환 후**:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  outputs = { nixpkgs, ... }: {
    devShells.x86_64-linux.default =
      nixpkgs.legacyPackages.x86_64-linux.mkShell {
        buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
          python38 git
        ];
      };
  };
}
```

---

**요약**: Flakes는 모든 의존성을 명시적으로 관리하여 완전한 재현성을 보장합니다. 프로젝트와 환경을 하나의 단위로 관리하여 팀 협업과 장기 보존에 필수적입니다.
