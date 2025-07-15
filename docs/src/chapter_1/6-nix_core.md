# 6. Nix 핵심 개념들

> _"모든 마법에는 원리가 있다."_
>
> Nix가 어떻게 완벽한 재현성을 보장하고, 의존성 충돌을 해결하며, 안전한 롤백을 가능하게 하는지 알아봅시다.

## 6.1 파생(Derivations): 빌드의 함수형 표현

### 🧮 파생이란?

**파생(Derivation)**은 Nix에서 빌드 과정을 나타내는 함수형 표현입니다.

```nix
📦 파생 = 순수 함수 (입력 → 출력)
```nix

**수학적 관점:**

```nix
derivation(inputs) = output
```nix

- **입력**: 소스 코드, 의존성, 빌드 스크립트, 환경 변수
- **출력**: 빌드된 패키지 (항상 동일한 경로)
- **순수성**: 같은 입력 → 항상 같은 출력

### 🔍 파생 들여다보기

**간단한 파생 예제:**

```nix
# hello-derivation.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "my-hello";
  version = "1.0.0";

  src = pkgs.writeText "hello.c" ''
    #include <stdio.h>
    int main() {
        printf("Hello from my custom derivation!\n");
        return 0;
    }
  '';

  buildPhase = ''
    gcc $src -o hello
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp hello $out/bin/
  '';
}
```nix

**파생 검사하기:**

```bash
# 파생 정보 확인 (빌드하지 않고)
$ nix show-derivation -f hello-derivation.nix
{
  "/nix/store/abc123...my-hello-1.0.0.drv": {
    "outputs": {
      "out": {
        "path": "/nix/store/def456...my-hello-1.0.0"
      }
    },
    "inputSrcs": [
      "/nix/store/ghi789...hello.c"
    ],
    "inputDrvs": {
      "/nix/store/jkl012...stdenv-linux.drv": ["out"],
      "/nix/store/mno345...gcc-12.2.0.drv": ["out"]
    },
    "platform": "x86_64-linux",
    "builder": "/nix/store/.../bash",
    "args": ["-e", "/nix/store/.../builder.sh"],
    "env": {
      "buildPhase": "gcc $src -o hello",
      "installPhase": "mkdir -p $out/bin\ncp hello $out/bin/",
      "name": "my-hello-1.0.0",
      "src": "/nix/store/ghi789...hello.c"
    }
  }
}
```nix

### 🎯 파생의 핵심 특성

**1. 결정론적 해싱:**

```bash
# 같은 입력 → 같은 해시 → 같은 경로
$ nix-build hello-derivation.nix
/nix/store/def456abc789...my-hello-1.0.0

# 한 글자라도 바뀌면 완전히 다른 해시
$ sed 's/Hello/Hi/' hello-derivation.nix > hello-modified.nix
$ nix-build hello-modified.nix
/nix/store/xyz987fed321...my-hello-1.0.0  # 다른 경로!
```nix

**2. 격리된 빌드 환경:**

```bash
# 빌드 과정에서 시스템과 완전히 격리됨
# - 네트워크 접근 차단 (샌드박스)
# - 시스템 경로 접근 불가 (/usr, /opt 등)
# - 시간 고정 (1970-01-01 00:00:00 UTC)
# - 환경 변수 제한

# 빌드 로그 확인
$ nix-build hello-derivation.nix -v
building '/nix/store/abc123...my-hello-1.0.0.drv'...
unpacking sources
unpacking source archive /nix/store/ghi789...hello.c
source root is hello.c
running: gcc /nix/store/ghi789...hello.c -o hello
installation
mkdir -p /tmp/nix-build-my-hello-1.0.0.drv-0/out/bin
cp hello /tmp/nix-build-my-hello-1.0.0.drv-0/out/bin/
/nix/store/def456...my-hello-1.0.0
```nix

**3. 암시적 의존성 자동 탐지:**

```nix
# 이 파생이 의존하는 모든 것들을 자동으로 파악
$ nix-store --query --references /nix/store/def456...my-hello-1.0.0
/nix/store/abc123...glibc-2.37
/nix/store/def456...my-hello-1.0.0

# 의존성 트리 전체 출력
$ nix-store --query --tree /nix/store/def456...my-hello-1.0.0
/nix/store/def456...my-hello-1.0.0
├───/nix/store/abc123...glibc-2.37
│   ├───/nix/store/ghi789...linux-headers-6.3
│   └───/nix/store/jkl012...tzdata-2023c
└───/nix/store/mno345...gcc-12.2.0-lib
    └───/nix/store/pqr678...libgcc-12.2.0
```nix

