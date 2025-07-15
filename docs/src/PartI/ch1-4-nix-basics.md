# 5. Nix 기초 문법과 실습

## 5.1 Nix 설치

### 설치 과정

```bash
# Linux/macOS 공식 설치
curl -L https://nixos.org/nix/install | sh

# 환경 변수 로드
source ~/.nix-profile/etc/profile.d/nix.sh
```

### 설치 확인

```bash
$ nix --version
nix (Nix) 2.18.1

# 목적: 설치 검증
# 핵심 개념: 임시 패키지 실행
$ nix-shell -p hello --run hello
Hello, world!
```

## 5.2 기본 데이터 타입

### 원시 타입

```nix
# 목적: Nix 기본 데이터 타입 이해
# 핵심 개념: 타입 시스템, 리터럴

# 문자열
"hello world"
''
  다중 줄
  문자열
''

# 숫자와 불린
42
3.14
true
false
null

# 문자열 보간
let name = "nix";
in "Hello ${name}"  # "Hello nix"
```

### 리스트

```nix
# 목적: 리스트 조작 이해
# 핵심 개념: 불변성, 연결 연산

# 기본 리스트 (공백으로 구분)
["python" "nodejs" "go"]

# 리스트 연결
["git"] ++ ["vim" "curl"]  # ["git" "vim" "curl"]

# 혼합 타입 허용
[1 "hello" true { version = "1.0"; }]
```

### 속성집합

```nix
# 목적: 속성집합 구조와 접근 방법
# 핵심 개념: 중첩 구조, 속성 접근

# 기본 속성집합
{
  name = "myproject";
  version = "1.0";
  dependencies = ["lib1" "lib2"];
}

# 중첩 속성집합
{
  project = {
    name = "webapp";
    language = "python";
  };
  environment = {
    packages = ["flask" "gunicorn"];
  };
}

# 속성 접근
let config = { project = { name = "test"; }; };
in config.project.name  # "test"
```

## 5.3 함수 정의와 호출

### 기본 함수

```nix
# 목적: 함수 정의와 호출 패턴 이해
# 핵심 개념: 커링, 부분 적용

# 단일 인자 함수
double = x: x * 2;
double 5  # 10

# 다중 인자 함수 (커링)
add = x: y: x + y;
add 3 4  # 7

# 부분 적용
add5 = add 5;
add5 10  # 15
```

### 속성집합 패턴 매칭

```nix
# 목적: 구조화된 인자 처리
# 핵심 개념: 패턴 매칭, 기본값

# 기본값과 패턴 매칭
buildConfig = { name, version ? "1.0", debug ? false }:
  {
    inherit name version debug;
    buildType = if debug then "development" else "production";
  };

# 사용 예시
buildConfig { name = "myapp"; debug = true; }
# { name = "myapp"; version = "1.0"; debug = true; buildType = "development"; }
```

## 5.4 let과 with 표현식

### let 표현식

```nix
# 목적: 지역 변수와 함수 정의
# 핵심 개념: 스코프, 변수 바인딩
let
  version = "3.8";
  packages = ["requests" "flask"];

  mkEnv = packages: {
    python = version;
    dependencies = packages;
  };

in mkEnv packages
```

### with 표현식

```nix
# 목적: 속성집합의 스코프 확장
# 핵심 개념: 네임스페이스 플래튼
let
  config = {
    host = "localhost";
    port = 8080;
    ssl = false;
  };

in {
  # with 사용으로 간결한 참조
  url = with config; "${host}:${toString port}";
  secure = with config; ssl;
}
```

## 5.5 조건문과 연산

### if-then-else

```nix
# 목적: 조건부 로직 구현
# 핵심 개념: 삼항 연산, 조건부 설정
let
  environment = "production";
  useSSL = true;

in {
  debug = if environment == "development" then true else false;
  protocol = if useSSL then "https" else "http";

  resources = if environment == "production"
    then { memory = "4GB"; cpu = 4; }
    else { memory = "1GB"; cpu = 1; };
}
```

### 리스트와 속성집합 연산

```nix
# 목적: 데이터 구조 조작 패턴
# 핵심 개념: 병합, 확장, 조건부 추가
let
  basePackages = ["git" "curl"];
  devPackages = ["vim" "tmux"];

  baseConfig = { timeout = 30; retries = 3; };
  prodConfig = { ssl = true; cache = true; };

in {
  # 리스트 병합
  allPackages = basePackages ++ devPackages;

  # 속성집합 병합
  config = baseConfig // prodConfig;

  # 조건부 확장
  packages = basePackages ++ (if true then devPackages else []);
}
```

## 5.6 실습: 개발 환경 구성

### 기본 개발 환경

```nix
# 목적: 간단한 개발 환경 정의
# 핵심 개념: mkShell, buildInputs, shellHook
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "dev-environment";

  buildInputs = with pkgs; [
    python3
    nodejs
    git
    curl
  ];

  shellHook = ''
    echo "개발 환경 준비 완료"
    echo "Python: $(python --version)"
    echo "Node: $(node --version)"
  '';
}
```

### 프로젝트별 환경

```nix
# 목적: 매개변수화된 환경 생성
# 핵심 개념: 함수, 재사용성, 모듈화
{ pkgs ? import <nixpkgs> {} }:

let
  mkDevEnv = { name, language, packages ? [] }:
    pkgs.mkShell {
      inherit name;
      buildInputs = with pkgs; [
        git
        (if language == "python" then python3 else nodejs)
      ] ++ packages;

      shellHook = ''
        echo "${name} 환경"
        echo "언어: ${language}"
      '';
    };

in {
  python-env = mkDevEnv {
    name = "python-dev";
    language = "python";
    packages = with pkgs; [ python3Packages.requests ];
  };

  web-env = mkDevEnv {
    name = "web-dev";
    language = "node";
    packages = with pkgs; [ yarn ];
  };
}
```

## 5.7 기본 명령어

### 환경 관리

```bash
# 임시 패키지 사용
nix-shell -p python3 nodejs

# 환경 파일 실행
nix-shell myenv.nix

# 특정 속성 선택
nix-shell myenvs.nix -A python-env

# 명령 실행 후 종료
nix-shell -p git --run "git --version"
```

### 정보 조회

```bash
# 패키지 검색
nix search nixpkgs python

# 표현식 평가
nix eval -f config.nix

# JSON 출력
nix eval -f config.nix --json
```

## 5.8 실제 사용 예제

### 설정 파일 작성

```nix
# 목적: 실무 환경 설정 예제
# 핵심 개념: 실제 도구 조합
{ pkgs ? import <nixpkgs> {} }:

let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    requests
    flask
    pytest
  ]);

in pkgs.mkShell {
  buildInputs = [
    pythonEnv
    pkgs.postgresql
    pkgs.redis
  ];

  shellHook = ''
    export DATABASE_URL="postgresql://localhost/myapp"
    export REDIS_URL="redis://localhost:6379"
    echo "웹 개발 환경 준비 완료"
  '';
}
```

### 테스트 실행

```bash
# 환경 활성화
$ nix-shell

# Python 확인
[nix-shell]$ python -c "import requests; print('패키지 로드 성공')"

# 데이터베이스 서비스 시작
[nix-shell]$ pg_ctl -D /tmp/postgres init
[nix-shell]$ pg_ctl -D /tmp/postgres start
```

---

**요약**: Nix 언어는 함수형 프로그래밍 개념을 기반으로 한 설정 정의 언어입니다. 기본 타입, 함수, 조건문을 조합하여 복잡한 개발 환경을 선언적으로 정의할 수 있습니다.
