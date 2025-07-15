# 4. 속성 집합(Attribute Sets)과 설정 관리

> _"모든 설정은 결국 Key-Value 쌍으로 귀결된다."_
>
> JSON에서 시작해서 Nix까지, 설정 관리의 진화 과정을 따라가봅시다.

## 4.1 속성 집합이란?

### 🗂️ 기본 개념

**속성 집합(Attribute Set)**은 이름(Key)과 값(Value)의 쌍으로 이루어진 데이터 구조입니다.

```nix
📦 속성 집합 = { 이름: 값, 이름: 값, ... }
```nix

**다른 언어에서는:**

- JavaScript: `Object`
- Python: `Dictionary`
- Java: `HashMap`
- Go: `Map`
- YAML: `Mapping`
- JSON: `Object`

### 🎯 왜 중요한가?

**모든 설정은 결국 속성 집합입니다:**

```json
// 웹 서버 설정
{
  "port": 8080,
  "host": "localhost",
  "ssl": {
    "enabled": true,
    "cert": "/path/to/cert.pem"
  }
}
```nix

```yaml
# Docker Compose 설정
version: "3.8"
services:
  web:
    image: nginx
    ports:
      - "80:80"
    environment:
      DEBUG: false
```nix

```nix
# Nix 시스템 설정
{
  networking.hostName = "myserver";
  services.nginx.enable = true;
  services.nginx.virtualHosts."example.com" = {
    forceSSL = true;
    enableACME = true;
  };
}
```nix

## 4.2 JSON으로 시작하는 설정 관리

### 📋 실제 프로젝트 설정 예제

현실적인 웹 프로젝트의 설정을 JSON으로 표현해봅시다.

```json
{
  "name": "awesome-webapp",
  "version": "2.1.0",
  "description": "A modern web application",
  "environments": {
    "development": {
      "database": {
        "host": "localhost",
        "port": 5432,
        "name": "webapp_dev",
        "user": "dev_user",
        "ssl": false
      },
      "redis": {
        "host": "localhost",
        "port": 6379,
        "db": 0
      },
      "api": {
        "baseUrl": "http://localhost:3000",
        "timeout": 5000,
        "retries": 3
      },
      "features": {
        "debugging": true,
        "analytics": false,
        "beta_features": true
      }
    },
    "production": {
      "database": {
        "host": "prod-db.company.com",
        "port": 5432,
        "name": "webapp_prod",
        "user": "prod_user",
        "ssl": true,
        "pool": {
          "min": 2,
          "max": 20
        }
      },
      "redis": {
        "host": "prod-redis.company.com",
        "port": 6379,
        "db": 0,
        "cluster": true
      },
      "api": {
        "baseUrl": "https://api.company.com",
        "timeout": 10000,
        "retries": 5
      },
      "features": {
        "debugging": false,
        "analytics": true,
        "beta_features": false
      }
    }
  },
  "dependencies": {
    "runtime": [
      { "name": "node", "version": "18.17.0" },
      { "name": "postgresql", "version": "15.3" },
      { "name": "redis", "version": "7.0.11" }
    ],
    "development": [
      { "name": "jest", "version": "29.5.0" },
      { "name": "eslint", "version": "8.44.0" },
      { "name": "prettier", "version": "3.0.0" }
    ]
  }
}
```nix

### 🔍 JSON의 장점과 한계

**✅ 장점:**

- 모든 개발자에게 친숙함
- 언어 독립적
- 간단하고 명확한 구조
- 파싱 도구가 풍부함

**❌ 한계:**

- 주석 불가능 (설명을 넣을 수 없음)
- 중복 제거 어려움 (DRY 원칙 위반)
- 조건부 설정 불가능
- 계산된 값 표현 불가능
- 타입 검증 부족

## 4.3 jq로 JSON 데이터 조작하기

### ⚡ jq: JSON 처리의 함수형 도구

**jq**는 JSON을 다루는 명령줄 도구로, 함수형 프로그래밍 개념을 사용합니다.

```bash
# 위의 설정 파일을 config.json으로 저장했다고 가정
```nix

### 🔧 기본 데이터 접근