## 6.2 Nix Store: 모든 것의 저장소

### 🏪 Nix Store 구조

**`/nix/store`의 구조:**

```nix
/nix/store/
├── 0123456789abcdef-package-name-version/
├── 1a2b3c4d5e6f7890-another-package-1.2.3/
├── deadbeef12345678-hello-world-1.0.0/
└── cafebabe87654321-python3-3.11.6/
    ├── bin/
    │   ├── python3 -> python3.11
    │   └── python3.11*
    ├── lib/
    │   └── python3.11/
    └── share/
        └── man/
```nix

**경로 구성 요소:**

```nix
/nix/store/[해시]-[이름]-[버전]/
           ↓      ↓     ↓
         32자리  패키지명 버전정보
         해시값   (pname) (version)
```nix

### 🔐 해시 기반 주소 지정

**해시 계산 과정:**

```bash
# 해시는 다음 모든 정보로부터 계산됨:
# 1. 모든 입력 파일의 내용
# 2. 모든 의존성의 경로
# 3. 빌드 스크립트
# 4. 환경 변수
# 5. 플랫폼 정보

# 해시 계산 과정 시뮬레이션
$ echo "inputs + dependencies + build script + env vars" | sha256sum
a1b2c3d4e5f6789... (실제로는 더 복잡한 계산)
```nix

**콘텐츠 주소 지정 (Content Addressing):**

```bash
# 같은 내용 → 같은 해시 → 같은 경로
$ nix-build -E 'with import <nixpkgs> {}; writeText "test" "hello"'
/nix/store/abc123...test

$ nix-build -E 'with import <nixpkgs> {}; writeText "test" "hello"'
/nix/store/abc123...test  # 동일한 경로! (캐시 활용)

# 다른 내용 → 다른 해시 → 다른 경로
$ nix-build -E 'with import <nixpkgs> {}; writeText "test" "world"'
/nix/store/def456...test  # 다른 경로
```nix

### 🔄 참조와 클로저

**참조 관계:**

```bash
# Python이 참조하는 것들
$ nix-store --query --references $(which python3)
/nix/store/abc123...glibc-2.37
/nix/store/def456...openssl-3.0.9
/nix/store/ghi789...zlib-1.2.13
/nix/store/jkl012...python3-3.11.6

# Python을 참조하는 것들 (역참조)
$ nix-store --query --referrers $(which python3)
/nix/store/mno345...python3-numpy-1.24.3
/nix/store/pqr678...python3-django-4.2.1
/nix/store/stu901...my-python-project
```nix

**클로저 (Closure):**

```bash
# 클로저 = 패키지 + 모든 의존성 (재귀적)
$ nix-store --query --requisites $(which python3)
/nix/store/abc123...glibc-2.37
/nix/store/def456...openssl-3.0.9
/nix/store/ghi789...zlib-1.2.13
/nix/store/jkl012...linux-headers-6.3
/nix/store/mno345...tzdata-2023c
/nix/store/pqr678...ca-certificates-2023.01.10
/nix/store/stu901...python3-3.11.6

# 클로저 크기 확인
$ nix path-info -S $(which python3)
/nix/store/stu901...python3-3.11.6    156789123

# 클로저를 다른 시스템으로 복사
$ nix copy --to ssh://user@server $(which python3)
# python3과 모든 의존성이 함께 복사됨
```nix

## 6.3 캐싱과 바이너리 대체

### 🚀 바이너리 캐시

**Nix의 캐싱 전략:**

```nix
개발자 컴퓨터               바이너리 캐시               소스에서 빌드
      ↓                       ↓                        ↓
1. 해시 계산              2. 해시로 검색            3. 로컬 빌드
   abc123...                 cache.nixos.org            (최후 수단)
                            /abc123... 존재?
                                 ↓
                            4. 다운로드 & 설치
```nix

**실제 동작 확인:**

