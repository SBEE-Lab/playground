# Appendix D: Home Manager 기초

## D.1 Home Manager 개념

### 사용자 환경 관리

**Home Manager**는 사용자 레벨의 환경과 설정을 Nix로 선언적으로 관리하는 도구입니다.

```nix
# home.nix - 개인 환경을 코드로 정의
{
  # 패키지 설치
  home.packages = with pkgs; [
    python3 git vim curl
  ];

  # dotfiles 관리
  programs.git = {
    enable = true;
    userName = "연구자";
    userEmail = "researcher@lab.edu";
  };

  # 환경 변수
  home.sessionVariables = {
    EDITOR = "vim";
    PYTHON_PATH = "/home/user/.local/bin";
  };
}
```

**활용 시점**:

- 개인 개발 환경을 체계적으로 관리할 때
- dotfiles를 버전 관리하고 싶을 때
- 여러 시스템에서 일관된 환경을 원할 때

## D.2 설치 및 설정

### 독립 설치

```bash
# Home Manager 채널 추가
nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
nix-channel --update

# 설치
nix-shell '<home-manager>' -A install
```

### Flake 기반 설치 (권장)

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations.researcher = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home.nix ];
    };
  };
}
```

```bash
# Flake로 활성화
home-manager switch --flake .#researcher
```

### 기본 설정

```nix
# ~/.config/home-manager/home.nix
{ config, pkgs, ... }:

{
  home.username = "researcher";
  home.homeDirectory = "/home/researcher";
  home.stateVersion = "23.11";

  # Home Manager 자체 관리 허용
  programs.home-manager.enable = true;
}
```

## D.3 Python 개발 환경 템플릿

### 연구자용 기본 환경

```nix
{ config, pkgs, ... }:

{
  home.username = "researcher";
  home.homeDirectory = "/home/researcher";

  # Python 개발 환경
  home.packages = with pkgs; [
    # Python 기본
    python311
    python311Packages.pip
    python311Packages.virtualenv
    python311Packages.pipenv

    # 생물정보학 도구
    python311Packages.biopython
    python311Packages.pandas
    python311Packages.numpy
    python311Packages.matplotlib
    python311Packages.seaborn
    python311Packages.scikit-learn

    # 개발 도구
    python311Packages.ipython
    python311Packages.jupyter
    python311Packages.black
    python311Packages.flake8
    python311Packages.pytest

    # 시스템 도구
    git curl wget tree htop
    jq ripgrep fd
  ];

  # Python 환경 변수
  home.sessionVariables = {
    PYTHONPATH = "$HOME/.local/lib/python3.11/site-packages:$PYTHONPATH";
    PIP_USER = "true";
  };

  # 별칭
  home.shellAliases = {
    py = "python3";
    pip = "pip3";
    jn = "jupyter notebook";
    ipy = "ipython";
  };

  programs.home-manager.enable = true;
  home.stateVersion = "23.11";
}
```

### R 연동 환경

```nix
{
  home.packages = with pkgs; [
    # R 환경
    R
    rPackages.BiocManager
    rPackages.tidyverse
    rPackages.ggplot2
    rPackages.phyloseq

    # RStudio 대안 (CLI)
    rPackages.IRkernel  # Jupyter R 커널
  ];

  # R 설정
  home.file.".Rprofile".text = ''
    options(repos = c(CRAN = "https://cran.rstudio.com/"))
    if (!require("BiocManager", quietly = TRUE))
        install.packages("BiocManager")
  '';
}
```

## D.4 dotfiles 관리

### Git 설정

```nix
{
  programs.git = {
    enable = true;
    userName = "연구실 연구자";
    userEmail = "researcher@lab.edu";

    extraConfig = {
      init.defaultBranch = "main";
      push.default = "simple";
      pull.rebase = true;

      # 생물정보학 파일 처리
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
    };

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      cm = "commit -m";
      lg = "log --oneline --graph";
    };

    ignores = [
      "*.pyc"
      "__pycache__/"
      ".pytest_cache/"
      ".ipynb_checkpoints/"
      "*.egg-info/"
      ".venv/"
      ".DS_Store"
    ];
  };
}
```

### 셸 환경

```nix
{
  programs.bash = {
    enable = true;

    shellAliases = {
      ll = "ls -la";
      la = "ls -A";
      grep = "grep --color=auto";

      # 연구 관련
      lab = "cd ~/research";
      data = "cd ~/research/data";
      scripts = "cd ~/research/scripts";
    };

    initExtra = ''
      # 프롬프트 커스터마이징
      export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

      # Python 가상환경 표시
      if [ -n "$VIRTUAL_ENV" ]; then
        export PS1="($(basename $VIRTUAL_ENV)) $PS1"
      fi
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "python" "pip" ];
    };
  };
}
```

### 편집기 설정

```nix
{
  programs.vim = {
    enable = true;

    extraConfig = ''
      " 기본 설정
      set number
      set tabstop=4
      set shiftwidth=4
      set expandtab
      set autoindent

      " Python 특화
      autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab

      " 구문 강조
      syntax on
      filetype plugin indent on

      " 검색
      set hlsearch
      set incsearch
      set ignorecase
      set smartcase
    '';
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-python.flake8
      ms-toolsai.jupyter
    ];

    userSettings = {
      "python.defaultInterpreterPath" = "${pkgs.python311}/bin/python";
      "python.formatting.provider" = "black";
      "editor.formatOnSave" = true;
      "files.associations" = {
        "*.fasta" = "plaintext";
        "*.fa" = "plaintext";
        "*.fastq" = "plaintext";
      };
    };
  };
}
```

## D.5 프로젝트별 환경 구성

### direnv 통합

```nix
{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
```

```bash
# 프로젝트 디렉토리에서
echo "use flake" > .envrc
direnv allow

# 자동으로 프로젝트 환경 활성화
```

### 프로젝트 템플릿

```nix
# ~/research/protein-study/.envrc
use flake

# ~/research/protein-study/flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

  outputs = { nixpkgs, ... }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          python311
          python311Packages.biopython
          python311Packages.tensorflow
          blast
        ];

        shellHook = ''
          echo "🧬 단백질 연구 환경"
          export PROJECT_ROOT=$(pwd)
          export PYTHONPATH="$PROJECT_ROOT/src:$PYTHONPATH"
        '';
      };
    };
}
```

## D.6 실제 사용 시나리오

### 연구자 환경 설정

```nix
# ~/.config/home-manager/home.nix
{ config, pkgs, ... }:

