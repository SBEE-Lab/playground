# 2.3 Attribute Sets and Configuration Management

## 핵심 개념

속성집합(Attribute Sets)은 Nix의 핵심 데이터 구조로, 이름-값 쌍으로 구성된 구조화된 설정을 표현합니다. JSON과 달리 변수, 함수, 조건문을 지원하여 복잡한 환경 설정을 재사용 가능하고 유지보수 가능하게 관리할 수 있습니다.

### 속성집합 기본 구조

속성집합은 중괄호로 둘러싸인 키-값 쌍의 집합입니다. 각 키는 문자열이며, 값은 모든 Nix 타입이 될 수 있습니다.

```nix
# 기본 속성집합 구문
{
  name = "bioanalysis";
  version = "1.0.0";
  language = "python";
  dependencies = ["numpy" "pandas" "biopython"];

  # 중첩 속성집합
  config = {
    threads = 8;
    memory = "16GB";
    gpu = false;
  };

  # 동적 속성명
  "python-version" = "3.8";
  "blast-db-path" = "/usr/local/db/blast";
}
```

속성 접근과 조작:

```nix
let
  project = {
    name = "rnaseq-analysis";
    samples = ["ctrl1" "ctrl2" "treat1" "treat2"];
    pipeline = {
      quality_control = true;
      alignment = "star";
      quantification = "salmon";
    };
  };
in {
  # 점 표기법으로 접근
  project_name = project.name;                    # "rnaseq-analysis"
  aligner = project.pipeline.alignment;           # "star"

  # 동적 접근
  first_sample = builtins.elemAt project.samples 0;  # "ctrl1"

  # 속성 존재 확인
  has_gpu = project ? gpu;                        # false (속성 없음)
  has_name = project ? name;                      # true
}
```

### 속성집합 연산과 조합

속성집합은 다양한 연산을 통해 조합하고 변형할 수 있습니다. 이는 설정 상속과 확장에 매우 유용합니다.

```nix
let
  baseConfig = {
    python = "3.8";
    memory = "8GB";
    timeout = 3600;
    packages = ["numpy" "pandas"];
  };

  # 속성집합 병합 (오른쪽이 우선)
  mlConfig = baseConfig // {
    memory = "16GB";              # 기존 값 오버라이드
    gpu = true;                   # 새 속성 추가
    packages = baseConfig.packages ++ ["tensorflow" "pytorch"];  # 리스트 확장
  };

  # 조건부 속성 추가
  productionConfig = baseConfig // (
    if useGPU then { gpu = true; gpu_memory = "8GB"; } else {}
  );

  # 속성 제거
  lightConfig = removeAttrs baseConfig ["timeout"];

in {
  inherit baseConfig mlConfig productionConfig lightConfig;
}
```

고급 속성집합 조작:

```nix
let
  # 속성 이름 동적 생성
  mkSampleConfig = sampleId: condition: {
    "sample_${sampleId}" = {
      id = sampleId;
      condition = condition;
      replicate = if condition == "control" then 1 else 2;
    };
  };

  # 여러 속성집합 병합
  allSamples =
    mkSampleConfig "001" "control" //
    mkSampleConfig "002" "treatment" //
    mkSampleConfig "003" "control";

  # 속성 필터링과 변환
  controlSamples = builtins.listToAttrs (
    builtins.filter (item: item.value.condition == "control")
      (builtins.map (name: {
        name = name;
        value = allSamples.${name};
      }) (builtins.attrNames allSamples))
  );

in {
  inherit allSamples controlSamples;
}
```

### JSON vs Nix 속성집합 비교

정적 JSON 설정의 한계와 Nix 속성집합의 장점을 구체적으로 살펴보겠습니다.

**JSON 설정의 제약사항:**

```json
{
  "projects": {
    "rnaseq_project": {
      "python": "3.8",
      "packages": ["pandas", "numpy", "deseq2"],
      "memory": "16GB",
      "samples": 24
    },
    "chipseq_project": {
      "python": "3.8",
      "packages": ["pandas", "numpy", "macs2"],
      "memory": "32GB",
      "samples": 12
    },
    "methylation_project": {
      "python": "3.9",
      "packages": ["pandas", "numpy", "methylpy"],
      "memory": "64GB",
      "samples": 48
    }
  }
}
```

