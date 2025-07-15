# 5. Nix 설치 및 기본 소개

> 함수형 프로그래밍과 속성 집합을 이해했으니, 실제 Nix를 설치하고 첫 번째 코드를 작성해봅시다.

## 5.1 Nix 설치하기

### 🖥️ 지원 운영체제

**✅ 공식 지원:**

- Linux (모든 주요 배포판)
- macOS (Intel, Apple Silicon)
- WSL2 (Windows Subsystem for Linux)

**⚠️ 실험적 지원:**

- Windows (직접 설치, 아직 불안정)
  - Windows 사용자의 경우 WSL (Windows Subsystem for Linux) 에 nix 를 설치하세요
  - 또는 Docker 를 사용할 수 있습니다.

### 🚀 단일 명령어 설치

**가장 간단한 방법:**

```bash
# Linux/macOS에서 공식 설치 스크립트
curl -L https://nixos.org/nix/install | sh

# 멀티 유저 설치 (권장)
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```nix

- 세부 설치 과정은 다음 링크를 참고하세요.
  - [Nix installation](https://nixos.org/download/#nix-install-windows)

**설치 과정 설명:**

```bash
# 설치 스크립트가 하는 일:
# 1. /nix 디렉토리 생성
# 2. nix 사용자 그룹 및 계정 생성
# 3. Nix 바이너리 다운로드 및 설치
# 4. 환경 변수 설정 스크립트 추가
```nix

### 🔧 설치 후 환경 설정

```bash
# 설치 완료 후 환경 변수 로드
source ~/.nix-profile/etc/profile.d/nix.sh

# 또는 새 터미널 세션 시작
exit
# 새 터미널 열기
```nix

**설치 확인:**

```bash
# Nix 버전 확인
$ nix --version
nix (Nix) 2.18.1

# 간단한 테스트
$ nix-shell -p hello --run hello
Hello, world!

# 성공! 🎉
```nix

## 5.2 첫 번째 Nix 명령어들

### 🎯 즉시 사용해보기

**임시 환경에서 프로그램 실행:**

- Nix 는 Nix Shell 이라는 임시 환경을 제공합니다.
- Nix shell 은 프로그래머가 선언한 패키지들을 nixpkgs 로부터 가져와 격리된 임시 shell 을 만듭니다.
- 자세한 내용은 심화편에서 알아보도록 합시다.

```bash
# Hello 프로그램 실행 (설치하지 않고)
$ nix-shell -p hello --run hello
Hello, world!

# Python 임시 사용
$ nix-shell -p python3 --run "python3 --version"
Python 3.11.6

# 여러 프로그램 동시에
$ nix-shell -p python3 nodejs git
[nix-shell]$ python3 --version
Python 3.11.6
[nix-shell]$ node --version
v18.17.0
[nix-shell]$ git --version
git version 2.42.0
[nix-shell]$ exit  # 나가면 모든 프로그램 사라짐
```nix

**패키지 검색:**

```bash
# 패키지 검색
$ nix search nixpkgs python
python3                 A high-level dynamically-typed programming language
python38                Python 3.8.x
python39                Python 3.9.x
python310               Python 3.10.x
python311               Python 3.11.x

# 특정 도구 검색
$ nix search nixpkgs neovim
neovim                  Vim text editor fork focused on extensibility
```nix

### 💻 Nix REPL 사용하기

- REPL 은 Read-Eval-Print-Loop 의 약자로, 작성한 코드를 evaluation (평가) 할 수 있는 인터프리터를 의미합니다.

**대화형 Nix 인터프리터:**

```bash
$ nix repl
Welcome to Nix 2.18.1. Type :? for help.

nix-repl>
```nix

**기본 계산:**

```nix
nix-repl> 1 + 2
3

nix-repl> "Hello, " + "Nix!"
"Hello, Nix!"

nix-repl> [ 1 2 3 4 5 ]
[ 1 2 3 4 5 ]
```nix

**속성 집합 만들기:**

```nix
nix-repl> { name = "Alice"; age = 30; }
{ age = 30; name = "Alice"; }

nix-repl> config = { server = { port = 8080; host = "localhost"; }; }
nix-repl> config.server.port
8080

nix-repl> config.server
{ host = "localhost"; port = 8080; }
```nix

## 5.3 Nix 언어 기본 문법

### 🔤 기본 데이터 타입

**문자열:**

```nix
nix-repl> "단순 문자열"
"단순 문자열"

nix-repl> ''
  여러 줄
  문자열도 가능
  들여쓰기 자동 정리
''
"여러 줄\n문자열도 가능\n들여쓰기 자동 정리"

# 문자열 보간 - 문자열 안에 변수를 가져올 수 있음.
nix-repl> name = "World"
nix-repl> "Hello, ${name}!"
"Hello, World!"

nix-repl> version = 42
nix-repl> "Version ${toString version}"
"Version 42"
```nix

**숫자와 불린:**

```nix
nix-repl> 42
42

nix-repl> 3.14
3.14

nix-repl> true
true

nix-repl> false
false

nix-repl> null
null
```nix

**리스트:**

```nix
nix-repl> [ 1 2 3 ]
[ 1 2 3 ]

nix-repl> [ "apple" "banana" "cherry" ]
[ "apple" "banana" "cherry" ]

# 혼합 타입 가능
nix-repl> [ 1 "hello" true { name = "config"; } ]
[ 1 "hello" true { name = "config"; } ]

# 리스트 연결
nix-repl> [ 1 2 ] ++ [ 3 4 ]
[ 1 2 3 4 ]
```nix

**속성 집합:**

```nix
nix-repl> { name = "John"; age = 25; active = true; }
{ active = true; age = 25; name = "John"; }

# 중첩 가능
nix-repl> {
  user = {
    name = "Alice";
    preferences = {
      theme = "dark";
      language = "en";
    };
  };
}
{ user = { name = "Alice"; preferences = { language = "en"; theme = "dark"; }; }; }

# 속성 접근
nix-repl> config = { server = { port = 8080; }; }
nix-repl> config.server.port
8080
```nix

### ⚡ 함수 정의와 호출

**간단한 함수:**

```nix
# 하나의 인자를 받는 함수
nix-repl> double = x: x * 2
nix-repl> double 5
10

# 두 개의 인자 (커링)
nix-repl> add = x: y: x + y
nix-repl> add 3 4
7

# 부분 적용
nix-repl> add5 = add 5
nix-repl> add5 3
8
```nix

**속성 집합을 인자로 받는 함수:**

```nix
nix-repl> greet = { name, age ? 25 }: "Hello, ${name}! You are ${toString age}."
nix-repl> greet { name = "Alice"; }
"Hello, Alice! You are 25."

nix-repl> greet { name = "Bob"; age = 30; }
"Hello, Bob! You are 30."

# 필수 인자가 없으면 에러
nix-repl> greet { age = 30; }
error: function called without required argument 'name'
```nix

### 🔧 let과 with 표현식

**let으로 변수 정의:**

```nix
nix-repl> let
  x = 10;
  y = 20;
in x + y
30

nix-repl> let
  name = "Nix";
  version = "2.18";
  greeting = "Welcome to ${name} ${version}!";
in greeting
"Welcome to Nix 2.18!"
```nix

**with로 속성 접근 간소화:**

```nix
nix-repl> config = {
  database = { host = "localhost"; port = 5432; };
  cache = { host = "redis"; port = 6379; };
}

# with 없이
nix-repl> "${config.database.host}:${toString config.database.port}"
"localhost:5432"

# with 사용
nix-repl> with config.database; "${host}:${toString port}"
"localhost:5432"
```nix

### 🎯 조건문과 패턴 매칭

**if-then-else:**

```nix
nix-repl> env = "development"
nix-repl> if env == "production" then "prod.db" else "dev.db"
"dev.db"

nix-repl> port = 443
nix-repl> {
  ssl = if port == 443 then true else false;
  protocol = if port == 443 then "https" else "http";
}
{ protocol = "https"; ssl = true; }
```nix

**패턴 매칭 (속성 집합):**

```nix
nix-repl> processUser = { name, isAdmin ? false, ... }:
  if isAdmin
  then "Admin: ${name}"
  else "User: ${name}"

nix-repl> processUser { name = "Alice"; isAdmin = true; }
"Admin: Alice"

nix-repl> processUser { name = "Bob"; }
"User: Bob"

nix-repl> processUser { name = "Charlie"; extra = "ignored"; }
"User: Charlie"
```nix

## 5.4 실용적인 첫 번째 예제

### 📦 간단한 패키지 정의

**hello.nix 파일 만들기:**

```nix
# hello.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellScriptBin "my-hello" ''
  echo "Hello from my custom Nix package!"
  echo "Current time: $(date)"
  echo "Nix store path: $out"
''
```nix

**빌드하고 실행:**

```bash
# 패키지 빌드
$ nix-build hello.nix
/nix/store/...-my-hello

# 실행
$ ./result/bin/my-hello
Hello from my custom Nix package!
Current time: Mon Oct 23 14:30:15 UTC 2023
Nix store path: /nix/store/...-my-hello

# 직접 실행
$ nix-shell hello.nix --run my-hello
```nix

### 🔧 설정 파일 생성 예제

**config-generator.nix:**

```nix
# config-generator.nix
{ environment ? "development" }:

let
  # 환경별 설정
  configs = {
    development = {
      database = {
        host = "localhost";
        port = 5432;
        name = "myapp_dev";
        ssl = false;
      };
      debug = true;
      logLevel = "debug";
    };

    production = {
      database = {
        host = "prod-db.company.com";
        port = 5432;
        name = "myapp_prod";
        ssl = true;
      };
      debug = false;
      logLevel = "info";
    };
  };

  # 선택된 환경의 설정
  config = configs.${environment};

  # JSON으로 변환하는 함수
  toJSON = builtins.toJSON;

in {
  # 설정 객체
  inherit config;

  # JSON 문자열
  configJSON = toJSON config;

  # 환경 변수 형태
  envVars = with config.database; [
    "DB_HOST=${host}"
    "DB_PORT=${toString port}"
    "DB_NAME=${name}"
    "DB_SSL=${if ssl then "true" else "false"}"
    "DEBUG=${if config.debug then "true" else "false"}"
    "LOG_LEVEL=${config.logLevel}"
  ];
}
```nix

**사용법:**

```bash
# 개발 환경 설정 생성
$ nix eval -f config-generator.nix configJSON
"{\"database\":{\"host\":\"localhost\",\"name\":\"myapp_dev\",\"port\":5432,\"ssl\":false},\"debug\":true,\"logLevel\":\"debug\"}"

# 프로덕션 환경 설정
$ nix eval -f config-generator.nix --arg environment '"production"' configJSON

# 환경 변수 목록 출력
$ nix eval -f config-generator.nix envVars
[ "DB_HOST=localhost" "DB_PORT=5432" "DB_NAME=myapp_dev" "DB_SSL=false" "DEBUG=true" "LOG_LEVEL=debug" ]
```nix

### 🎨 개발 환경 미리보기

**simple-shell.nix:**

```nix
# simple-shell.nix - 7장에서 자세히 다룰 예정
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "my-dev-environment";

  buildInputs = with pkgs; [
    # 기본 개발 도구
    git
    curl
    jq

    # Python 환경
    python3
    python3Packages.pip
    python3Packages.virtualenv

    # Node.js 환경
    nodejs
    nodePackages.npm
  ];

  shellHook = ''
    echo "🚀 개발 환경에 오신 것을 환영합니다!"
    echo ""
    echo "사용 가능한 도구들:"
    echo "  Python: $(python3 --version)"
    echo "  Node.js: $(node --version)"
    echo "  Git: $(git --version)"
    echo ""
    echo "💡 'exit'를 입력하면 환경을 종료합니다."
  '';
}
```nix

**실행:**

```bash
$ nix-shell simple-shell.nix
🚀 개발 환경에 오신 것을 환영합니다!

사용 가능한 도구들:
  Python: Python 3.11.6
  Node.js: v18.17.0
  Git: git version 2.42.0

💡 'exit'를 입력하면 환경을 종료합니다.

[nix-shell]$ python3 -c "print('Hello from Nix!')"
Hello from Nix!

[nix-shell]$ exit
```nix

## 5.5 Nix 명령어 치트시트

### 📚 자주 사용하는 명령어들

```bash
# === 패키지 관리 ===
nix-shell -p PACKAGE              # 임시로 패키지 사용
nix-shell -p python3 nodejs       # 여러 패키지 동시에
nix search nixpkgs KEYWORD        # 패키지 검색

# === 빌드와 실행 ===
nix-build FILE.nix                # Nix 표현식 빌드
nix-shell FILE.nix                # 개발 환경 진입
nix eval -f FILE.nix               # 표현식 평가

# === REPL과 학습 ===
nix repl                          # 대화형 인터프리터
nix repl '<nixpkgs>'              # nixpkgs와 함께 시작

# === 정보 조회 ===
nix --version                     # Nix 버전 확인
nix-env --query                   # 설치된 패키지 목록
nix-store --query --references    # 의존성 조회

# === 정리 ===
nix-collect-garbage               # 사용하지 않는 패키지 정리
nix-collect-garbage -d            # 모든 이전 버전 삭제
```nix

### 🔧 유용한 옵션들

```bash
# JSON 출력
nix eval -f config.nix --json

# 여러 줄 문자열을 파일로 출력
nix eval -f config.nix configFile --raw > output.conf

# 특정 인자와 함께 평가
nix eval -f config.nix --arg debug true

# 문자열 인자 전달
nix eval -f config.nix --argstr environment "production"
```nix

## 5.6 다음 단계 준비

### ✅ 지금까지 배운 것들

- [x] Nix 설치와 기본 설정
- [x] 기본 데이터 타입과 문법
- [x] 함수 정의와 호출
- [x] let, with 표현식
- [x] 간단한 패키지와 설정 파일 작성

### 🎯 다음에 배울 내용 (6장)

**Nix의 핵심 개념들:**

- **파생(Derivations)**: 빌드 과정의 함수형 표현
- **Nix Store**: `/nix/store`의 구조와 동작 원리
- **해시와 캐싱**: 어떻게 재현성을 보장하는가
- **가비지 컬렉션**: 자동 정리 메커니즘

### 🛠️ 그 후에 배울 내용 (7장)

**실용적 환경 구성:**

- 완전한 `shell.nix` 작성법
- 프로젝트별 개발 환경 관리
- direnv와 연동한 자동 환경 활성화
- 팀 협업을 위한 환경 표준화

---

## 🎓 섹션 5 요약

**🚀 성취한 것들:**

- Nix 설치 완료 ✅
- 기본 문법 이해 ✅
- 첫 번째 Nix 코드 작성 ✅
- 실용적인 예제 실행 ✅

**🔑 핵심 깨달음:**

- Nix는 설치와 동시에 바로 사용 가능
- 함수형 언어지만 직관적인 문법
- 설정 관리가 프로그래밍이 됨
- 임시 환경부터 영구 설정까지 가능

**💡 다음 단계:**
이제 Nix가 **어떻게** 동작하는지 알아봅시다. 파생과 Nix Store의 마법을 파헤쳐보겠습니다! 🧙‍♂️

---

설치부터 첫 번째 코드까지, Nix의 첫 맛을 보셨나요? 생각보다 친근하지 않나요? 🎯
