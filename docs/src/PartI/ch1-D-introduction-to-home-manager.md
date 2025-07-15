# Appendix D: Home Manager 기초

## D.1 Home Manager 개념

### 사용자 환경 관리

**Home Manager**는 사용자 레벨의 환경과 설정을 Nix로 선언적으로 관리하는 도구입니다.

```nix
# 목적: 개인 환경을 코드로 정의
# 핵심 개념: 사용자 레벨 설정, dotfiles 관리
{
  # 패키지 설치
  home.packages = with pkgs; [
    git vim curl python3
  ];

  # 프로그램 설정
  programs.git = {
    enable = true;
    userName = "Developer";
    userEmail = "dev@example.com";
  };

  # 환경 변수
  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "firefox";
  };
}
```

**적용 범위**:

- 개인 패키지 관리
- dotfiles 버전 관리
- 프로그램 설정 통합

## D.2 설치와 설정

### Flake 기반 설치

```nix
# 목적: Home Manager Flake 구성
# 핵심 개념: 사용자별 구성, 모듈화
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations.developer = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home.nix ];
    };
  };
}
```

### 기본 설정

```nix
# 목적: Home Manager 기본 구성
# 핵심 개념: 사용자 정보, 상태 버전
{ config, pkgs, ... }:

{
  home.username = "developer";
  home.homeDirectory = "/home/developer";
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
```

## D.3 개발 환경 구성

### Python 개발 환경

```nix
# 목적: Python 개발자용 환경 설정
# 핵심 개념: 언어별 도구, 개발 워크플로우
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Python 도구
    python3
    python3Packages.pip
    python3Packages.virtualenv

    # 개발 도구
    python3Packages.black
    python3Packages.flake8
    python3Packages.pytest

    # 에디터와 유틸리티
    git curl wget tree htop
  ];

  # Python 환경 변수
  home.sessionVariables = {
    PYTHONPATH = "$HOME/.local/lib/python3.11/site-packages";
    PIP_USER = "true";
  };

  # 별칭
  home.shellAliases = {
    py = "python3";
    pip = "pip3";
    venv = "python3 -m venv";
  };
}
```

### 웹 개발 환경

```nix
# 목적: 웹 개발자용 환경 설정
# 핵심 개념: 다중 언어, 빌드 도구
{
  home.packages = with pkgs; [
    # 런타임
    nodejs yarn
    python3

    # 도구
    git docker-client

    # 에디터 지원
    nodePackages.typescript
    nodePackages.eslint
  ];

  # 프로젝트별 설정
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
```

## D.4 프로그램 설정 관리

### Git 설정

```nix
# 목적: Git 전역 설정 관리
# 핵심 개념: 버전 관리 설정, 워크플로우
{
  programs.git = {
    enable = true;
    userName = "Developer Name";
    userEmail = "dev@company.com";

    extraConfig = {
      init.defaultBranch = "main";
      push.default = "simple";
      pull.rebase = true;

      core.editor = "vim";
      merge.tool = "vimdiff";
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
      ".venv/"
      ".DS_Store"
      "node_modules/"
    ];
  };
}
```

### 셸 환경

```nix
# 목적: 셸 환경 커스터마이징
# 핵심 개념: 생산성 향상, 자동화
{
  programs.bash = {
    enable = true;

    shellAliases = {
      ll = "ls -la";
      grep = "grep --color=auto";
      ".." = "cd ..";
    };

    initExtra = ''
      # 프롬프트 설정
      export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

      # 히스토리 설정
      export HISTSIZE=10000
      export HISTFILESIZE=20000
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
      plugins = [ "git" "python" "node" ];
    };
  };
}
```

### 에디터 설정

```nix
# 목적: 에디터 환경 설정
# 핵심 개념: 개발 도구 통합
{
  programs.vim = {
    enable = true;

    extraConfig = ''
      set number
      set tabstop=4
      set shiftwidth=4
      set expandtab

      syntax on
      filetype plugin indent on

      set hlsearch
      set incsearch
    '';
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-vscode.vscode-typescript-next
      esbenp.prettier-vscode
    ];

    userSettings = {
      "editor.formatOnSave" = true;
      "python.defaultInterpreterPath" = "${pkgs.python3}/bin/python";
      "editor.tabSize" = 2;
    };
  };
}
```

## D.5 프로젝트별 환경

### direnv 통합

```nix
# 목적: 프로젝트별 자동 환경 전환
# 핵심 개념: 디렉토리 기반 환경
{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
```

프로젝트에서 사용:

```bash
# .envrc 파일 생성
echo "use flake" > .envrc
direnv allow
```

### 개발 템플릿

```nix
# 목적: 일관된 프로젝트 구조 제공
# 핵심 개념: 템플릿화, 자동화
{
  home.file = {
    # 프로젝트 템플릿
    "templates/python/.envrc".text = "use flake";
    "templates/python/flake.nix".text = ''
      {
        inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
        outputs = { nixpkgs, ... }:
          let pkgs = nixpkgs.legacyPackages.x86_64-linux;
          in {
            devShells.x86_64-linux.default = pkgs.mkShell {
              buildInputs = with pkgs; [
                python3
                python3Packages.pytest
              ];
            };
          };
      }
    '';

    # 스크립트
    "bin/new-python-project" = {
      text = ''
        #!/bin/bash
        mkdir -p "$1"
        cd "$1"
        cp -r ~/templates/python/* .
        direnv allow
      '';
      executable = true;
    };
  };
}
```

## D.6 환경 동기화

### 설정 백업

```bash
# Git 저장소로 설정 백업
cd ~/.config/home-manager
git init
git add .
git commit -m "초기 Home Manager 설정"
git remote add origin https://github.com/user/dotfiles.git
git push -u origin main
```

### 새 시스템에서 복원

```bash
# 설정 복제
git clone https://github.com/user/dotfiles.git ~/.config/home-manager
cd ~/.config/home-manager

# 환경 적용
home-manager switch --flake .
```

### 업데이트 관리

```bash
# 설정 업데이트
home-manager switch

# Flake 업데이트
nix flake update
home-manager switch --flake .

# 세대 관리
home-manager generations
home-manager switch --switch-generation 42
```

## D.7 모듈화와 재사용

### 공통 모듈

```nix
# 목적: 재사용 가능한 설정 모듈
# 파일: common.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git curl wget tree htop
  ];

  programs.git = {
    enable = true;
    extraConfig.init.defaultBranch = "main";
  };

  home.shellAliases = {
    ll = "ls -la";
    ".." = "cd ..";
  };
}
```

### 환경별 구성

```nix
# 목적: 환경별 특화 설정
# 파일: work.nix
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    docker-client kubectl
    slack discord
  ];

  programs.git = {
    userName = "Work Name";
    userEmail = "work@company.com";
  };
}
```

## D.8 특징과 활용

### 장점

- 사용자 레벨 선언적 관리
- 시스템 관리자 권한 불필요
- dotfiles 버전 관리
- 프로젝트별 환경 자동화

### 제한사항

- 시스템 레벨 설정 불가
- GUI 프로그램 설정 제한적
- 일부 프로그램 미지원

---

**요약**: Home Manager는 개인 개발 환경과 dotfiles를 체계적으로 관리하는 도구입니다. 사용자 레벨에서 재현 가능한 환경을 제공하여 개발 워크플로우를 표준화할 수 있습니다.