문제점들:

- Python 3.8, 공통 패키지 중복 정의
- 총 메모리 요구량, 샘플 수 계산 불가능
- 조건부 로직 (GPU 사용 여부) 구현 어려움
- 설정 템플릿 재사용 불가능

**Nix 속성집합 해결책:**

```nix
let
  # 공통 설정 추출
  commonConfig = {
    basePackages = ["pandas" "numpy"];
    defaultPython = "3.8";
    standardMemory = "16GB";
  };

  # 프로젝트 생성 함수
  mkProject = { python ? commonConfig.defaultPython
              , extraPackages ? []
              , memoryMultiplier ? 1
              , samples
              , useGPU ? false
              }: {
    inherit python samples;
    packages = commonConfig.basePackages ++ extraPackages;
    memory = "${toString (16 * memoryMultiplier)}GB";
    gpu = useGPU;
    estimated_runtime = samples * 2;  # 동적 계산
  };

in {
  projects = {
    rnaseq = mkProject {
      extraPackages = ["deseq2"];
      samples = 24;
    };

    chipseq = mkProject {
      extraPackages = ["macs2"];
      memoryMultiplier = 2;
      samples = 12;
    };

    methylation = mkProject {
      python = "3.9";
      extraPackages = ["methylpy"];
      memoryMultiplier = 4;
      samples = 48;
      useGPU = true;
    };
  };

  # 자동 계산된 통계
  totalSamples = builtins.foldl' (acc: proj: acc + proj.samples) 0
    (builtins.attrValues projects);
  totalMemory = builtins.foldl' (acc: proj: acc + (builtins.fromJSON (builtins.substring 0 2 proj.memory))) 0
    (builtins.attrValues projects);
}
```

### 환경별 설정 관리

실제 연구 환경에서는 개발, 테스트, 프로덕션 환경에 따라 다른 설정이 필요합니다. Nix 속성집합은 이를 체계적으로 관리할 수 있습니다.

```nix
let
  # 기본 환경 설정
  baseEnvironment = {
    python = "3.8";
    packages = ["numpy" "pandas" "matplotlib"];
    threads = 4;
    logging = "info";
  };

  # 환경별 오버라이드
  environments = {
    development = baseEnvironment // {
      packages = baseEnvironment.packages ++ ["ipython" "jupyter"];
      logging = "debug";
      debug_mode = true;
    };

    testing = baseEnvironment // {
      packages = baseEnvironment.packages ++ ["pytest" "coverage"];
      threads = 2;
      timeout = 300;
    };

    production = baseEnvironment // {
      threads = 16;
      memory_limit = "64GB";
      logging = "warning";
      optimization = true;
      backup_enabled = true;
    };

    cluster = baseEnvironment // {
      threads = 32;
      memory_limit = "256GB";
      distributed = true;
      scheduler = "slurm";
      queue = "gpu";
    };
  };

  # 환경 선택 함수
  selectEnvironment = envName:
    if environments ? ${envName}
    then environments.${envName}
    else builtins.throw "Unknown environment: ${envName}";

in {
  inherit environments;

  # 현재 환경 (환경 변수나 매개변수로 제어)
  current = selectEnvironment "development";

  # 환경 비교
  envComparison = builtins.mapAttrs (name: env: {
    inherit (env) threads;
    package_count = builtins.length env.packages;
    has_debug = env ? debug_mode;
  }) environments;
}
```

### 복잡한 패키지 의존성 관리

생물정보학 도구들은 복잡한 의존성 관계를 가집니다. 속성집합을 통해 이를 체계적으로 관리할 수 있습니다.

