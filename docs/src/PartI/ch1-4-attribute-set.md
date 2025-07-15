# 4. 속성 집합(Attribute Sets)과 설정 관리

## 4.1 연구 설정의 구조화

### 실험 조건 기록하기

연구자는 실험 조건을 체계적으로 기록해야 합니다. 단백질 분석 실험을 JSON으로 표현해봅시다.

```json
{
  "experiment": {
    "name": "protein-analysis-v1",
    "date": "2023-10-15",
    "researcher": "kim-lab"
  },
  "samples": {
    "input_file": "sequences.fasta",
    "output_dir": "results/",
    "protein_count": 245
  },
  "analysis": {
    "method": "blast",
    "database": "uniprot",
    "evalue": 1e-10,
    "max_hits": 100
  },
  "environment": {
    "python_version": "3.8",
    "packages": ["biopython", "pandas", "matplotlib"]
  }
}
```

위와 같이 이름(Key)과 값(Value)의 쌍으로 구성된 데이터 구조를 **속성 집합(Attribute Set)** 이라 합니다.

## 4.2 JSON 설정 관리의 한계

### 실제 연구 설정 예제

```json
{
  "projects": {
    "protein_folding": {
      "python": "3.8",
      "packages": ["tensorflow", "biopython", "numpy"],
      "gpu": true,
      "memory": "16GB"
    },
    "sequence_analysis": {
      "python": "3.8",
      "packages": ["biopython", "pandas", "matplotlib"],
      "gpu": false,
      "memory": "8GB"
    },
    "microbiome": {
      "python": "3.9",
      "packages": ["pandas", "scikit-learn", "qiime2"],
      "r_version": "4.2",
      "gpu": false,
      "memory": "32GB"
    }
  }
}
```

### JSON의 제약사항

위 예제를 통해 다음과 같은 json 의 제약 사항들을 확인할 수 있습니다.

- **중복 코드**: Python 3.8, 공통 패키지와 같이 동일한 속성의 정의는 반복해서 선언해야 함.
- **계산 불가**: 속성의 정의만 가능하므로, 표현식 내부에서 메모리 합계, 패키지 개수 등의 계산 불가능
- **조건부 설정**: 속성의 정의만 가능하므로, 표현식 내부에서 GPU 사용 여부와 같은 조건부 설정 어려움
- **재사용성**: 공통 설정 템플릿 정의하거나, 설정 조합 또는 확장이 어려움

## 4.3 jq를 통한 함수형 데이터 처리

### 연구 설정 분석

```bash
# 위의 JSON을 research_config.json으로 저장했다고 가정

# 모든 프로젝트가 사용하는 Python 버전 조회
$ cat research_config.json | jq '.projects | to_entries | map(.value.python)'
["3.8", "3.8", "3.9"]

# GPU 사용 프로젝트만 필터링
$ cat research_config.json | jq '
  .projects |
  to_entries |
  map(select(.value.gpu == true)) |
  map(.key)
'
["protein_folding"]

# 프로젝트별 필요 메모리 합계
$ cat research_config.json | jq '
  .projects |
  to_entries |
  map(.value.memory | sub("GB"; "") | tonumber) |
  add
'
56
```

### 함수형 데이터 변환

```bash
# 환경 변수 형태로 변환
$ cat research_config.json | jq -r '
  .projects.protein_folding |
  to_entries |
  map("ANALYSIS_\(.key | ascii_upcase)=\(.value)") |
  .[]
'
ANALYSIS_PYTHON=3.8
ANALYSIS_GPU=true
ANALYSIS_MEMORY=16GB

# 설치 스크립트 생성
$ cat research_config.json | jq -r '
  .projects.sequence_analysis.packages |
  map("pip install \(.)") |
  .[]
'
pip install biopython
pip install pandas
pip install matplotlib
```

## 4.4 Nix 속성 집합: 코드로서의 설정

Nix 는 속성 집합을 코드로 작성함으로써, 기존 JSON 제약 사항을 해결합니다.

### 기본적인 속성 집합 구조

```nix
# 기본적인 속성 집합 (JSON과 유사)
{
  name = "protein-analysis";
  version = "1.0";
  packages = ["biopython" "pandas"];
  gpu_enabled = true;
}
```

