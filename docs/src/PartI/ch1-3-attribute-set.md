# 4. 속성집합과 설정 관리

## 4.1 구조화된 설정의 필요성

### 속성집합 데이터 구조

소프트웨어 설정은 이름-값 쌍으로 구성된 **속성집합(Attribute Set)** 형태로 표현됩니다:

```json
{
  "project": {
    "name": "data-analysis",
    "version": "1.0.0",
    "language": "python"
  },
  "environment": {
    "python_version": "3.8",
    "packages": ["pandas", "numpy", "matplotlib"],
    "memory": "8GB"
  },
  "analysis": {
    "method": "statistical",
    "output_format": "csv"
  }
}
```

이러한 구조는 설정을 계층적으로 조직화하고 관리할 수 있게 합니다.

## 4.2 JSON 설정 관리의 제약사항

### 정적 데이터의 한계

```json
{
  "projects": {
    "ml_project": {
      "python": "3.8",
      "packages": ["tensorflow", "numpy", "pandas"],
      "memory": "16GB"
    },
    "web_project": {
      "python": "3.8",
      "packages": ["flask", "numpy", "pandas"],
      "memory": "8GB"
    },
    "data_project": {
      "python": "3.9",
      "packages": ["pandas", "scikit-learn"],
      "memory": "32GB"
    }
  }
}
```

**주요 제약사항**:

- **중복 데이터**: Python 3.8, 공통 패키지 반복 정의
- **계산 불가**: 총 메모리, 패키지 개수 등 동적 계산 불가능
- **조건부 설정**: GPU 사용 여부 등 조건부 로직 구현 어려움
- **재사용성 부족**: 공통 설정 템플릿 정의 및 확장 어려움

## 4.3 jq를 통한 함수형 데이터 처리

### 데이터 분석 및 변환

```bash
# 목적: JSON 데이터 함수형 처리 예제
# 핵심 개념: 함수형 변환, 필터링, 집계

# 모든 프로젝트의 Python 버전 추출
$ jq '.projects | to_entries | map(.value.python)' config.json
["3.8", "3.8", "3.9"]

# 메모리 사용량 8GB 이상인 프로젝트 필터링
$ jq '.projects | to_entries | map(select(.value.memory | tonumber >= 8))' config.json

# 전체 메모리 요구량 계산
$ jq '.projects | to_entries | map(.value.memory | sub("GB"; "") | tonumber) | add' config.json
56
```

### 설정 파일 생성

```bash
# 목적: 설정 데이터를 스크립트로 변환
# 핵심 개념: 데이터 기반 코드 생성

# 설치 스크립트 생성
$ jq -r '.projects.ml_project.packages | map("pip install \(.)") | .[]' config.json
pip install tensorflow
pip install numpy
pip install pandas
```

**한계**: JSON은 정적 데이터만 저장 가능하며, 로직과 계산은 외부 도구에 의존해야 합니다.

## 4.4 Nix 속성집합: 코드로서의 설정

### 프로그래밍 가능한 설정

Nix는 속성집합을 프로그래밍 언어로 작성하여 JSON의 제약을 해결합니다:

```nix
# 목적: 재사용 가능한 설정 정의
# 핵심 개념: 변수, 함수, 조건문 활용
let
  # 공통 설정을 변수로 정의
  commonPython = "3.8";
  basePackages = ["numpy" "pandas"];

in {
  ml_project = {
    python = commonPython;
    packages = basePackages ++ ["tensorflow"];
    memory = "16GB";
  };

  web_project = {
    python = commonPython;
    packages = basePackages ++ ["flask"];
    memory = "8GB";
  };
}
```

### 조건부 설정

```nix
# 목적: 환경에 따른 동적 설정
# 핵심 개념: 조건문, 동적 계산
let
  useGPU = true;
  isDevelopment = false;

in {
  environment = {
    python = "3.8";
    packages = ["pandas" "numpy"] ++
               (if useGPU then ["tensorflow-gpu"] else ["tensorflow"]);
    memory = if useGPU then "16GB" else "8GB";
    debug = isDevelopment;
  };
}
```

### 함수를 통한 설정 생성

