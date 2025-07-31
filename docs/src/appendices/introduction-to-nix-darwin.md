# Appendix C: nix-darwin 기초

## C.1 nix-darwin 개념

### macOS 시스템 관리

**nix-darwin**은 macOS 시스템 설정을 Nix 언어로 선언적으로 관리하는 도구입니다.

```nix
# 목적: macOS 시스템을 코드로 정의
# 핵심 개념: 선언적 설정, Homebrew 통합
{
  # 시스템 기본값
  system.defaults = {
    dock.autohide = true;
    finder.FXPreferredViewStyle = "clmv";
  };

  # Homebrew 패키지
  homebrew = {
    enable = true;
    brews = [ "git" "curl" ];
    casks = [ "visual-studio-code" "docker" ];
  };

  # Nix 패키지
  environment.systemPackages = with pkgs; [
    python3 nodejs
  ];
}
```

**활용 목적**:

- 개발 환경 표준화
- 새 Mac 설정 자동화
- 팀 환경 일관성 확보

## C.2 설치

### 전제 조건

```bash
# Nix 설치 확인
nix --version

# Xcode Command Line Tools 설치
xcode-select --install
```

### Flake 기반 설치

```nix
# 목적: nix-darwin Flake 구성
# 핵심 개념: 시스템 설정 모듈화
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nix-darwin, nixpkgs, ... }: {
    darwinConfigurations."MacBook-Dev" = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin-configuration.nix ];
    };
  };
}
```

```bash
# 설치 실행
nix run nix-darwin -- switch --flake ~/config#MacBook-Dev
```

## C.3 개발 환경 구성

### 기본 개발자 설정

```nix
# 목적: 개발자용 macOS 설정
# 핵심 개념: 생산성 향상, 도구 통합
{ config, pkgs, ... }:

{
  # Nix 설정
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # 시스템 패키지
  environment.systemPackages = with pkgs; [
    git vim curl wget tree htop
    python3 nodejs docker-client
  ];

  # 시스템 기본값
  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
      tilesize = 48;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv";
      ShowStatusBar = true;
    };

    NSGlobalDomain = {
      AppleKeyboardUIMode = 3;
      KeyRepeat = 1;
      InitialKeyRepeat = 14;
    };
  };

  system.stateVersion = 4;
}
```

### 전문 개발 환경

```nix
# 목적: 특화된 개발 환경 구성
# 핵심 개념: 언어별 도구, 전문 소프트웨어
{
  imports = [ ./base-darwin.nix ];

  # 개발 도구
  environment.systemPackages = with pkgs; [
    # 언어 런타임
    python3 nodejs go rustc

    # 빌드 도구
    cmake gnumake

    # 데이터베이스 클라이언트
    postgresql mysql80
  ];

  # 개발 환경 변수
  environment.variables = {
    EDITOR = "vim";
    PYTHON_PATH = "${pkgs.python3}/bin/python";
  };
}
```

## C.4 Homebrew 통합

### 패키지 관리 전략

```nix
# 목적: Nix와 Homebrew 역할 분담
# 핵심 개념: 도구별 최적 활용
{
  homebrew = {
    enable = true;

    # CLI 도구 (Nix가 더 적합한 경우)
    brews = [
      "postgresql@14"  # 특정 버전 필요
      "redis"
    ];

    # GUI 애플리케이션 (Homebrew가 적합)
    casks = [
      "visual-studio-code"
      "docker"
      "firefox"
      "slack"
    ];

    # 자동 정리
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };

  # Nix로 관리할 도구들
  environment.systemPackages = with pkgs; [
    git curl wget htop jq
    python3 nodejs
  ];
}
```

### 패키지 선택 기준

| 도구 유형   | Nix 사용             | Homebrew 사용     |
| ----------- | -------------------- | ----------------- |
| CLI 도구    | ✅ git, curl, python | ❌                |
| GUI 앱      | ❌                   | ✅ VSCode, Docker |
| 시스템 도구 | ❌                   | ✅ 드라이버, 폰트 |
| 개발 런타임 | ✅ 버전 관리 중요    | ⚠️ 특정 버전만    |

## C.5 시스템 설정 관리

### 프로그래밍 도구 설정

```nix
# 목적: 개발 도구 통합 설정
# 핵심 개념: 설정 파일 관리, 자동화
{
  # Git 전역 설정
  programs.git = {
    enable = true;
    config = {
      user.name = "Developer";
      user.email = "dev@company.com";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # 셸 설정
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
  };

  # 환경 변수
  environment = {
    variables = {
      EDITOR = "vim";
      LANG = "en_US.UTF-8";
    };

    shellAliases = {
      ll = "ls -la";
      rebuild = "darwin-rebuild switch --flake ~/config";
    };
  };
}
```

### 보안 설정

```nix
# 목적: 시스템 보안 강화
# 핵심 개념: 방화벽, 개인정보 보호
{
  # 방화벽
  system.defaults.alf = {
    globalstate = 1;
    allowsignedenabled = 1;
  };

  # 개인정보 보호
  system.defaults.NSGlobalDomain = {
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
  };

  # 자동 업데이트 비활성화 (수동 제어)
  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
}
```

## C.6 팀 표준화

### 공통 설정 모듈

```nix
# 목적: 팀 전체 표준 설정
# 핵심 개념: 설정 모듈화, 재사용
{ config, pkgs, ... }:

{
  # 공통 개발 도구
  environment.systemPackages = with pkgs; [
    git vim curl
    python3 nodejs docker-client
  ];

  # 공통 GUI 도구
  homebrew.casks = [
    "visual-studio-code"
    "docker"
    "slack"
  ];

  # 공통 시스템 설정
  system.defaults = {
    dock.tilesize = 48;
    finder.FXPreferredViewStyle = "clmv";
  };
}
```

### 개인 설정 확장

```nix
# 목적: 공통 설정 + 개인 커스터마이징
# 핵심 개념: 설정 상속, 개인화
{
  imports = [ ./team-common.nix ];

  # 개인 추가 도구
  environment.systemPackages = with pkgs; [
    tmux neovim
  ];

  homebrew.casks = [
    "spotify"
    "notion"
  ];
}
```

## C.7 시스템 관리

### 설정 적용과 업데이트

```bash
# 설정 적용
darwin-rebuild switch --flake ~/config

# 설정 테스트
darwin-rebuild check --flake ~/config

# 롤백
darwin-rebuild switch --rollback

# 세대 관리
nix-env --list-generations --profile /nix/var/nix/profiles/system
```

### 설정 백업과 복원

```bash
# 설정 백업
cd ~/config
git add .
git commit -m "시스템 설정 업데이트"
git push

# 새 Mac에서 복원
git clone https://github.com/user/mac-config.git ~/config
cd ~/config
darwin-rebuild switch --flake .
```

## C.8 특징과 제한사항

### 장점

- macOS 설정의 선언적 관리
- Homebrew와 자연스러운 통합
- 설정 버전 관리 및 공유
- 새 시스템 빠른 구성

### 제한사항

- macOS 전용
- 모든 시스템 설정을 다루지 못함
- GUI 설정은 제한적
- 일부 macOS 업데이트 시 재설정 필요

---

**요약**: nix-darwin은 macOS 개발 환경을 코드로 관리하여 팀 표준화와 환경 재현성을 제공합니다. Homebrew와의 통합으로 macOS 생태계의 장점을 유지하면서 설정 관리를 체계화할 수 있습니다.