```bash
# 프로젝트 이름 추출
$ cat config.json | jq '.name'
"awesome-webapp"

# 개발 환경 데이터베이스 설정
$ cat config.json | jq '.environments.development.database'
{
  "host": "localhost",
  "port": 5432,
  "name": "webapp_dev",
  "user": "dev_user",
  "ssl": false
}

# 특정 값만 추출
$ cat config.json | jq '.environments.development.database.host'
"localhost"

# 배열 접근
$ cat config.json | jq '.dependencies.runtime[0]'
{
  "name": "node",
  "version": "18.17.0"
}
```nix

### 🔄 함수형 데이터 변환

**필터링과 매핑:**

```bash
# 런타임 의존성 이름만 추출
$ cat config.json | jq '.dependencies.runtime | map(.name)'
["node", "postgresql", "redis"]

# 버전 정보 포함한 간단한 형태
$ cat config.json | jq '.dependencies.runtime | map("\(.name):\(.version)")'
["node:18.17.0", "postgresql:15.3", "redis:7.0.11"]

# 특정 조건으로 필터링
$ cat config.json | jq '.dependencies.runtime | map(select(.name == "node"))'
[
  {
    "name": "node",
    "version": "18.17.0"
  }
]
```nix

### 🛠️ 환경별 설정 생성

**개발 환경용 설정 추출:**

```bash
# 개발 환경 전용 설정 파일 생성
$ cat config.json | jq '.environments.development' > dev-config.json

# 데이터베이스 연결 문자열 생성
$ cat config.json | jq -r '
  .environments.development.database |
  "postgresql://\(.user)@\(.host):\(.port)/\(.name)"
'
"postgresql://dev_user@localhost:5432/webapp_dev"

# 환경 변수 형태로 변환
$ cat config.json | jq -r '
  .environments.development.database |
  to_entries |
  map("DB_\(.key | ascii_upcase)=\(.value)") |
  .[]
'
DB_HOST=localhost
DB_PORT=5432
DB_NAME=webapp_dev
DB_USER=dev_user
DB_SSL=false
```nix

### 🔧 설정 병합과 오버라이드

```bash
# 기본 설정에 로컬 오버라이드 적용
$ jq -s '.[0] * .[1]' config.json local-override.json

# local-override.json 예시:
{
  "environments": {
    "development": {
      "database": {
        "host": "custom-db-host",
        "port": 5433
      }
    }
  }
}

# 결과: 기본 설정은 유지하되, 지정된 부분만 변경됨
```nix

### 🎯 복잡한 데이터 변환

```bash
# 모든 환경의 데이터베이스 호스트 목록
$ cat config.json | jq '[.environments[] | .database.host] | unique'
["localhost", "prod-db.company.com"]

# 환경별 활성화된 기능 비교
$ cat config.json | jq '
  .environments |
  to_entries |
  map({
    env: .key,
    features: [.value.features | to_entries[] | select(.value == true) | .key]
  })
'
[
  {
    "env": "development",
    "features": ["debugging", "beta_features"]
  },
  {
    "env": "production",
    "features": ["analytics"]
  }
]

# 의존성 요약 리포트
$ cat config.json | jq '
  {
    project: .name,
    version: .version,
    total_dependencies: (.dependencies.runtime + .dependencies.development | length),
    runtime_deps: (.dependencies.runtime | length),
    dev_deps: (.dependencies.development | length),
    environments: (.environments | keys)
  }
'
{
  "project": "awesome-webapp",
  "version": "2.1.0",
  "total_dependencies": 6,
  "runtime_deps": 3,
  "dev_deps": 3,
  "environments": ["development", "production"]
}
```nix

## 4.4 jq의 함수형 특성

### ⚡ 순수 함수와 파이프라인

