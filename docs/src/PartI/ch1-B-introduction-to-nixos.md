# Appendix B: NixOS 기초

## B.1 NixOS 개념

### 선언적 시스템 관리

**NixOS**는 전체 Linux 시스템을 Nix 언어로 선언적으로 관리하는 배포판입니다.

```nix
# 목적: 시스템 전체를 코드로 정의
# 핵심 개념: 선언적 구성, 불변 시스템
{
  # 사용자 정의
  users.users.developer = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  # 서비스 활성화
  services.openssh.enable = true;
  services.docker.enable = true;

  # 시스템 패키지
  environment.systemPackages = with pkgs; [
    git vim curl python3
  ];
}
```

**핵심 특징**:

- 시스템 상태를 코드로 버전 관리
- 원자적 업데이트와 롤백
- 완전한 재현성

## B.2 설치 과정

### 최소 요구사항

- RAM: 4GB 이상
- 디스크: 20GB 이상
- 아키텍처: x86_64, aarch64

### 기본 설치 절차

```bash
# NixOS ISO 부팅 후 파티션 생성
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 512MiB -8GiB
parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB

# 파일시스템 생성
mkfs.ext4 -L nixos /dev/sda1
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3

# 마운트 및 설치
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/sda2

nixos-generate-config --root /mnt
nixos-install
```

## B.3 시스템 구성

### 기본 서버 설정

```nix
# 목적: 개발 서버 기본 구성
# 핵심 개념: 서비스 정의, 사용자 관리
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # 부트로더
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 네트워크
  networking = {
    hostName = "dev-server";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  # SSH 설정
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # 시스템 패키지
  environment.systemPackages = with pkgs; [
    git vim curl wget htop
    python3 nodejs docker
  ];

  # 가상화
  virtualisation.docker.enable = true;

  system.stateVersion = "23.11";
}
```

### 개발 환경 서버

```nix
# 목적: 개발팀용 서버 구성
# 핵심 개념: 다중 사용자, 개발 도구
{
  imports = [ ./base-config.nix ];

  # 사용자 계정
  users.users = {
    developer1 = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... developer1@laptop"
      ];
    };

    developer2 = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... developer2@laptop"
      ];
    };
  };

  # 개발 도구
  environment.systemPackages = with pkgs; [
    # 언어별 런타임
    python3 nodejs-18_x go rustc

    # 데이터베이스 클라이언트
    postgresql mysql80

    # 빌드 도구
    gnumake cmake gcc
  ];

  # 데이터베이스 서비스
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "development" ];
  };
}
```

## B.4 서비스 관리

### 웹 서버 구성

```nix
# 목적: Nginx 웹 서버 설정
# 핵심 개념: 리버스 프록시, SSL
{
  services.nginx = {
    enable = true;
    virtualHosts."api.example.com" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:3000";
      };
    };
  };

  # 자동 SSL 인증서
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@example.com";
  };
}
```

### 백업 서비스

```nix
# 목적: 자동 백업 설정
# 핵심 개념: 스케줄링, 데이터 보호
{
  services.restic.backups.daily = {
    repository = "/backup/restic";
    paths = [ "/home" "/etc/nixos" "/var/lib" ];
    passwordFile = "/etc/nixos/backup-password";
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
```

## B.5 시스템 관리

### 업데이트와 롤백

```bash
# 시스템 업데이트
sudo nixos-rebuild switch

# 설정 테스트 (재부팅 없이)
sudo nixos-rebuild test

# 이전 설정으로 롤백
sudo nixos-rebuild switch --rollback

# 세대 목록 확인
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

### 원격 관리

```bash
# 원격 빌드 및 배포
nixos-rebuild switch --target-host user@server --use-remote-sudo

# 설정 파일 동기화
rsync -av ./nixos-config/ server:/etc/nixos/
```

## B.6 실무 사례

### CI/CD 서버

```nix
# 목적: 지속적 통합 서버 구성
# 핵심 개념: 자동화, 컨테이너 지원
{
  # GitLab Runner
  services.gitlab-runner = {
    enable = true;
    services.default = {
      registrationConfigFile = "/etc/nixos/gitlab-runner-config";
      executor = "docker";
    };
  };

  # Docker 레지스트리
  services.dockerRegistry = {
    enable = true;
    port = 5000;
  };

  # 모니터링
  services.prometheus = {
    enable = true;
    exporters.node.enable = true;
  };
}
```

### 데이터베이스 서버

```nix
# 목적: 고가용성 데이터베이스 구성
# 핵심 개념: 데이터 지속성, 백업
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    dataDir = "/var/lib/postgresql/15";

    settings = {
      max_connections = 200;
      shared_buffers = "256MB";
      effective_cache_size = "1GB";
    };

    ensureDatabases = [ "production" "staging" ];
    ensureUsers = [
      {
        name = "app";
        ensurePermissions = {
          "DATABASE production" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  # 자동 백업
  services.postgresqlBackup = {
    enable = true;
    databases = [ "production" ];
    startAt = "02:00";
  };
}
```

## B.7 특징과 제한사항

### 장점

| 특성       | 설명                                    |
| ---------- | --------------------------------------- |
| **재현성** | 설정 파일로 완전히 동일한 시스템 재구성 |
| **롤백**   | 이전 시스템 상태로 즉시 복원            |
| **원자성** | 업데이트 성공 또는 완전 실패            |
| **테스트** | 프로덕션 적용 전 안전한 테스트          |

### 제한사항

- 전통적 Linux 관리 방식과 상이
- 학습 곡선 존재
- 일부 소프트웨어 호환성 이슈
- FHS(Filesystem Hierarchy Standard) 비준수

### 적용 시점

**권장**:

- 서버 인프라 관리
- 개발팀 표준화
- 시스템 설정 버전 관리

**비권장**:

- 데스크톱 일반 사용
- Linux 초보자
- 레거시 시스템 의존성

---

**요약**: NixOS는 전체 시스템을 선언적으로 관리하는 Linux 배포판입니다. 서버 환경에서 재현성과 안정성을 보장하지만, 전통적 관리 방식과는 다른 접근법을 요구합니다.