```bash
# 새로운 패키지 설치 (캐시에서 다운로드)
$ nix-shell -p cowsay
downloading 'https://cache.nixos.org/abc123...cowsay-3.04.drv'
downloading 'https://cache.nixos.org/def456...cowsay-3.04'
copying path '/nix/store/def456...cowsay-3.04' from 'https://cache.nixos.org'...

# 이미 있는 패키지 (즉시 사용)
$ nix-shell -p cowsay
[nix-shell]$ # 다운로드 없이 즉시 시작

# 캐시 설정 확인
$ nix show-config | grep substituters
substituters = https://cache.nixos.org https://nix-community.cachix.org
```nix

**개인 캐시 서버 설정:**

```nix
# ~/.config/nix/nix.conf
substituters = https://cache.nixos.org https://my-company.cache.nix
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= my-company:abc123...
```nix

### 🔒 서명과 신뢰성

**서명 검증 과정:**

```bash
# 바이너리 캐시의 서명 확인
$ nix-store --verify-path /nix/store/abc123...hello
checking path '/nix/store/abc123...hello'...
path '/nix/store/abc123...hello' is valid and has correct signature

# 무결성 검사
$ nix-store --verify --check-contents
checking path '/nix/store/abc123...hello'...
checking path '/nix/store/def456...glibc-2.37'...
...all paths verified successfully

# 손상된 파일 복구
$ nix-store --repair-path /nix/store/abc123...hello
```nix

## 6.4 프로파일과 세대 관리

### 👤 사용자 프로파일

**프로파일 구조:**

```nix
~/.nix-profile -> /nix/var/nix/profiles/per-user/username/profile
                     ↓
              profile -> profile-15-link
                        ↓
              /nix/store/abc123...user-environment/
              ├── bin/           # 설치된 프로그램들
              ├── share/         # 문서, 아이콘 등
              └── manifest.json  # 설치된 패키지 목록
```nix

**세대(Generation) 시스템:**

```bash
# 현재 설치된 패키지들
$ nix-env --query
git-2.41.0
vim-9.0.1562
python3-3.11.6

# 새 패키지 설치 (새 세대 생성)
$ nix-env --install nodejs
installing 'nodejs-18.17.0'
building '/nix/store/...user-environment.drv'...

# 세대 목록 확인
$ nix-env --list-generations
   1   2023-06-01 10:30:00
   2   2023-06-15 14:20:00
   3   2023-07-01 09:15:00   (current)

# 이전 세대로 롤백
$ nix-env --rollback
switching from generation 3 to 2

$ nix-env --query
git-2.41.0
vim-9.0.1562
python3-3.11.6
# nodejs가 사라짐!

# 특정 세대로 전환
$ nix-env --switch-generation 3
switching from generation 2 to 3

$ nix-env --query
git-2.41.0
vim-9.0.1562
python3-3.11.6
nodejs-18.17.0
# nodejs가 다시 나타남!
```nix

### 🔄 원자적 업데이트

**원자성의 의미:**

```bash
# 업데이트 과정
1. 새로운 환경 구성 (/nix/store에 별도 생성)
2. 모든 패키지가 성공적으로 준비되면
3. 심볼릭 링크 하나만 변경
4. 실패하면 원래 환경 그대로 유지

# 예시: 대규모 업데이트
$ nix-env --upgrade '*'
upgrading packages...
building new user environment...
installing 'python3-3.11.7'
installing 'git-2.42.0'
installing 'vim-9.0.1750'
...
creating generation 4
# 모든 것이 성공한 후에만 활성화
```nix

**실패 시나리오:**

```bash
# 디스크 공간 부족으로 실패
$ nix-env --install huge-package
building '/nix/store/...user-environment.drv'...
error: not enough free disk space to build derivation

# 원래 환경은 그대로 유지됨
$ nix-env --query
git-2.41.0    # 변경 없음
vim-9.0.1562  # 변경 없음
python3-3.11.6  # 변경 없음
```nix

## 6.5 가비지 컬렉션

### 🗑️ 자동 정리 시스템

**가비지 컬렉션의 원리:**

```nix
1. 루트(Roots) 찾기
   ├── 사용자 프로파일들
   ├── 시스템 프로파일
   └── 명시적 GC 루트들

2. 참조 추적 (Mark)
   └── 루트에서 도달 가능한 모든 경로 마킹

3. 정리 (Sweep)
   └── 마킹되지 않은 경로들 삭제
```nix

**가비지 컬렉션 실행:**

