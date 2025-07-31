# 2.5 Nix Core Concepts and System Architecture

## 핵심 개념

Nix의 동작 원리는 Derivation 빌드 시스템, 해시 기반 Nix Store, 순수 함수적 의존성 해결을 통해 완전한 재현성과 격리를 보장합니다. 이러한 아키텍처는 생물정보학 연구에서 요구되는 복잡한 소프트웨어 스택의 안정적 관리를 가능하게 합니다.

### Derivation: 빌드 명세서

Derivation은 패키지나 환경을 빌드하는 방법을 완전히 기술한 명세서입니다. 모든 입력, 빌드 과정, 예상 출력을 포함하여 동일한 입력에서 항상 동일한 출력을 보장합니다.

```bash
# Derivation 구조 확인
$ nix show-derivation -f '<nixpkgs>' python38
{
  "/nix/store/abc123...python3-3.8.16.drv": {
    "outputs": {
      "out": {
        "path": "/nix/store/def456...python3-3.8.16"
      }
    },
    "inputSrcs": [
      "/nix/store/ghi789...Python-3.8.16.tar.xz"
    ],
    "inputDrvs": {
      "/nix/store/jkl012...glibc-2.37-8.drv": ["out"],
      "/nix/store/mno345...openssl-3.0.9.drv": ["out"],
      "/nix/store/pqr678...zlib-1.2.13.drv": ["out"]
    },
    "system": "x86_64-linux",
    "builder": "/nix/store/stu901...bash-5.2-p15/bin/bash",
    "args": ["-e", "/nix/store/vwx234...builder.sh"],
    "env": {
      "buildInputs": "...",
      "nativeBuildInputs": "...",
      "src": "/nix/store/ghi789...Python-3.8.16.tar.xz"
    }
  }
}
```

Derivation의 핵심 구성 요소:

- **outputs**: 빌드 결과물이 저장될 경로들
- **inputSrcs**: 소스 파일들 (타르볼, 패치 등)
- **inputDrvs**: 의존하는 다른 derivation들
- **system**: 대상 플랫폼 (x86_64-linux, aarch64-darwin 등)
- **builder**: 빌드를 수행할 프로그램
- **args**: 빌더에 전달할 인자들
- **env**: 빌드 환경 변수들

```nix
# 커스텀 Derivation 생성 예제
{ pkgs ? import <nixpkgs> {} }:

let
  # 간단한 분석 스크립트 패키지
  analysis_script = pkgs.stdenv.mkDerivation {
    pname = "sequence-analyzer";
    version = "1.0.0";

    # 소스 코드 (로컬 파일)
    src = pkgs.writeText "analyze.py" ''
      #!/usr/bin/env python3
      import sys
      import json

      def analyze_fasta(filename):
          sequences = 0
          total_length = 0

          with open(filename) as f:
              for line in f:
                  if line.startswith('>'):
                      sequences += 1
                  else:
                      total_length += len(line.strip())

          return {
              "sequences": sequences,
              "total_length": total_length,
              "average_length": total_length / sequences if sequences > 0 else 0
          }

      if __name__ == "__main__":
          result = analyze_fasta(sys.argv[1])
          print(json.dumps(result, indent=2))
    '';

    # 빌드 의존성
    nativeBuildInputs = with pkgs; [ python3 ];

    # 설치 과정 정의
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/sequence-analyzer
      chmod +x $out/bin/sequence-analyzer

      # Python 경로 수정
      sed -i '1s|.*|#!${pkgs.python3}/bin/python3|' $out/bin/sequence-analyzer
    '';

    # 메타데이터
    meta = with pkgs.lib; {
      description = "Simple FASTA sequence analyzer";
      platforms = platforms.unix;
    };
  };

in analysis_script
```

### Nix Store: 불변 패키지 저장소

Nix Store는 모든 패키지가 저장되는 중앙 저장소로, 해시 기반 주소 체계를 통해 불변성과 격리를 보장합니다.

```bash
# Store 경로 구조 분석
$ ls /nix/store/ | head -5
0123456789abcdef01234567-glibc-2.37-8
1a2b3c4d5e6f7890a1b2c3d4-python3-3.8.16
2b3c4d5e6f789012b2c3d4e5-numpy-1.24.3-python3.8
3c4d5e6f78901234c3d4e5f6-gcc-12.3.0
4d5e6f7890123456d4e5f6g7-openssl-3.0.9

# 경로 구조: /nix/store/[32자리해시]-[패키지명]-[버전]/
# 해시는 모든 입력(소스, 의존성, 빌드 스크립트)으로부터 계산됨
```

