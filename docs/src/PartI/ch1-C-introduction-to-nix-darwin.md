# Appendix C: nix-darwin 기초

## C.1 nix-darwin 개념

### macOS 시스템 관리

**nix-darwin**은 macOS 시스템 설정을 Nix 언어로 선언적으로 관리하는 도구입니다.

```nix
# darwin-configuration.nix - macOS 시스템을 코드로 정의
{
  # 시스템 기본값
  system.defaults = {
    dock.autohide = true;
    finder.FXPreferredViewStyle = "clmv";
  };

  # Homebrew 패키지
  homebrew = {
    enable = true;
    brews = [ "python@3.11" "git" ];
    casks = [ "visual-studio-code" "docker" ];
  };

  # Nix 패키지
  environment.systemPackages = with pkgs; [
    curl wget tree htop
  ];
}
```

**활용 시점**:

- 개발 환경을 코드로 관리하고 싶을 때
- 새 Mac 설정을 빠르게 복원하고 싶을 때
- 팀의 macOS 환경을 표준화할 때

## C.2 설치 과정

### 전제 조건

```bash
# Nix 설치 (미설치 시)
curl -L https://nixos.org/nix/install | sh

# Xcode Command Line Tools
xcode-select --install
```

### nix-darwin 설치

```bash
# nix-darwin 설치
nix-build https://github.com/nix-darwin/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer

# 설정 파일 위치 확인
ls ~/.nixpkgs/darwin-configuration.nix
```

### Flake 기반 설치 (권장)

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }: {
    darwinConfigurations."MacBook-Research" = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin-configuration.nix ];
    };
  };
}
```

```bash
# Flake로 설치
nix run nix-darwin -- switch --flake ~/config#MacBook-Research
```

## C.3 개발 환경 통합 템플릿

### 연구자용 기본 설정

```nix
# darwin-configuration.nix
{ config, pkgs, ... }:

{
  # Nix 설정
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # 시스템 패키지
  environment.systemPackages = with pkgs; [
    # 개발 도구
    git vim curl wget
    tree htop jq

    # Python 환경
    python311
    python311Packages.pip
    python311Packages.virtualenv

    # 버전 관리
    git-lfs
  ];

  # 시스템 기본값
  system.defaults = {
    # Dock 설정
    dock = {
      autohide = true;
      orientation = "bottom";
      tilesize = 48;
    };

    # Finder 설정
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv";  # 컬럼 뷰
      ShowStatusBar = true;
    };

    # 트랙패드
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    # 기타
    NSGlobalDomain = {
      AppleKeyboardUIMode = 3;  # 키보드 탐색
      ApplePressAndHoldEnabled = false;  # 키 반복
      InitialKeyRepeat = 14;
      KeyRepeat = 1;
    };
  };

  # 사용자 계정
  users.users.researcher = {
    name = "researcher";
    home = "/Users/researcher";
  };

  # 시스템 버전
  system.stateVersion = 4;
}
```

### 생물정보학 개발 환경

```nix
{ config, pkgs, ... }:

