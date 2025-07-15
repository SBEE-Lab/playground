# Appendix B: NixOS 기초

## B.1 NixOS 개념

### 선언적 시스템 관리

**NixOS**는 전체 Linux 시스템을 Nix 언어로 선언하여 관리하는 배포판입니다.

```nix
# configuration.nix - 시스템 전체를 코드로 정의
{
  # 사용자 정의
  users.users.researcher = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  # 서비스 활성화
  services.openssh.enable = true;
  services.docker.enable = true;

  # 패키지 설치
  environment.systemPackages = with pkgs; [
    python3 git vim curl
  ];
}
```

**장점**:

- 시스템 상태를 코드로 버전 관리
- 원자적 업데이트와 안전한 롤백
- 완전한 재현성 보장

## B.2 설치 과정

### 최소 요구사항

- RAM: 2GB 이상 (권장 4GB)
- 디스크: 20GB 이상
- 아키텍처: x86_64, aarch64

### 기본 설치

```bash
# NixOS ISO 다운로드 및 부팅 후
sudo su

# 디스크 파티션 (예: /dev/sda)
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 512MiB -8GiB
parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 3 esp on

# 파일시스템 생성
mkfs.ext4 -L nixos /dev/sda1
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3

# 마운트
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/sda2

# 설정 생성
nixos-generate-config --root /mnt

# 설치
nixos-install
reboot
```

## B.3 연구 서버 설정 템플릿

### 기본 서버 구성

```nix
# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # 부트로더
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 네트워크
  networking = {
    hostName = "research-server";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 8888 ];  # SSH, HTTP, HTTPS, Jupyter
    };
  };

  # 사용자 계정
  users.users = {
    researcher = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... researcher@laptop"
      ];
    };

    admin = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... admin@workstation"
      ];
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

  # 개발 도구
  environment.systemPackages = with pkgs; [
    # 기본 도구
    git vim curl wget tree htop

    # Python 환경
    python3 python3Packages.pip

    # 서버 관리
    docker docker-compose
    nginx
  ];

  # Docker
  virtualisation.docker.enable = true;

  # Jupyter 서비스 (옵션)
  services.jupyter = {
    enable = true;
    ip = "0.0.0.0";
    port = 8888;
    password = "'sha256:...'";  # jupyter notebook password 명령으로 생성
  };

  system.stateVersion = "23.11";
}
```

### GPU 서버 설정

```nix
# CUDA 지원 서버
{ config, pkgs, ... }:

{
  # 기본 설정 상속
  imports = [ ./configuration.nix ];

  # NVIDIA 드라이버
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # CUDA 패키지
  environment.systemPackages = with pkgs; [
    cudatoolkit
    cudnn
    python3Packages.tensorflow-gpu
    python3Packages.pytorch
  ];

  # Docker NVIDIA 지원
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };
}
```

## B.4 패키지 관리와 서비스

### 시스템 업데이트

```bash
# 채널 업데이트
sudo nix-channel --update

# 시스템 재빌드
sudo nixos-rebuild switch

# 특정 세대로 롤백
sudo nixos-rebuild switch --rollback

# 세대 목록 확인
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

### 서비스 관리

```nix
# 웹 서버 추가
services.nginx = {
  enable = true;
  virtualHosts."research.lab.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:8888";  # Jupyter로 프록시
    };
  };
};

# 자동 SSL 인증서
security.acme = {
  acceptTerms = true;
  defaults.email = "admin@lab.com";
};

# 백업 서비스
services.restic.backups.daily = {
  repository = "/backup";
  paths = [ "/home" "/etc/nixos" ];
  timerConfig = {
    OnCalendar = "daily";
    Persistent = true;
  };
};
```

### 사용자별 환경

```nix
# 연구자별 Python 환경
environment.systemPackages = with pkgs; [
  (python3.withPackages (ps: with ps; [
    biopython pandas matplotlib numpy
    scikit-learn tensorflow
    jupyter notebook
  ]))
];

# 개발 도구
programs = {
  git.enable = true;
  vim.defaultEditor = true;
  zsh.enable = true;
};
```

## B.5 실제 운용 시나리오

### 연구 데이터 서버

```nix
# 데이터 보관 및 분석 서버
{
  # 대용량 스토리지 마운트
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/...";
    fsType = "ext4";
    options = [ "defaults" "noatime" ];
  };

  # 자동 백업
  services.restic.backups.research-data = {
    repository = "s3:backup-bucket/research";
    paths = [ "/data/experiments" "/data/results" ];
    environmentFile = "/etc/nixos/backup-credentials";
    timerConfig.OnCalendar = "weekly";
  };

  # 데이터 공유 (Samba)
  services.samba = {
    enable = true;
    shares.research = {
      path = "/data";
      browseable = "yes";
      writable = "yes";
      "valid users" = "researcher";
    };
  };

  # 모니터링
  services.prometheus = {
    enable = true;
    exporters.node.enable = true;
  };
}
```

### 업데이트 및 롤백

```bash
# 안전한 업데이트 절차
# 1. 현재 세대 확인
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# 2. 테스트 빌드
sudo nixos-rebuild test

# 3. 정상 작동 확인 후 적용
sudo nixos-rebuild switch

# 4. 문제 발생 시 롤백
sudo nixos-rebuild switch --rollback
```

### 원격 관리

```bash
# 원격 배포 (deploy-rs 사용)
nix run github:serokell/deploy-rs -- .#research-server

# 원격 빌드
nixos-rebuild switch --target-host researcher@server --use-remote-sudo
```

## B.6 요약 및 정리

**NixOS 활용 시점**:

- 연구실 서버 관리 필요
- 시스템 설정의 버전 관리 필요
- 완전한 재현성이 중요한 환경

**장점**:

- 선언적 시스템 관리
- 안전한 업데이트/롤백
- 완전한 재현성

**제한사항**:

- 학습 곡선 가파름
- 일부 소프트웨어 호환성 이슈
- 전통적 Linux 관리 방식과 다름

**Advanced**:

- Enterprise/Production 환경에서는 디스크 파티셔닝, 리소스 할당과 같은 프로비저닝 과정까지 모두 Nix로 선언 가능.
- 프로비저닝의 경우, HashiCorp Terraform 을 nixos-anywhere 와 함께 활용하여 AWS/Azure/Google Cloud 를 비롯한 여러 클라우드 서비스에 원격 설치 및 배포도 가능함

**다음 단계**: 개인 환경 관리는 [Appendix D (Home Manager)](./ch1-D-introduction-to-home-manager.md) 참조

---

## **읽을거리**

1. [Learn Nix](https://nixos.org/learn/)
2. [nix.dev](https://nix.dev/)
3. [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
4. [deploy-rs](https://github.com/serokell/deploy-rs)