해시 계산과 재현성:

```bash
# 동일한 입력에서 동일한 해시 생성 확인
$ nix-instantiate -E 'with import <nixpkgs> {}; python38'
/nix/store/abc123...python3-3.8.16.drv

$ nix-instantiate -E 'with import <nixpkgs> {}; python38'
/nix/store/abc123...python3-3.8.16.drv  # 동일한 경로

# 다른 입력은 다른 해시 생성
$ nix-instantiate -E 'with import <nixpkgs> {}; python39'
/nix/store/xyz789...python3-3.9.18.drv  # 다른 경로
```

Store 경로의 내용 분석:

```bash
# 패키지 내부 구조 확인
$ ls -la /nix/store/abc123...python3-3.8.16/
drwxr-xr-x bin/          # 실행 파일들
drwxr-xr-x lib/          # 라이브러리들
drwxr-xr-x include/      # 헤더 파일들
drwxr-xr-x share/        # 공유 데이터

# 의존성 확인 - 절대 경로로 하드코딩됨
$ ldd /nix/store/abc123...python3-3.8.16/bin/python3
linux-vdso.so.1 => (0x00007fff...)
libc.so.6 => /nix/store/def456...glibc-2.37/lib/libc.so.6
libdl.so.2 => /nix/store/def456...glibc-2.37/lib/libdl.so.2
```

### 의존성 추적과 격리

Nix는 각 패키지의 의존성을 명시적으로 추적하고 격리합니다. 이는 "dependency hell" 문제를 근본적으로 해결합니다.

```bash
# 의존성 관계 조회
$ nix-store --query --references /nix/store/abc123...python3-3.8.16
/nix/store/def456...glibc-2.37-8
/nix/store/ghi789...openssl-3.0.9
/nix/store/jkl012...zlib-1.2.13
/nix/store/mno345...ncurses-6.4
/nix/store/pqr678...readline-8.2

# 역방향 의존성 (이 패키지를 참조하는 패키지들)
$ nix-store --query --referrers /nix/store/abc123...python3-3.8.16
/nix/store/stu901...python3-numpy-1.24.3
/nix/store/vwx234...python3-pandas-2.0.1

# 의존성 트리 시각화
$ nix-store --query --tree /nix/store/abc123...python3-3.8.16 | head -15
/nix/store/abc123...python3-3.8.16
├───/nix/store/def456...glibc-2.37-8
│   ├───/nix/store/yza567...linux-headers-6.3
│   └───/nix/store/bcd890...gcc-12.3.0-lib
├───/nix/store/ghi789...openssl-3.0.9
│   ├───/nix/store/def456...glibc-2.37-8 [...]
│   └───/nix/store/jkl012...zlib-1.2.13
└───/nix/store/mno345...ncurses-6.4
    └───/nix/store/def456...glibc-2.37-8 [...]
```

환경 격리 메커니즘:

```bash
# 시스템과 완전히 분리된 환경
$ which python
/usr/bin/which: no python in (/usr/bin:/bin)

$ nix-shell -p python38
[nix-shell]$ which python
/nix/store/abc123...python3-3.8.16/bin/python

[nix-shell]$ echo $PATH
/nix/store/abc123...python3-3.8.16/bin:/nix/store/def456...coreutils-9.3/bin:...

[nix-shell]$ exit
$ which python
/usr/bin/which: no python in (/usr/bin:/bin)  # 다시 격리됨
```

### 바이너리 캐시와 성능 최적화

Nix는 미리 빌드된 바이너리를 캐시 서버에서 다운로드하여 빌드 시간을 크게 단축합니다. 해시가 같으면 빌드 결과도 동일하므로 안전하게 캐시를 공유할 수 있습니다.

```bash
# 캐시 서버 설정 확인
$ nix show-config | grep substituters
substituters = https://cache.nixos.org/ https://nix-community.cachix.org

# 캐시에서 다운로드되는 과정
$ nix-shell -p tensorflow
downloading 'https://cache.nixos.org/nar/0abc123...tensorflow-2.11.0.nar.xz'
downloading 'https://cache.nixos.org/nar/1def456...python3-numpy-1.24.3.nar.xz'
copying path '/nix/store/ghi789...tensorflow-2.11.0' from 'https://cache.nixos.org'...
copying path '/nix/store/jkl012...python3-numpy-1.24.3' from 'https://cache.nixos.org'...

# 로컬 빌드 vs 캐시 다운로드 비교
# 로컬 빌드: TensorFlow 컴파일 시간 2-4시간
# 캐시 다운로드: 네트워크 속도에 따라 5-15분
```

