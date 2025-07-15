# 6. Nix 핵심 개념과 동작 원리

## 6.1 Derivation: 빌드 명세서

### 개념 정의

**Derivation**은 패키지를 빌드하는 방법을 정의하는 명세서입니다. 필요한 입력, 빌드 과정, 예상 출력을 선언적으로 기술합니다.

```bash
# 목적: Derivation 구조 확인
# 핵심 개념: 빌드 명세, 의존성 정의
$ nix show-derivation -f basic-env.nix
{
  "/nix/store/abc123...env.drv": {
    "outputs": {
      "out": { "path": "/nix/store/def456...env" }
    },
    "inputDrvs": {
      "/nix/store/ghi789...python3.drv": ["out"],
      "/nix/store/jkl012...git.drv": ["out"]
    },
    "builder": "/nix/store/.../bash",
    "args": ["-e", "/nix/store/.../builder.sh"]
  }
}
```

**구성 요소**:

- **inputs**: 빌드에 필요한 의존성
- **builder**: 빌드를 수행할 실행 파일
- **outputs**: 빌드 결과물의 저장 위치

## 6.2 Nix Store: 불변 패키지 저장소

### 저장소 구조

```bash
# 목적: Nix Store 구조 이해
# 핵심 개념: 해시 기반 주소, 불변성
$ ls /nix/store/ | head -5
0123456789abcdef-python3-3.8.16
1a2b3c4d5e6f7890-git-2.41.0
2b3c4d5e6f789012-curl-8.2.1
3c4d5e6f78901234-vim-9.0.1677
4d5e6f7890123456-dev-environment
```

**경로 구조**: `/nix/store/[32자리해시]-[패키지명]-[버전]/`

### 해시 기반 주소 지정

```bash
# 목적: 동일 입력의 결정론적 결과 확인
# 핵심 개념: 내용 기반 주소, 재현성
$ nix-build -E 'with import <nixpkgs> {}; python3'
/nix/store/abc123...python3-3.8.16

$ nix-build -E 'with import <nixpkgs> {}; python3'
/nix/store/abc123...python3-3.8.16  # 동일한 경로

# 다른 입력은 다른 해시
$ nix-build -E 'with import <nixpkgs> {}; python39'
/nix/store/xyz789...python3-3.9.18  # 다른 경로
```

**장점**: 내용이 같으면 해시가 같아 중복 저장을 방지하고 무결성을 보장합니다.

## 6.3 의존성 추적과 격리

### 의존성 관계 확인

```bash
# 목적: 패키지 간 의존성 관계 분석
# 핵심 개념: 의존성 그래프, 추적성
$ nix-store --query --references /nix/store/abc123...python3
/nix/store/def456...glibc-2.37
/nix/store/ghi789...openssl-3.0.9
/nix/store/jkl012...zlib-1.2.13

# 의존성 트리 시각화
$ nix-store --query --tree /nix/store/abc123...python3 | head -10
/nix/store/abc123...python3-3.8.16
├───/nix/store/def456...glibc-2.37
│   ├───/nix/store/mno345...linux-headers-6.4
│   └───/nix/store/pqr678...gcc-12.3.0
├───/nix/store/ghi789...openssl-3.0.9
└───/nix/store/jkl012...zlib-1.2.13
```

### 환경 격리 메커니즘

```bash
# 목적: 환경 격리 확인
# 핵심 개념: PATH 조작, 독립 실행

# 시스템 레벨에서는 사용 불가
$ python --version
bash: python: command not found

# Nix 환경에서만 사용 가능
$ nix-shell -p python3
[nix-shell]$ python --version
Python 3.8.16
[nix-shell]$ echo $PATH
/nix/store/abc123...python3/bin:/usr/bin:/bin

[nix-shell]$ exit
$ python --version  # 다시 사용 불가
bash: python: command not found
```

## 6.4 바이너리 캐시: 효율적 배포

### 캐시 동작 원리

```bash
# 목적: 바이너리 캐시 동작 확인
# 핵심 개념: 빌드 vs 다운로드, 효율성
$ nix-shell -p tensorflow
downloading 'https://cache.nixos.org/...tensorflow-2.11.0.nar.xz'
copying path '/nix/store/...tensorflow-2.11.0' from 'https://cache.nixos.org'...
# 컴파일 없이 즉시 사용 가능
```

### 캐시 설정