```bash
# 현재 스토어 크기 확인
$ du -sh /nix/store
15G    /nix/store

# 죽은 경로들 확인 (삭제 가능한 것들)
$ nix-store --gc --print-dead | head -5
finding garbage collector roots...
/nix/store/abc123...old-version-1.0
/nix/store/def456...unused-package-2.0
/nix/store/ghi789...temporary-build-artifact
...would delete 156 paths (5.2G)

# 가비지 컬렉션 실행
$ nix-collect-garbage
finding garbage collector roots...
deleting '/nix/store/abc123...old-version-1.0'
deleting '/nix/store/def456...unused-package-2.0'
...
5.2G freed

# 새로운 크기 확인
$ du -sh /nix/store
9.8G    /nix/store
```nix

**세대 기반 정리:**

```bash
# 오래된 세대들 삭제
$ nix-collect-garbage --delete-older-than 30d
removing old generations of profile /nix/var/nix/profiles/per-user/username/profile
removing generation 1
removing generation 2
...

# 특정 세대 이전 모두 삭제
$ nix-env --delete-generations old
deleting generations: 1 2 3 4 5

# 최신 N개만 유지
$ nix-env --delete-generations +5
# 최신 5개 세대만 유지하고 나머지 삭제
```nix

### 🔒 GC 루트 관리

**루트 설정:**

```bash
# 특정 빌드 결과를 GC로부터 보호
$ nix-build my-important-project.nix
/nix/store/abc123...my-important-project

$ nix-store --add-root /nix/var/nix/gcroots/my-project --indirect /nix/store/abc123...my-important-project

# 이제 GC에서 삭제되지 않음
$ nix-collect-garbage
...
# my-important-project는 보존됨

# 루트 목록 확인
$ ls -la /nix/var/nix/gcroots/
auto/
my-project -> /nix/store/abc123...my-important-project
profiles/
```nix

## 6.6 실전 예제: 의존성 추적

### 🕵️ 의존성 디버깅

**복잡한 프로젝트의 의존성 분석:**

```bash
# 큰 프로젝트 빌드
$ nix-build '<nixpkgs>' -A firefox

# 의존성 트리 시각화
$ nix-store --query --tree $(nix-build '<nixpkgs>' -A firefox) | head -20
/nix/store/abc123...firefox-117.0
├───/nix/store/def456...glibc-2.37
│   ├───/nix/store/ghi789...linux-headers-6.3
│   └───/nix/store/jkl012...tzdata-2023c
├───/nix/store/mno345...gtk3-3.24.38
│   ├───/nix/store/pqr678...glib-2.76.4
│   │   ├───/nix/store/stu901...pcre2-10.42
│   │   └───/nix/store/vwx234...util-linux-2.39
│   └───/nix/store/yza567...cairo-1.16.0
...

# 크기별 의존성 분석
$ nix path-info -S $(nix-store --query --requisites $(nix-build '<nixpkgs>' -A firefox)) | sort -k2 -n | tail -10
/nix/store/abc123...fontconfig-2.14.2      12345678
/nix/store/def456...mesa-23.1.4           23456789
/nix/store/ghi789...gtk3-3.24.38          34567890
/nix/store/jkl012...glibc-2.37            45678901
/nix/store/mno345...firefox-117.0         156789012
```nix

**의존성 충돌 해결 과정:**

```bash
# 두 가지 버전의 같은 라이브러리가 필요한 경우
$ nix-shell -p python38 python38Packages.numpy python39 python39Packages.numpy

# 각각 다른 버전의 numpy를 사용
$ python3.8 -c "import numpy; print(numpy.__file__)"
/nix/store/abc123...python3.8-numpy-1.21.0/lib/python3.8/site-packages/numpy/__init__.py

$ python3.9 -c "import numpy; print(numpy.__file__)"
/nix/store/def456...python3.9-numpy-1.24.3/lib/python3.9/site-packages/numpy/__init__.py

# 완전히 다른 경로! 충돌 없음!
```nix

### 🔧 빌드 과정 들여다보기

**상세한 빌드 로그:**