```bash
# jq는 순수 함수형 언어입니다
# 같은 입력 → 항상 같은 출력

# 파이프라인 형태의 데이터 변환
$ cat config.json | jq '
  .dependencies.runtime           # 런타임 의존성 선택
  | map(select(.name != "redis")) # redis 제외
  | map(.name)                    # 이름만 추출
  | sort                          # 정렬
'
["node", "postgresql"]

# 함수 정의와 재사용
$ cat config.json | jq '
  def get_host(env): .environments[env].database.host;
  def get_port(env): .environments[env].database.port;

  {
    dev_endpoint: "\(get_host("development")):\(get_port("development"))",
    prod_endpoint: "\(get_host("production")):\(get_port("production"))"
  }
'
{
  "dev_endpoint": "localhost:5432",
  "prod_endpoint": "prod-db.company.com:5432"
}
```nix

### 🔗 불변성과 참조 투명성

```bash
# jq는 원본 데이터를 절대 변경하지 않음
$ original=$(cat config.json)
$ modified=$(echo "$original" | jq '.version = "3.0.0"')

$ echo "$original" | jq '.version'    # "2.1.0" (원본 그대로)
$ echo "$modified" | jq '.version'    # "3.0.0" (변경된 복사본)

# 표현식은 언제든 그 값으로 대체 가능 (참조 투명성)
$ cat config.json | jq '.environments.development.database.port'  # 5432
$ cat config.json | jq '(.environments.development.database | .port)'  # 5432 (동일)
```nix

## 4.5 Nix 속성 집합: 코드로써의 설정

### 🎯 JSON에서 Nix로

이제 같은 설정을 Nix 속성 집합으로 표현해봅시다.

```nix
# config.nix - JSON과 같은 구조, 하지만 코드!
{
  name = "awesome-webapp";
  version = "2.1.0";
  description = "A modern web application";

  # 함수를 사용한 설정 생성
  mkEnvironment = { isDev ? false, dbHost, redisHost }: {
    database = {
      host = dbHost;
      port = 5432;
      name = if isDev then "webapp_dev" else "webapp_prod";
      user = if isDev then "dev_user" else "prod_user";
      ssl = !isDev;  # 개발환경에서는 SSL 끄기
    } // (if !isDev then {
      pool = { min = 2; max = 20; };  # 프로덕션에만 풀 설정
    } else {});

    redis = {
      host = redisHost;
      port = 6379;
      db = 0;
    } // (if !isDev then {
      cluster = true;
    } else {});

    api = {
      baseUrl = if isDev
        then "http://localhost:3000"
        else "https://api.company.com";
      timeout = if isDev then 5000 else 10000;
      retries = if isDev then 3 else 5;
    };

    features = {
      debugging = isDev;
      analytics = !isDev;
      beta_features = isDev;
    };
  };

  # 실제 환경 설정들
  environments = {
    development = mkEnvironment {
      isDev = true;
      dbHost = "localhost";
      redisHost = "localhost";
    };

    production = mkEnvironment {
      isDev = false;
      dbHost = "prod-db.company.com";
      redisHost = "prod-redis.company.com";
    };
  };

  # 조건부 의존성 목록
  dependencies = let
    runtime = [
      { name = "node"; version = "18.17.0"; }
      { name = "postgresql"; version = "15.3"; }
      { name = "redis"; version = "7.0.11"; }
    ];
    development = [
      { name = "jest"; version = "29.5.0"; }
      { name = "eslint"; version = "8.44.0"; }
      { name = "prettier"; version = "3.0.0"; }
    ];
  in {
    inherit runtime development;
    all = runtime ++ development;  # 계산된 값
  };
}
```nix

### 🔍 Nix의 고급 기능들

**1. 조건부 속성:**

```nix
{
  # 조건에 따라 다른 설정
  services = {
    nginx.enable = true;
  } // (if enableSSL then {
    nginx.sslCertificates = [ "/path/to/cert" ];
  } else {});
}
```nix

**2. 함수와 재사용:**

```nix
let
  # 서비스 템플릿 함수
  mkService = name: port: {
    enable = true;
    bind = "0.0.0.0:${toString port}";
    logLevel = "info";
  };
in {
  services = {
    web = mkService "web" 8080;
    api = mkService "api" 3000;
    admin = mkService "admin" 9000;
  };
}
```nix

**3. 상속과 오버라이드:**