{
  imports = [ ./darwin-configuration.nix ];

  # 전문 도구
  environment.systemPackages = with pkgs; [
    # 생물정보학 도구
    blast
    clustal-omega

    # Python 과학 계산
    (python311.withPackages (ps: with ps; [
      biopython pandas numpy
      matplotlib seaborn
      jupyter notebook
      scikit-learn
    ]))

    # R 환경
    R
    rPackages.BiocManager
    rPackages.ggplot2
  ];

  # 개발 환경 변수
  environment.variables = {
    PYTHON_PATH = "${pkgs.python311}/bin/python";
    R_LIBS_USER = "$HOME/.R/library";
  };
}
```

## C.4 Homebrew 연동

### 통합 패키지 관리

```nix
# Homebrew와 Nix 조합
{
  # Homebrew 활성화
  homebrew = {
    enable = true;

    # CLI 도구
    brews = [
      "python@3.11"
      "node"
      "postgresql"
      "redis"
    ];

    # GUI 애플리케이션
    casks = [
      # 개발 도구
      "visual-studio-code"
      "pycharm-ce"
      "docker"

      # 연구 도구
      "rstudio"
      "jupyter-notebook-app"

      # 유틸리티
      "iterm2"
      "rectangle"
      "the-unarchiver"
    ];

    # Mac App Store 앱
    masApps = {
      "Keynote" = 409183694;
      "Numbers" = 409203825;
    };

    # 자동 정리
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  # Nix로 관리할 것들
  environment.systemPackages = with pkgs; [
    # 명령행 도구 (Nix가 더 적합)
    git curl wget tree htop jq

    # 개발 런타임 (버전 관리 중요)
    python311 nodejs_18
  ];
}
```

### 패키지 선택 가이드

| 도구 유형   | Nix 권장           | Homebrew 권장     |
| ----------- | ------------------ | ----------------- |
| CLI 도구    | ✅ git, curl, htop | ❌                |
| 개발 런타임 | ✅ Python, Node.js | ⚠️ 버전별 설치    |
| GUI 앱      | ❌                 | ✅ VSCode, Docker |
| 시스템 도구 | ❌                 | ✅ 드라이버, 폰트 |

## C.5 기본 시스템 설정

### 개발자 친화적 설정

```nix
{
  # 터미널 및 셸
  programs = {
    zsh.enable = true;
    bash.enable = true;
  };

  # 환경 변수
  environment = {
    variables = {
      EDITOR = "vim";
      LANG = "en_US.UTF-8";
    };

    # 셸 별칭
    shellAliases = {
      ll = "ls -la";
      la = "ls -la";
      rebuild = "darwin-rebuild switch --flake ~/config";
      update = "cd ~/config && nix flake update && darwin-rebuild switch --flake .";
    };
  };

  # SSH 설정
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host lab-server
        HostName research.lab.edu
        User researcher
        ForwardX11 yes
    '';
  };

  # Git 전역 설정
  programs.git = {
    enable = true;
    config = {
      user.name = "Research Lab";
      user.email = "researcher@lab.edu";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
```

### 보안 및 개인정보

```nix
{
  # 방화벽
  system.defaults.alf = {
    globalstate = 1;  # 방화벽 활성화
    allowsignedenabled = 1;
    allowdownloadsignedenabled = 1;
  };

  # 개인정보 보호
  system.defaults.NSGlobalDomain = {
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
  };

  # Spotlight 제외 경로
  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
}
```

## C.6 실제 사용 시나리오

### 새 Mac 설정 자동화

```bash
# 설정 저장소 복제
git clone https://github.com/lab/mac-config.git ~/config
cd ~/config

# 환경 구성
nix run nix-darwin -- switch --flake .#MacBook-Research

# 30분 내 완전한 개발 환경 구성 완료
```

### 팀 표준화

```nix
# 연구실 공통 설정
{ config, pkgs, ... }:

{
  # 공통 개발 도구
  environment.systemPackages = with pkgs; [
    python311 git vim curl
    (python311.withPackages (ps: [ ps.biopython ps.pandas ]))
  ];

  # 공통 GUI 앱
  homebrew.casks = [
    "visual-studio-code"
    "docker"
    "rstudio"
  ];

  # 공통 시스템 설정
  system.defaults.dock.tilesize = 48;
  system.defaults.finder.FXPreferredViewStyle = "clmv";
}
```

### 프로젝트별 환경

```nix
# 특정 연구 프로젝트용 설정
{
  imports = [ ./base-config.nix ];

  # 프로젝트 전용 도구
  environment.systemPackages = with pkgs; [
    blast clustal-omega
    python311Packages.tensorflow
  ];

  homebrew.casks = [ "pymol" "chimera" ];

  # 프로젝트 디렉토리
  environment.variables.PROJECT_HOME = "/Users/researcher/protein-study";
}
```

### 시스템 관리

```bash
# 설정 적용
darwin-rebuild switch --flake ~/config

# 업데이트
cd ~/config
nix flake update
darwin-rebuild switch --flake .

# 롤백
darwin-rebuild switch --rollback

# 세대 관리
nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## C.7 요약

**nix-darwin 활용 시점**:

- macOS 개발 환경 표준화
- 새 Mac 설정 자동화
- 팀 환경 일관성 확보

**장점**:

- 선언적 시스템 관리
- Homebrew와 자연스러운 통합
- 버전 관리 가능한 설정

**제한사항**:

- macOS 전용
- 모든 시스템 설정을 다루지 못함
- GUI 설정은 제한적

**다음 단계**: 사용자 레벨 설정은 [Appendix D (Home Manager)](./ch1-D-introduction-to-home-manager.md) 참조
