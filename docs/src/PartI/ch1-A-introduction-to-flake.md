# Appendix A. Nix Flakes: 완전한 재현성 보장

## A.1 기존 방식의 한계

### shell.nix의 문제점

```nix
# basic-bio-env.nix (6장에서 사용)
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.biopython
    python38Packages.pandas
  ];
}
```

**문제**: `<nixpkgs>`가 시스템에 설치된 버전에 의존하여 시점에 따라 다른 환경이 생성됩니다.

```bash
# 2023년 10월 실행
$ nix-shell basic-bio-env.nix
Python 3.8.16, biopython 1.81

# 2024년 3월 실행 (nixpkgs 업데이트 후)
$ nix-shell basic-bio-env.nix
Python 3.8.18, biopython 1.83  # 다른 버전!
```

## A.2 Flakes: 연구 프로젝트의 디지털 보관소

### 개념 이해

**Flake**는 Nix의 새로운 형태로, 프로젝트의 모든 의존성을 명시적으로 선언하고 버전을 정확히 고정하는 시스템입니다.
비유하자면, 논문의 "Materials and Methods" 섹션과 같습니다. 사용한 모든 시약의 정확한 cat no., lot no., 농도가 기록되어 있어 다른 연구자가 정확히 같은 조건으로 실험을 재현할 수 있습니다.

**핵심 파일**:

- `flake.nix`: 프로젝트 설명서 (의존성과 환경 정의)
- `flake.lock`: 정확한 버전 기록 (자동 생성)

## A.3 첫 번째 Flake 작성

### 기본 구조

```nix
# flake.nix
{
  ## 기본적으로 flake 는 inptus, outputs, description, nixConfig 의 4개 항목으로 구성됩니다

  # 우리가 작성한 flake 의 설명
  description = "단백질 분석 프로젝트";

  # flake 의 모든 입력
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  # flake 의 모든 출력
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          python38
          python38Packages.biopython
          python38Packages.pandas
          python38Packages.matplotlib
        ];

        shellHook = ''
          echo "🧬 단백질 분석 환경 (Flake)"
          echo "Python: $(python --version)"
        '';
      };
    };
}
```

### 사용법

```bash
# 첫 실행 (flake.lock 자동 생성)
$ nix develop
🧬 단백질 분석 환경 (Flake)
Python: Python 3.8.16

# 6개월 후에도 정확히 같은 환경
$ nix develop
🧬 단백질 분석 환경 (Flake)
Python: Python 3.8.16  # 보장된 재현성
```

## A.4 다중 환경 Flake

### 연구 단계별 환경

```nix
# flake.nix
{
  description = "생물정보학 연구 환경들";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # 공통 함수
      mkBioEnv = name: extraPackages: pkgs.mkShell {
        inherit name;
        buildInputs = with pkgs; [
          python38
          python38Packages.biopython
          python38Packages.pandas
        ] ++ extraPackages;

        shellHook = ''
          echo "🧬 ${name} 환경"
          echo "Python: $(python --version)"
        '';
      };

    in {
      devShells.${system} = {
        # 기본 분석 환경
        default = mkBioEnv "기본 분석" (with pkgs; [
          python38Packages.matplotlib
        ]);

        # 기계학습 환경
        ml = mkBioEnv "기계학습 분석" (with pkgs; [
          python38Packages.tensorflow
          python38Packages.scikit-learn
          python38Packages.matplotlib
        ]);

        # 시퀀스 분석 환경
        sequence = mkBioEnv "시퀀스 분석" (with pkgs; [
          blast
          clustal-omega
          python38Packages.seaborn
        ]);
      };
    };
}
```

### 환경별 실행

```bash
# 기본 환경
$ nix develop    # nix develop .#default 와 동일
🧬 기본 분석 환경

# 기계학습 환경
$ nix develop .#ml
🧬 기계학습 분석 환경

# 시퀀스 분석 환경
$ nix develop .#sequence
🧬 시퀀스 분석 환경
```

## A.5 실제 연구 프로젝트 구성

### 완전한 프로젝트 구조

```bash
protein-study/
├── flake.nix          # 환경 정의
├── flake.lock         # 버전 고정 (자동 생성)
├── data/
│   ├── sequences.fasta
│   └── metadata.csv
├── scripts/
│   ├── analysis.py
│   └── visualization.py
└── README.md
```

### 프로젝트 Flake

```nix
# flake.nix
{
  description = "단백질 구조-기능 관계 연구";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Python 환경
          python38
          python38Packages.biopython
          python38Packages.pandas
          python38Packages.matplotlib
          python38Packages.seaborn
          python38Packages.scikit-learn

          # 분석 도구
          blast
          clustal-omega

          # 개발 도구
          git
          jupyter
        ];

        shellHook = ''
          echo "🧬 단백질 구조-기능 연구 환경"
          echo "데이터: $(ls data/ | wc -l) 파일"
          echo "스크립트: $(ls scripts/ | wc -l) 파일"
          echo ""
          echo "실행 방법:"
          echo "  python scripts/analysis.py"
          echo "  jupyter notebook"
        '';
      };

      # 분석 스크립트를 앱으로 제공
      apps.${system} = {
        analysis = {
          type = "app";
          program = "${pkgs.python38}/bin/python";
          args = [ "scripts/analysis.py" ];
        };
      };
    };
}
```

## A.6 버전 관리와 업데이트

### flake.lock 파일 이해

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

**의미**: 정확한 커밋 해시로 nixpkgs 버전이 고정되어 재현성 보장

### 업데이트 관리

```bash
# 현재 버전 확인
$ nix flake metadata
Resolved URL:  git+file:///home/user/protein-study
Path:          /nix/store/...protein-study
Revision:      7816540796e4f6b4f1a1e8c45be6c54f9e1b8db7
Last modified: 2023-10-19 14:28:46

# 의존성 업데이트 (신중하게)
$ nix flake update
• Updated 'nixpkgs': 'github:NixOS/nixpkgs/...' -> 'github:NixOS/nixpkgs/...'

# 특정 입력만 업데이트
$ nix flake update nixpkgs
```

## A.7 팀 협업과 공유

### Git 저장소에 포함

```bash
# 프로젝트 초기화
$ git init
$ git add flake.nix flake.lock data/ scripts/
$ git commit -m "초기 프로젝트 설정"

# 동료와 공유
$ git push origin main
```

### 팀원의 환경 구성

```bash
# 저장소 복제
$ git clone https://github.com/lab/protein-study.git
$ cd protein-study

# 환경 즉시 사용 (flake.lock 기반)
$ nix develop
🧬 단백질 구조-기능 연구 환경
# 5분 내에 완전히 동일한 환경 구성 완료

# 분석 실행
$ python scripts/analysis.py
```

## A.8 기존 프로젝트에서 Flakes 도입

### shell.nix → flake.nix 변환

**기존 (shell.nix)**:

```nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [ python38 python38Packages.biopython ];
}
```

**변환 후 (flake.nix)**:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  outputs = { nixpkgs, ... }: {
    devShells.x86_64-linux.default =
      nixpkgs.legacyPackages.x86_64-linux.mkShell {
        buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
          python38 python38Packages.biopython
        ];
      };
  };
}
```

---

**요약**: Flakes는 연구 프로젝트의 완전한 재현성을 보장하는 도구입니다. 의존성을 명시적으로 관리하고 버전을 정확히 고정하여 논문과 함께 제출할 수 있는 **"재현성 패키지"** 를 만들 수 있습니다. 팀 협업과 장기간 보존이 필요한 연구 프로젝트에 필수적입니다.