```nix
let
  baseConfig = {
    timeout = 30;
    retries = 3;
    logLevel = "info";
  };

  prodConfig = baseConfig // {
    timeout = 60;        # 오버라이드
    logLevel = "warn";   # 오버라이드
    # retries = 3 은 baseConfig에서 상속
  };
in {
  environments = {
    development = baseConfig;
    production = prodConfig;
  };
}
```nix

**4. 계산된 값과 유효성 검사:**

```nix
{ pkgs, lib, ... }:

let
  cfg = {
    port = 8080;
    maxConnections = 1000;
  };

  # 유효성 검사
  validPort = lib.assertMsg (cfg.port > 1024) "Port must be > 1024";

in {
  # 계산된 설정들
  processCount = builtins.min 8 (cfg.maxConnections / 100);
  memoryLimit = "${toString (cfg.maxConnections * 2)}M";

  # 조건부 확장
  extraConfig = lib.optionalAttrs (cfg.port == 443) {
    ssl = true;
    certificates = [ "/etc/ssl/cert.pem" ];
  };
}
```nix

## 4.6 JSON vs jq vs Nix 비교

### 📊 기능 비교표

| 기능            | JSON         | jq        | Nix          |
| --------------- | ------------ | --------- | ------------ |
| **데이터 표현** | ✅ 완벽      | ✅ 완벽   | ✅ 완벽      |
| **주석**        | ❌ 불가능    | ❌ 불가능 | ✅ 가능      |
| **변수**        | ❌ 없음      | ✅ 제한적 | ✅ 완전 지원 |
| **함수**        | ❌ 없음      | ✅ 있음   | ✅ 완전 지원 |
| **조건문**      | ❌ 없음      | ✅ 있음   | ✅ 완전 지원 |
| **타입 검사**   | ❌ 없음      | ⚠️ 런타임 | ✅ 정적 검사 |
| **중복 제거**   | ❌ 어려움    | ✅ 가능   | ✅ 완벽      |
| **유효성 검사** | ❌ 외부 도구 | ⚠️ 제한적 | ✅ 내장      |
| **모듈화**      | ❌ 불가능    | ❌ 불가능 | ✅ 완전 지원 |

### 🎯 사용 시나리오

**📄 JSON - 데이터 교환:**

```json
// API 응답, 설정 파일 저장
{
  "users": [
    { "id": 1, "name": "Alice" },
    { "id": 2, "name": "Bob" }
  ]
}
```nix

**⚡ jq - 데이터 변환:**

```bash
# JSON 데이터를 다른 형태로 변환
cat users.json | jq 'map({user_id: .id, full_name: .name})'
```nix

**🔧 Nix - 시스템 구성:**

```nix
# 전체 시스템을 코드로 정의
{ config, pkgs, ... }: {
  users.users = {
    alice = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" ];
      shell = pkgs.zsh;
    };
  };
}
```nix

## 4.7 실제 사용 사례: 멀티 환경 배포

### 🚀 시나리오: 마이크로서비스 배포 설정

**🔴 기존 방식 (JSON + 수동 관리):**

```json
// dev-config.json
{
  "services": {
    "user-service": {"port": 3001, "replicas": 1},
    "order-service": {"port": 3002, "replicas": 1},
    "payment-service": {"port": 3003, "replicas": 1}
  },
  "database": {"host": "localhost", "pool": 5}
}

// prod-config.json
{
  "services": {
    "user-service": {"port": 3001, "replicas": 3},
    "order-service": {"port": 3002, "replicas": 5},
    "payment-service": {"port": 3003, "replicas": 2}
  },
  "database": {"host": "prod-db.internal", "pool": 20}
}
// 중복 코드, 일관성 유지 어려움
```nix

**🟢 Nix 방식 (DRY + 타입 안전):**