### 1. 주석 사용 가능

```nix
{
  # 실험 메타데이터
  experiment = {
    name = "protein-folding-study";
    # 2023-10-15 시작된 AlphaFold 비교 연구
    date = "2023-10-15";
    researcher = "kim-lab";
  };

  # GPU 사용 시 CUDA 호환성 필요
  environment = {
    python = "3.8";  # TensorFlow 2.8 호환성 위해 고정
    gpu = true;
  };
}
```

### 2. 변수 사용 가능

```nix
let
  # 공통 설정을 변수로 정의
  commonPython = "3.8";
  bioPackages = ["biopython" "numpy" "matplotlib"];

in {
  protein_project = {
    python = commonPython;  # 중복 제거
    packages = bioPackages ++ ["tensorflow"];
  };

  sequence_project = {
    python = commonPython;  # 중복 제거
    packages = bioPackages ++ ["pandas"];
  };
}
```

### 3. 조건부 설정

```nix
let
  useGPU = true;

in {
  environment = {
    python = "3.8";
    # GPU 사용 여부에 따른 조건부 패키지 선택
    packages = ["biopython" "pandas"] ++
               (if useGPU then ["tensorflow-gpu"] else ["tensorflow"]);
    memory = if useGPU then "16GB" else "8GB";
  };
}
```

### 4. 속성 집합 간 계산 가능

```nix
let
  projects = {
    small = { cores = 4; memory_per_core = 2; };
    medium = { cores = 8; memory_per_core = 4; };
    large = { cores = 16; memory_per_core = 8; };
  };

in {
  # 자동으로 총 메모리 계산
  project_summary = builtins.mapAttrs (name: config:
    config // {
      total_memory = config.cores * config.memory_per_core;
      size_category = name;
    }
  ) projects;

  # 전체 리소스 요약
  total_cores = builtins.foldl' (acc: proj: acc + proj.cores) 0
                (builtins.attrValues projects);
}
```

### 5. 재사용 가능한 함수

```nix
let
  # 환경 생성 함수 (템플릿)
  mkResearchEnv = { python ? "3.8", packages ? [], gpu ? false }: {
    inherit python gpu;
    packages = packages ++ (if gpu then ["tensorflow-gpu"] else []);
    memory = if gpu then "16GB" else "8GB";
  };

in {
  # 함수를 사용한 일관된 환경 생성
  basic_env = mkResearchEnv {
    packages = ["pandas" "matplotlib"];
  };

  ml_env = mkResearchEnv {
    packages = ["tensorflow" "scikit-learn"];
    gpu = true;
  };
}
```

## 4.5 실제 연구 환경 구성

### 프로젝트별 환경 정의

```nix
# research-envs.nix
{ pkgs ? import <nixpkgs> {} }:

let
  # 공통 함수들
  mkBioEnv = python: extraPackages: python.withPackages (ps: with ps; [
    biopython
    pandas
    matplotlib
    numpy
  ] ++ extraPackages);

  mkREnv = rPackages: pkgs.rWrapper.override {
    packages = with pkgs.rPackages; [
      phyloseq
      ggplot2
      dplyr
    ] ++ rPackages;
  };

in {
  # 단백질 구조 분석 환경
  protein_folding = pkgs.mkShell {
    buildInputs = [
      (mkBioEnv pkgs.python38 (ps: [ps.tensorflow ps.keras]))
      pkgs.blast
    ];

    shellHook = ''
      echo "🧬 단백질 구조 분석 환경"
      echo "TensorFlow: 사용 가능"
      echo "BLAST: 사용 가능"
    '';
  };

  # 시퀀스 분석 환경
  sequence_analysis = pkgs.mkShell {
    buildInputs = [
      (mkBioEnv pkgs.python38 (ps: [ps.seaborn]))
      pkgs.clustal-omega
      pkgs.muscle
    ];

    shellHook = ''
      echo "🧬 시퀀스 분석 환경"
      echo "다중 서열 정렬 도구 준비됨"
    '';
  };

  # 마이크로바이옴 분석 환경
  microbiome = pkgs.mkShell {
    buildInputs = [
      (mkBioEnv pkgs.python39 (ps: [ps.scikit-learn]))
      (mkREnv [])
      pkgs.qiime2
    ];
  };
}
```