```bash
# 빌드 과정 자세히 보기
$ nix-build hello-derivation.nix --show-trace -v
building '/nix/store/abc123...my-hello-1.0.0.drv'...
@nix { "action": "setPhase", "phase": "unpackPhase" }
unpacking sources
unpacking source archive /nix/store/def456...hello.c
source root is hello.c
@nix { "action": "setPhase", "phase": "patchPhase" }
patching sources
@nix { "action": "setPhase", "phase": "buildPhase" }
running: gcc /nix/store/def456...hello.c -o hello
@nix { "action": "setPhase", "phase": "installPhase" }
installation
mkdir -p /tmp/nix-build-my-hello-1.0.0.drv-0/out/bin
cp hello /tmp/nix-build-my-hello-1.0.0.drv-0/out/bin/
@nix { "action": "setPhase", "phase": "fixupPhase" }
shrinking RPATHs of ELF executables and libraries in /tmp/nix-build-my-hello-1.0.0.drv-0/out
stripping (with command strip and flags -S) in  /tmp/nix-build-my-hello-1.0.0.drv-0/out/bin
patching script interpreter paths in /tmp/nix-build-my-hello-1.0.0.drv-0/out
/nix/store/ghi789...my-hello-1.0.0
```nix

**빌드 환경 검사:**

```bash
# 빌드 시 사용된 환경 변수 확인
$ nix show-derivation -f hello-derivation.nix | jq '.[].env'
{
  "buildInputs": "",
  "buildPhase": "gcc $src -o hello",
  "builder": "/nix/store/abc123...bash-5.2-p15/bin/bash",
  "installPhase": "mkdir -p $out/bin\ncp hello $out/bin/",
  "name": "my-hello-1.0.0",
  "out": "/nix/store/def456...my-hello-1.0.0",
  "src": "/nix/store/ghi789...hello.c",
  "stdenv": "/nix/store/jkl012...stdenv-linux",
  "system": "x86_64-linux"
}
```nix

## 6.7 성능과 최적화

### ⚡ 병렬 빌드

**빌드 최적화 설정:**

```bash
# ~/.config/nix/nix.conf
max-jobs = 8              # 동시 빌드 작업 수
cores = 4                 # 각 빌드 작업의 코어 수
sandbox = true            # 샌드박스 활성화
keep-outputs = true       # 빌드 출력 유지
keep-derivations = true   # 파생 파일 유지

# 실시간 설정 확인
$ nix show-config | grep -E "(max-jobs|cores)"
cores = 4
max-jobs = 8
```nix

**빌드 속도 분석:**

```bash
# 빌드 시간 측정
$ time nix-build '<nixpkgs>' -A hello
real    0m15.234s
user    0m8.123s
sys     0m2.456s

# 캐시 적중률 확인
$ nix-build '<nixpkgs>' -A hello --option narinfo-cache-positive-ttl 0
# 캐시 무시하고 빌드 시간 비교
```nix

### 💾 스토리지 최적화

**중복 제거:**

```bash
# 하드링크를 통한 공간 절약 확인
$ ls -li /nix/store/*/bin/python3
1234567 -r-xr-xr-x 2 root root 15672 Jan  1  1970 /nix/store/abc123...python3-3.11.6/bin/python3
1234567 -r-xr-xr-x 2 root root 15672 Jan  1  1970 /nix/store/def456...python3-3.11.6/bin/python3.11
# 같은 inode 번호 = 하드링크로 공간 절약

# 스토어 최적화 실행
$ nix-store --optimise
hashing files in '/nix/store'...
...
2.3G freed by hard-linking identical files
```nix

---

## 🎓 섹션 6 요약

**🔑 핵심 개념들:**

1. **파생(Derivations)**

   - 빌드 과정의 순수 함수형 표현
   - 결정론적 해싱으로 재현성 보장
   - 샌드박스 환경에서 격리된 빌드

2. **Nix Store**

   - 해시 기반 주소 지정으로 충돌 방지
   - 참조 추적을 통한 의존성 관리
   - 바이너리 캐시로 빌드 시간 단축

3. **세대 관리**
   - 원자적 업데이트로 안전한 변경
   - 언제든 이전 상태로 롤백 가능
   - 세대별 가비지 컬렉션

**🧙‍♂️ "마법"의 정체:**

- **재현성**: 해시 기반 결정론적 빌드
- **격리**: 각 패키지가 독립적인 경로
- **안전성**: 원자적 업데이트와 롤백
- **효율성**: 캐싱과 하드링크 최적화

**🚀 다음 단계:**
이제 이론을 완전히 이해했으니, **실무에서 활용할 수 있는 도구들**을 만들어봅시다!

---

Nix의 "마법"이 실제로는 **탄탄한 컴퓨터 과학 원리**에 기반하고 있음을 이해하셨나요? 이제 7장에서 이 지식을 실무에 적용해봅시다! 🎯