```nix
# deployment.nix
{ lib, ... }:

let
  # 서비스 타입 정의
  serviceType = lib.types.submodule {
    options = {
      port = lib.mkOption {
        type = lib.types.port;
        description = "Service port";
      };
      replicas = lib.mkOption {
        type = lib.types.ints.positive;
        description = "Number of replicas";
      };
    };
  };

  # 환경별 설정 생성 함수
  mkEnvironment = { isProd ? false }: {
    services = {
      user-service = {
        port = 3001;
        replicas = if isProd then 3 else 1;
      };
      order-service = {
        port = 3002;
        replicas = if isProd then 5 else 1;
      };
      payment-service = {
        port = 3003;
        replicas = if isProd then 2 else 1;
      };
    };

    database = {
      host = if isProd then "prod-db.internal" else "localhost";
      pool = if isProd then 20 else 5;
      ssl = isProd;
      backup = lib.mkIf isProd {
        enabled = true;
        schedule = "0 2 * * *";
      };
    };

    monitoring = lib.mkIf isProd {
      prometheus.enable = true;
      grafana.enable = true;
    };
  };

in {
  environments = {
    development = mkEnvironment { isProd = false; };
    staging = mkEnvironment { isProd = false; } // {
      # 스테이징 전용 오버라이드
      services.user-service.replicas = 2;
    };
    production = mkEnvironment { isProd = true; };
  };

  # 모든 환경에서 사용할 공통 설정
  common = {
    version = "2.1.0";
    region = "us-west-2";
    tags = {
      project = "awesome-webapp";
      team = "backend";
    };
  };
}
```nix

## 4.8 속성 집합의 고급 패턴

### 🔧 머지와 오버라이드 패턴

```nix
let
  # 기본 설정
  defaults = {
    timeout = 30;
    retries = 3;
    logLevel = "info";
    features = {
      cache = true;
      metrics = false;
    };
  };

  # 개발 환경 오버라이드
  devOverrides = {
    logLevel = "debug";
    features = {
      metrics = true;  # cache는 defaults에서 상속
    };
  };

  # 재귀적 머지 함수
  recursiveMerge = lib.recursiveUpdate;

in {
  # 결과: 중첩된 속성까지 올바르게 병합
  devConfig = recursiveMerge defaults devOverrides;
  # {
  #   timeout = 30;        # defaults에서
  #   retries = 3;         # defaults에서
  #   logLevel = "debug";  # devOverrides에서 오버라이드
  #   features = {
  #     cache = true;      # defaults에서
  #     metrics = true;    # devOverrides에서 오버라이드
  #   };
  # }
}
```nix

### 🎯 조건부 확장 패턴

```nix
{ enableSSL ? false, enableMonitoring ? true, ... }:

{
  services.nginx = {
    enable = true;
    virtualHosts."example.com" = {
      locations."/" = {
        proxyPass = "http://localhost:3000";
      };
    }
    # 조건부 SSL 설정 추가
    // lib.optionalAttrs enableSSL {
      forceSSL = true;
      enableACME = true;
    }
    # 조건부 모니터링 설정 추가
    // lib.optionalAttrs enableMonitoring {
      extraConfig = ''
        access_log /var/log/nginx/access.log combined;
        error_log /var/log/nginx/error.log warn;
      '';
    };
  };

  # 모니터링이 활성화된 경우에만 프로메테우스 설정 포함
  services.prometheus = lib.mkIf enableMonitoring {
    enable = true;
    exporters.nginx.enable = true;
  };
}
```nix

---

## 🎓 섹션 4 요약

**🔑 핵심 깨달음:**

1. **진화 과정**: JSON (데이터) → jq (변환) → Nix (코드)
2. **함수형 특성**: jq와 Nix 모두 순수 함수, 불변성, 참조 투명성 지원
3. **실용적 장점**: 중복 제거, 타입 안전성, 조건부 설정, 모듈화

**📊 도구별 활용:**

- **JSON**: 데이터 저장 및 교환
- **jq**: 기존 JSON 데이터 변환 및 분석
- **Nix**: 복잡한 시스템 설정을 코드로 관리

**🚀 다음 단계:**
속성 집합의 개념을 이해했으니, 이제 **Nix 언어의 문법**을 배워서 실제로 이런 설정들을 작성해봅시다!

---

속성 집합이 단순한 데이터 구조가 아니라 **설정 관리의 혁신**임을 이해하셨나요? JSON에서 시작해서 Nix까지, 자연스러운 연결고리가 보이시나요? 🎯