### 사용법

```bash
# 단백질 구조 분석
$ nix-shell research-envs.nix -A protein_folding
🧬 단백질 구조 분석 환경
TensorFlow: 사용 가능
BLAST: 사용 가능

[nix-shell]$ python fold_prediction.py

# 시퀀스 분석 (별도 환경)
$ nix-shell research-envs.nix -A sequence_analysis
🧬 시퀀스 분석 환경
다중 서열 정렬 도구 준비됨

[nix-shell]$ clustalo -i sequences.fasta -o aligned.fasta
```

## 4.6 속성 집합의 고급 패턴

### 설정 상속과 오버라이드

```nix
let
  # 기본 분석 설정
  baseAnalysis = {
    python = "3.8";
    timeout = 3600;
    memory = "8GB";
    packages = ["biopython" "pandas"];
  };

  # 기본 설정을 확장한 특화 분석
  proteinAnalysis = baseAnalysis // {
    timeout = 7200;  # 더 긴 시간 허용
    memory = "16GB";  # 더 많은 메모리
    packages = baseAnalysis.packages ++ ["tensorflow"];
  };

  # 결과 확인
  # proteinAnalysis.python = "3.8" (상속)
  # proteinAnalysis.timeout = 7200 (오버라이드)
  # proteinAnalysis.packages = ["biopython" "pandas" "tensorflow"] (확장)

in {
  environments = {
    basic = baseAnalysis;
    protein = proteinAnalysis;
  };
}
```

### 설정의 동적 계산

```nix
let
  projects = {
    small = { cores = 4; memory_per_core = 2; };
    medium = { cores = 8; memory_per_core = 4; };
    large = { cores = 16; memory_per_core = 8; };
  };

  # 각 프로젝트의 총 메모리 계산
  enrichedProjects = builtins.mapAttrs (name: config:
    config // {
      total_memory = config.cores * config.memory_per_core;
      size_category =
        if config.cores <= 4 then "small"
        else if config.cores <= 8 then "medium"
        else "large";
    }
  ) projects;

in enrichedProjects
```

**참고**: 위 예제들은 Nix 언어들의 기본 문법을 사용합니다. `let`, `//`, `if-then-else`, `builtins.mapAttrs` 등의 자세한 문법은 다음 [5장 Nix Basics](./5-nix-basics.md) 에서 자세히 다룹니다.

## 4.7 JSON vs Nix 속성 집합 비교

| 특성            | JSON              | Nix 속성 집합    |
| --------------- | ----------------- | ---------------- |
| **데이터 표현** | ✅ 완벽           | ✅ 완벽          |
| **주석**        | ❌ 불가능         | ✅ 가능          |
| **변수**        | ❌ 없음           | ✅ let 바인딩    |
| **함수**        | ❌ 없음           | ✅ 완전 지원     |
| **조건문**      | ❌ 없음           | ✅ if-then-else  |
| **계산**        | ❌ 외부 도구 필요 | ✅ 내장 함수     |
| **재사용**      | ❌ 복사-붙여넣기  | ✅ 함수와 import |
| **타입 검사**   | ❌ 없음           | ✅ 정적 검사     |

### 실제 프로젝트에서의 활용

**JSON 방식**:

```json
// 100줄의 반복적인 설정 파일
// 수동으로 일관성 유지
// 변경사항 전파 어려움
```

**Nix 방식**:

```nix
# 10줄의 함수 정의
# 자동 일관성 보장
# 한 곳만 수정하면 모든 곳에 반영
```

---

**요약**: 속성 집합은 연구 설정을 구조화하고 관리하는 강력한 도구입니다. JSON의 표현력에 함수형 프로그래밍의 재사용성과 계산 능력을 더해 복잡한 연구 환경을 효율적으로 관리할 수 있습니다. 다음 장에서는 이러한 개념을 실제 Nix 명령어로 구현하는 방법을 학습합니다.