```bash
# 목적: 캐시 서버 확인
# 핵심 개념: 대체자(Substituter), 성능 최적화
$ nix show-config | grep substituters
substituters = https://cache.nixos.org

# 캐시 우선순위: 원격 바이너리 > 로컬 빌드
```

## 6.5 재현성 보장 메커니즘

### 환경 고정과 복제

```nix
# 목적: 완전한 재현성 보장
# 핵심 개념: 소스 고정, 버전 락
{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/22.11.tar.gz";
    sha256 = "11w3wn2yjhaa5pv20gbfbirvjq6i3m7pqrq2msf0g7cv44vijwgw";
  }) {}
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python38    # 정확히 Python 3.8.16
    git         # 정확히 Git 2.38.1
  ];
}
```

### 재현성 테스트

```bash
# 목적: 시점 무관 재현성 검증
# 핵심 개념: 결정론적 빌드

# 첫 번째 실행
$ nix-shell reproducible-env.nix --run "python --version"
Python 3.8.16

# 1년 후 실행해도 동일한 결과
$ nix-shell reproducible-env.nix --run "python --version"
Python 3.8.16  # 보장된 재현성
```

## 6.6 가비지 컬렉션: 저장소 관리

### 사용하지 않는 패키지 정리

```bash
# 목적: 저장소 공간 관리
# 핵심 개념: 참조 추적, 자동 정리

# 현재 저장소 크기
$ du -sh /nix/store
8.5G    /nix/store

# 사용되지 않는 패키지 확인
$ nix-store --gc --print-dead | head -5
/nix/store/old123...unused-package-1.0
/nix/store/old456...temporary-build
would delete 50 paths (2.1G)

# 가비지 컬렉션 실행
$ nix-collect-garbage
deleting '/nix/store/old123...unused-package'
2.1G freed

# 정리 후 크기
$ du -sh /nix/store
6.4G    /nix/store
```

### 세대 관리

```bash
# 목적: 이전 환경 보존과 정리
# 핵심 개념: 세대별 GC root, 롤백 지원

# 현재 세대 확인
$ nix-env --list-generations
   1   2023-10-01 10:00:00
   2   2023-10-15 14:30:00   (current)

# 이전 세대로 롤백
$ nix-env --switch-generation 1

# 오래된 세대 정리
$ nix-collect-garbage --delete-older-than 30d
```

## 6.7 실제 워크플로우에서의 동작

### 개발 환경 구성 과정

```bash
# 목적: Nix의 전체 동작 과정 이해
# 핵심 개념: 평가 → 빌드 → 실행

# 1. 표현식 평가
$ nix-shell dev-env.nix
evaluating derivation...

# 2. 의존성 해결
building '/nix/store/abc123...dev-env.drv'...

# 3. 바이너리 캐시 확인
downloading from 'https://cache.nixos.org'...

# 4. 환경 활성화
[nix-shell]$ # 모든 도구 사용 가능
```

### 팀 협업 시나리오

```bash
# 목적: 환경 공유와 재현
# 핵심 개념: 설정 파일 기반 협업

# 저장소 복제
$ git clone https://github.com/team/project.git
$ cd project

# 환경 자동 구성 (5분 내 완료)
$ nix-shell
[nix-shell]$ # 모든 팀원이 동일한 환경
```

## 6.8 핵심 개념 요약

### Nix의 설계 원칙

| 원칙       | 구현 방법      | 효과              |
| ---------- | -------------- | ----------------- |
| **불변성** | 해시 기반 주소 | 패키지 변경 불가  |
| **격리**   | PATH 조작      | 환경 간 간섭 없음 |
| **재현성** | 소스 고정      | 항상 같은 결과    |
| **효율성** | 바이너리 캐시  | 빠른 환경 구성    |
| **추적성** | 의존성 그래프  | 명확한 관계 파악  |

### 기존 도구와의 차이점

**전통적 패키지 관리자**:

- 시스템 전역 상태 변경
- 버전 충돌 발생 가능
- 수동 의존성 해결

**Nix**:

- 불변 저장소 사용
- 수학적 의존성 해결
- 자동 환경 격리

---

**요약**: Nix는 해시 기반 저장소, Derivation 빌드 시스템, 의존성 추적을 통해 완전히 재현 가능하고 격리된 환경을 제공합니다. 이는 소프트웨어 환경 관리에서 근본적인 패러다임 변화를 의미합니다.