```nix
# 목적: 재사용 가능한 환경 생성 함수
# 핵심 개념: 함수 정의, 매개변수화
let
  mkProjectEnv = { python ? "3.8", packages ? [], gpu ? false }:
    {
      inherit python gpu;
      packages = packages ++ (if gpu then ["tensorflow-gpu"] else []);
      memory = if gpu then "16GB" else "8GB";
    };

in {
  # 함수를 사용한 일관된 환경 생성
  basic_env = mkProjectEnv {
    packages = ["pandas" "matplotlib"];
  };

  ml_env = mkProjectEnv {
    packages = ["tensorflow" "scikit-learn"];
    gpu = true;
  };
}
```

## 4.5 실제 환경 구성 예제

### 프로젝트별 환경 정의

```nix
# 목적: 실무 환경 설정 예제
# 핵심 개념: 모듈화, 확장성
{ pkgs ? import <nixpkgs> {} }:

let
  # 환경 생성 함수
  mkPythonEnv = python: extraPackages:
    python.withPackages (ps: with ps; [
      pandas numpy matplotlib
    ] ++ extraPackages);

in {
  # 데이터 분석 환경
  data_analysis = pkgs.mkShell {
    buildInputs = [
      (mkPythonEnv pkgs.python38 (ps: [ps.seaborn ps.jupyter]))
    ];
  };

  # 기계학습 환경
  machine_learning = pkgs.mkShell {
    buildInputs = [
      (mkPythonEnv pkgs.python38 (ps: [ps.tensorflow ps.scikit-learn]))
    ];
  };
}
```

### 설정 상속과 확장

```nix
# 목적: 기본 설정의 상속과 특화
# 핵심 개념: 속성집합 병합, 오버라이드
let
  baseConfig = {
    python = "3.8";
    memory = "8GB";
    packages = ["pandas" "numpy"];
  };

  # 기본 설정을 확장한 특화 설정
  mlConfig = baseConfig // {
    memory = "16GB";  # 오버라이드
    packages = baseConfig.packages ++ ["tensorflow"];  # 확장
    gpu = true;       # 새 속성 추가
  };

in {
  environments = {
    base = baseConfig;
    ml = mlConfig;
  };
}
```

## 4.6 고급 패턴

### 동적 속성 계산

```nix
# 목적: 설정값의 동적 계산
# 핵심 개념: 계산된 속성, 집계 함수
let
  projects = {
    small = { cores = 4; memory_per_core = 2; };
    medium = { cores = 8; memory_per_core = 4; };
    large = { cores = 16; memory_per_core = 8; };
  };

  # 각 프로젝트의 총 메모리 자동 계산
  enrichedProjects = builtins.mapAttrs (name: config:
    config // {
      total_memory = config.cores * config.memory_per_core;
      category =
        if config.cores <= 4 then "small"
        else if config.cores <= 8 then "medium"
        else "large";
    }
  ) projects;

in enrichedProjects
```

### 설정 검증

```nix
# 목적: 설정값 유효성 검사
# 핵심 개념: 어서션, 타입 검사
let
  validateConfig = config:
    assert config.memory_gb > 0;
    assert builtins.isString config.python_version;
    assert builtins.isList config.packages;
    config;

  projectConfig = validateConfig {
    memory_gb = 16;
    python_version = "3.8";
    packages = ["pandas" "numpy"];
  };

in projectConfig
```

## 4.7 JSON vs Nix 속성집합 비교

| 특성            | JSON              | Nix 속성집합     |
| --------------- | ----------------- | ---------------- |
| **데이터 표현** | ✅ 완전 지원      | ✅ 완전 지원     |
| **주석**        | ❌ 불가능         | ✅ 지원          |
| **변수**        | ❌ 없음           | ✅ let 바인딩    |
| **함수**        | ❌ 없음           | ✅ 완전 지원     |
| **조건문**      | ❌ 없음           | ✅ if-then-else  |
| **계산**        | ❌ 외부 도구 필요 | ✅ 내장 함수     |
| **재사용성**    | ❌ 복사-붙여넣기  | ✅ 함수와 import |
| **타입 검사**   | ❌ 없음           | ✅ 정적 검사     |

### 개발 효율성 비교

**JSON 방식**:

- 100줄의 반복적인 설정
- 수동 일관성 유지
- 변경사항 전파 어려움

**Nix 방식**:

- 10줄의 함수 정의
- 자동 일관성 보장
- 중앙화된 변경 관리

---

**요약**: Nix 속성집합은 JSON의 데이터 표현력에 프로그래밍 언어의 계산 능력을 결합합니다. 변수, 함수, 조건문을 통해 복잡한 설정을 간결하고 재사용 가능하게 관리할 수 있습니다.