캐시 작동 원리:

```bash
# 빌드 계획 확인 (실제 빌드 전)
$ nix-build -E 'with import <nixpkgs> {}; python38' --dry-run
these derivations will be built:
  /nix/store/abc123...some-dependency.drv
these paths will be fetched (25.4 MiB download, 128.7 MiB unpacked):
  /nix/store/def456...python3-3.8.16
  /nix/store/ghi789...glibc-2.37-8

# 캐시 확인
$ nix path-info --json /nix/store/def456...python3-3.8.16 | jq .narSize
134217728  # 바이트 단위 크기

# 수동 캐시 푸시 (자체 캐시 서버 운영 시)
$ nix copy --to https://my-cache.example.com /nix/store/def456...python3-3.8.16
```

### 재현성 보장 메커니즘

Nix의 재현성은 소스 고정, 환경 격리, 결정론적 빌드의 조합으로 달성됩니다.

```nix
# 완전한 재현성을 위한 고정된 nixpkgs 사용
{ pkgs ? import (fetchTarball {
    # 특정 커밋 해시로 nixpkgs 고정
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-23.11.tar.gz";
    sha256 = "1wg61h4gndm3vcprdcg7rc4s1v3jkm5xd7lw8r2f67w502y94gcy";
  }) {}
}:

let
  # 정확한 버전 지정
  bioinformatics_env = pkgs.python38.withPackages (ps: with ps; [
    numpy       # 1.24.3 (nixpkgs 23.11에서 고정)
    pandas      # 2.0.3
    biopython   # 1.81
    matplotlib  # 3.7.1
  ]);

in pkgs.mkShell {
  buildInputs = [
    bioinformatics_env
    pkgs.blast     # 2.13.0
    pkgs.bwa       # 0.7.17
    pkgs.samtools  # 1.17
  ];

  # 환경 변수도 고정
  shellHook = ''
    export PYTHONHASHSEED=0  # Python 해시 시드 고정
    export OMP_NUM_THREADS=4 # OpenMP 스레드 수 고정

    echo "생물정보학 환경 (nixpkgs 23.11)"
    echo "Python: $(python --version)"
    echo "NumPy: $(python -c 'import numpy; print(numpy.__version__)')"
  '';
}
```

재현성 테스트:

```bash
# 1년 후에도 동일한 환경 구성 확인
$ nix-shell reproducible-bioinfo.nix --run "python -c 'import numpy; print(numpy.__version__)'"
1.24.3  # 항상 동일한 버전

# 다른 시스템에서도 동일한 결과
$ nix-shell --pure reproducible-bioinfo.nix --run "blast --version"
blastn: 2.13.0+  # 시스템과 무관하게 동일

# 해시 기반 확인성
$ nix-store --query --hash /nix/store/abc123...numpy-1.24.3
sha256:1a2b3c4d5e6f7890...  # 내용이 같으면 해시도 같음
```

### 가비지 컬렉션과 스토리지 관리

Nix Store는 자동으로 사용하지 않는 패키지를 정리하여 디스크 공간을 관리합니다.

```bash
# 현재 스토어 사용량 확인
$ du -sh /nix/store
45G     /nix/store

# GC 루트 확인 (삭제되지 않을 경로들)
$ nix-store --gc --print-roots | head -5
/home/user/.nix-profile -> /nix/store/abc123...user-environment
/nix/var/nix/profiles/default -> /nix/store/def456...system-profile
/run/current-system -> /nix/store/ghi789...nixos-system

# 삭제 가능한 경로 확인
$ nix-store --gc --print-dead | wc -l
1247  # 1247개 경로가 삭제 가능

# 예상 절약 공간 확인
$ nix-store --gc --print-dead | xargs nix-store --query --size | awk '{sum+=$1} END {print sum/1024/1024/1024 " GB"}'
8.5 GB

# 가비지 컬렉션 실행
$ nix-collect-garbage
deleting '/nix/store/old123...unused-package-1.0'
deleting '/nix/store/old456...temporary-build'
...
8.5G freed

# 특정 기간보다 오래된 것만 삭제
$ nix-collect-garbage --delete-older-than 30d
$ nix-collect-garbage --delete-older-than "2023-01-01"
```

세대 관리:

```bash
# 프로필 세대 확인
$ nix-env --list-generations
   1   2023-10-01 10:00:00   (current)
   2   2023-10-15 14:30:00
   3   2023-11-01 09:15:00

# 특정 세대로 롤백
$ nix-env --switch-generation 2

# 오래된 세대 삭제
$ nix-env --delete-generations old
$ nix-env --delete-generations 1 2  # 특정 세대들만
```

### 실제 워크플로우에서의 동작 과정

생물정보학 연구에서 Nix가 어떻게 동작하는지 단계별로 살펴보겠습니다.

```bash
# 1. 환경 정의 평가
$ nix-shell bioinfo-env.nix
evaluating derivation '/nix/store/abc123...bioinfo-env.drv'...

# 2. 의존성 그래프 구성
building dependency graph...
- python38: cache hit
- numpy: cache hit
- biopython: cache hit
- blast: needs building

# 3. 캐시 확인 및 다운로드
downloading from 'https://cache.nixos.org'...
copying path '/nix/store/def456...python3-3.8.16' (25.4 MiB)
copying path '/nix/store/ghi789...numpy-1.24.3' (15.2 MiB)

# 4. 필요시 로컬 빌드
building '/nix/store/jkl012...blast-2.13.0.drv'...
unpacking sources...
configuring...
building...
installing...

# 5. 환경 활성화
[nix-shell]$ which python
/nix/store/def456...python3-3.8.16/bin/python

[nix-shell]$ which blastn
/nix/store/jkl012...blast-2.13.0/bin/blastn
```

## Practice Section: 핵심 개념 실습

### 실습 1: Derivation 구조 확인

```bash
# 간단한 패키지의 Derivation 확인
nix show-derivation -f '<nixpkgs>' hello --json | jq '.[] | keys'

# Python 환경의 의존성 확인
nix-instantiate -E 'with import <nixpkgs> {}; python38' | head -1
```

### 실습 2: Store 경로 탐색

```bash
# Store에서 Python 패키지 찾기
ls /nix/store/*python3* | head -3

# 의존성 관계 확인
PYTHON_PATH=$(nix-build -E 'with import <nixpkgs> {}; python38' --no-out-link)
nix-store --query --references $PYTHON_PATH | head -5
```

### 실습 3: 환경 격리 테스트

```bash
# 시스템 Python 확인
which python || echo "시스템에 Python 없음"

# Nix 환경에서 Python 사용
nix-shell -p python38 --run "which python && python --version"

# 격리 확인
echo "시스템: $(which python 2>/dev/null || echo 'None')"
```

### 실습 4: 재현성 확인

```nix
# reproducible_test.nix
{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-23.11.tar.gz";
    sha256 = "1wg61h4gndm3vcprdcg7rc4s1v3jkm5xd7lw8r2f67w502y94gcy";
  }) {}
}:
pkgs.mkShell {
  buildInputs = [ pkgs.python38 ];
  shellHook = "python --version";
}
```

```bash
nix-shell reproducible_test.nix
```

### 실습 5: 가비지 컬렉션

```bash
# 현재 Store 크기 확인
du -sh /nix/store 2>/dev/null || echo "권한 부족"

# 삭제 가능한 경로 개수 확인
nix-store --gc --print-dead | wc -l

# 안전한 가비지 컬렉션 (dry-run)
nix-collect-garbage --dry-run | head -5
```

## 핵심 정리

### Nix 시스템 아키텍처

```text
사용자 요청 → Derivation 생성 → 의존성 해결 → 캐시 확인 → 빌드/다운로드 → Store 저장 → 환경 활성화
```

### 핵심 명령어

```bash
# Derivation 관리
nix show-derivation expr         # Derivation 구조 확인
nix-instantiate expr             # .drv 파일 생성

# Store 관리
nix-store --query --references   # 의존성 확인
nix-store --gc                   # 가비지 컬렉션
nix path-info --size             # 크기 정보

# 재현성
nix-shell --pure                 # 순수 환경
nix-build --check               # 재빌드 검증
```

### 시스템 이해 핵심

- **불변성**: Store 경로는 절대 변경되지 않음
- **격리**: 각 패키지는 명시적 의존성만 참조
- **재현성**: 같은 입력 → 같은 해시 → 같은 결과
- **효율성**: 바이너리 캐시로 빌드 시간 단축

**다음**: [Chapter 3: Version Control with Git](../ch03-git/ch03-0-introduction-to-version-control.md)