```nix
let
  # 도구별 요구사항 정의
  tools = {
    blast = {
      version = "2.12.0";
      dependencies = ["ncbi-blast+"];
      memory_per_thread = "2GB";
      database_required = true;
    };

    bwa = {
      version = "0.7.17";
      dependencies = ["bwa"];
      memory_per_thread = "1GB";
      index_required = true;
    };

    star = {
      version = "2.7.10";
      dependencies = ["star"];
      memory_per_thread = "8GB";
      index_required = true;
    };

    salmon = {
      version = "1.9.0";
      dependencies = ["salmon"];
      memory_per_thread = "4GB";
      index_required = true;
    };
  };

  # 분석 파이프라인 정의
  pipelines = {
    dna_alignment = {
      tools = ["bwa" "samtools"];
      estimated_memory = 32;
      parallel_jobs = 4;
    };

    rna_quantification = {
      tools = ["star" "salmon"];
      estimated_memory = 64;
      parallel_jobs = 2;
    };

    sequence_search = {
      tools = ["blast"];
      estimated_memory = 16;
      parallel_jobs = 8;
    };
  };

  # 파이프라인별 리소스 계산
  calculateResources = pipelineName:
    let
      pipeline = pipelines.${pipelineName};
      toolConfigs = map (toolName: tools.${toolName}) pipeline.tools;
      maxMemoryPerThread = builtins.foldl' builtins.max 0
        (map (tool: builtins.fromJSON (builtins.substring 0 1 tool.memory_per_thread)) toolConfigs);
    in {
      total_memory = pipeline.estimated_memory;
      memory_per_job = maxMemoryPerThread * pipeline.parallel_jobs;
      dependencies = builtins.concatLists (map (tool: tool.dependencies) toolConfigs);
    };

in {
  inherit tools pipelines;

  # 각 파이프라인의 리소스 요구사항
  resource_requirements = builtins.mapAttrs (name: _: calculateResources name) pipelines;
}
```

## Practice Section: 속성집합 실습

### 실습 1: 기본 속성집합 조작

```nix
# basic_attrs.nix
let
  project = {
    name = "genomics";
    samples = 10;
    organism = "E.coli";
  };
in {
  # 속성 접근
  project_info = "${project.name}: ${project.organism}";
  sample_count = project.samples;

  # 속성 확장
  extended = project // { version = "1.0"; };
}
```

```bash
nix eval -f basic_attrs.nix --json
```

### 실습 2: 설정 병합

```nix
# config_merge.nix
let
  base = { python = "3.8"; memory = "8GB"; };
  gpu_config = { gpu = true; memory = "16GB"; };
in {
  cpu_env = base;
  gpu_env = base // gpu_config;

  # 메모리 비교
  memory_diff = gpu_config.memory != base.memory;
}
```

```bash
nix eval -f config_merge.nix
```

### 실습 3: 동적 속성 생성

```nix
# dynamic_attrs.nix
let
  samples = ["ctrl" "treat"];
  mkSample = name: { "${name}_config" = { id = name; processed = false; }; };
in
  builtins.foldl' (acc: sample: acc // mkSample sample) {} samples
```

```bash
nix eval -f dynamic_attrs.nix --json
```

### 실습 4: 조건부 설정

```nix
# conditional_config.nix
let
  useGPU = true;
  baseConfig = { threads = 4; memory = "8GB"; };
in
  baseConfig // (if useGPU then {
    gpu = true;
    gpu_memory = "8GB";
    threads = 8;
  } else {})
```

```bash
nix eval -f conditional_config.nix
```

### 실습 5: 환경 설정 함수

```nix
# env_function.nix
let
  mkEnv = {name, python ? "3.8", packages ? []}:
    {
      environment_name = name;
      python_version = python;
      package_list = ["numpy"] ++ packages;
      package_count = builtins.length (["numpy"] ++ packages);
    };
in {
  basic = mkEnv { name = "basic"; };
  advanced = mkEnv {
    name = "advanced";
    python = "3.9";
    packages = ["tensorflow" "pytorch"];
  };
}
```

```bash
nix eval -f env_function.nix --json
```

## 핵심 정리

### 속성집합 필수 연산

```nix
# 기본 조작
attrs = { a = 1; b = 2; };
extended = attrs // { c = 3; };      # 병합
value = attrs.a;                     # 접근
exists = attrs ? c;                  # 존재 확인

# 고급 조작
filtered = removeAttrs attrs ["a"];   # 속성 제거
names = builtins.attrNames attrs;     # 키 목록
values = builtins.attrValues attrs;   # 값 목록
```

### 실용적 패턴

```nix
# 환경 설정 패턴
baseEnv // (if condition then extraConfig else {})

# 다중 병합 패턴
config1 // config2 // config3

# 동적 속성 패턴
{ "${name}_${version}" = value; }
```

**다음**: [2.4 Nix Language Basics](./ch02-4-nix-basics.md)