{
  imports = [
    ./programs.nix    # 프로그램 설정
    ./development.nix # 개발 환경
    ./research.nix    # 연구 도구
  ];

  home = {
    username = "researcher";
    homeDirectory = "/home/researcher";
    stateVersion = "23.11";
  };

  # 연구 디렉토리 구조
  home.file = {
    "research/.keep".text = "";
    "research/data/.keep".text = "";
    "research/scripts/.keep".text = "";
    "research/results/.keep".text = "";

    # 공통 스크립트
    "research/scripts/setup_project.sh" = {
      text = ''
        #!/bin/bash
        mkdir -p data results notebooks
        echo "use flake" > .envrc
        direnv allow
      '';
      executable = true;
    };
  };

  programs.home-manager.enable = true;
}
```

### 시스템 간 동기화

```bash
# 설정 백업
cd ~/.config/home-manager
git init
git add .
git commit -m "Initial home configuration"
git remote add origin https://github.com/researcher/dotfiles.git
git push -u origin main

# 새 시스템에서 복원
git clone https://github.com/researcher/dotfiles.git ~/.config/home-manager
cd ~/.config/home-manager
home-manager switch
```

### 업데이트 관리

```bash
# 설정 업데이트
home-manager switch

# 패키지 업데이트
nix-channel --update
home-manager switch

# Flake 업데이트
cd ~/.config/home-manager
nix flake update
home-manager switch --flake .

# 롤백
home-manager generations
home-manager switch --switch-generation 42
```

### 팀 환경 표준화

```nix
# 연구실 공통 설정 모듈
# ~/.config/home-manager/lab-common.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # 공통 도구
    python311
    python311Packages.biopython
    python311Packages.pandas
    git
  ];

  programs.git = {
    enable = true;
    extraConfig = {
      # 연구실 공통 설정
      core.autocrlf = "input";
      init.defaultBranch = "main";
    };
  };

  # 공통 별칭
  home.shellAliases = {
    lab-server = "ssh researcher@lab.edu";
    backup = "rsync -av ~/research/ lab.edu:~/backup/";
  };
}
```

## D.7 요약

**Home Manager 활용 시점**:

- 개인 개발 환경 관리
- dotfiles 버전 관리
- 프로젝트별 환경 자동화

**장점**:

- 사용자 레벨 선언적 관리
- 시스템 독립적
- Git 친화적 설정

**제한사항**:

- 시스템 레벨 설정 불가
- GUI 설정 제한적
- 초기 학습 필요

**연구자에게 가장 실용적**: 개인 Python 환경, dotfiles, 프로젝트 자동화에 최적화 Appendix D: Introduction to Home-Manager
