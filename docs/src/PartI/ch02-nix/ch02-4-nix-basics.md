# 2.4 Nix Language Basics

## 핵심 개념

Nix 언어는 함수형 도메인 특화 언어(DSL)로, 패키지와 환경을 선언적으로 정의하기 위해 설계되었습니다. 표현식 기반 언어로서 모든 구문이 값을 생성하며, 강력한 타입 추론과 지연 평가를 통해 복잡한 시스템 구성을 간결하게 표현할 수 있습니다.

### 기본 데이터 타입

Nix는 동적 타입 언어이지만 강한 타입 시스템을 가지고 있습니다. 런타임에 타입 검사가 수행되며, 타입 불일치 시 명확한 오류 메시지를 제공합니다.

```nix
# 기본 타입들
let
  # 정수와 부동소수점
  sample_count = 42;
  expression_level = 3.14159;

  # 불린 값
  use_gpu = true;
  debug_mode = false;

  # null 값 (옵션 타입 표현)
  optional_config = null;

  # 문자열 (다양한 정의 방법)
  simple_string = "ATCGTTAA";
  interpolated = "Sample count: ${toString sample_count}";

  # 다중 줄 문자열 (들여쓰기 자동 제거)
  fasta_sequence = ''
    >seq1_sample_001
    ATCGATCGATCGATCGATCG
    GCTAGCTAGCTAGCTAGCTA
  '';

  # 경로 타입 (문자열과 구별됨)
  script_path = ./analysis.py;
  data_directory = /home/user/bioproject/data;

in {
  # 타입 확인
  sample_type = builtins.typeOf sample_count;        # "int"
  string_type = builtins.typeOf simple_string;       # "string"
  path_type = builtins.typeOf script_path;           # "path"
}
```

문자열 조작과 변환:

```nix
let
  sequence = "ATCGATCG";
  sample_id = "sample_001";
  count = 42;

in {
  # 문자열 연결
  filename = "${sample_id}_sequences.fasta";
  full_path = "/data/" + sample_id + "/results.txt";

  # 숫자-문자열 변환
  count_string = toString count;                     # "42"
  parsed_number = builtins.fromJSON "123";          # 123

  # 문자열 길이와 부분 문자열
  seq_length = builtins.stringLength sequence;      # 8
  first_codon = builtins.substring 0 3 sequence;    # "ATC"

  # 문자열 분할과 결합
  codons = builtins.filter (s: s != "")
    (builtins.split "(.{3})" sequence);             # ["ATC" "GAT" "CG"]
}
```

### 리스트 조작

리스트는 Nix에서 가장 중요한 컬렉션 타입입니다. 불변이며 다양한 타입의 요소를 포함할 수 있습니다.

```nix
let
  # 리스트 정의 (공백으로 구분)
  samples = ["ctrl_rep1" "ctrl_rep2" "treat_rep1" "treat_rep2"];
  mixed_list = [1 "hello" true ./path];

  # 리스트 연산
  basic_packages = ["numpy" "pandas"];
  ml_packages = ["tensorflow" "pytorch"];
  all_packages = basic_packages ++ ml_packages;

in {
  # 리스트 접근
  first_sample = builtins.elemAt samples 0;         # "ctrl_rep1"
  sample_count = builtins.length samples;           # 4

  # 리스트 조작
  reversed = builtins.genList (i: builtins.elemAt samples (3 - i)) 4;
  indexed = builtins.genList (i: {
    index = i;
    sample = builtins.elemAt samples i;
  }) (builtins.length samples);

  # 리스트 필터링과 변환
  control_samples = builtins.filter
    (s: builtins.match "ctrl.*" s != null) samples;

  uppercase_samples = map
    (s: builtins.replaceStrings ["ctrl" "treat"] ["CTRL" "TREAT"] s) samples;

  # 리스트 폴딩 (reduce)
  total_length = builtins.foldl'
    (acc: str: acc + builtins.stringLength str) 0 samples;
}
```

고급 리스트 조작:

```nix
let
  sequences = [
    { id = "seq1"; length = 150; gc_content = 0.45; }
    { id = "seq2"; length = 200; gc_content = 0.52; }
    { id = "seq3"; length = 100; gc_content = 0.38; }
  ];

in {
  # 조건부 필터링
  long_sequences = builtins.filter (seq: seq.length > 140) sequences;
  high_gc = builtins.filter (seq: seq.gc_content > 0.5) sequences;

  # 변환과 집계
  sequence_ids = map (seq: seq.id) sequences;
  total_bases = builtins.foldl' (acc: seq: acc + seq.length) 0 sequences;
  average_gc = (builtins.foldl' (acc: seq: acc + seq.gc_content) 0.0 sequences)
              / (builtins.length sequences);

  # 그룹화 (고급 패턴)
  by_length_category = builtins.groupBy
    (seq: if seq.length < 150 then "short" else "long") sequences;
}
```

### 함수 정의와 호출

Nix의 함수는 일급 객체이며, 커링을 자동으로 지원합니다. 모든 함수는 단일 인자를 받아 단일 값을 반환합니다.

```nix
let
  # 단순 함수
  double = x: x * 2;

  # 다중 인자 함수 (커링)
  add = x: y: x + y;
  multiply = x: y: z: x * y * z;

  # 부분 적용
  add10 = add 10;
  double_and_add5 = x: add 5 (double x);

  # 속성집합 패턴 매칭
  mkSample = { id, condition, replicate ? 1 }:
    {
      sample_name = "${condition}_${id}_rep${toString replicate}";
      inherit id condition replicate;
    };

  # 가변 인자 함수 (... 패턴)
  mkAnalysisConfig = { packages, threads ? 4, memory ? "8GB", ... }@args:
    {
      inherit packages threads memory;
      extra_config = removeAttrs args ["packages" "threads" "memory"];
    };

in {
  # 함수 호출
  result1 = double 21;                             # 42
  result2 = add 15 27;                             # 42
  result3 = add10 32;                              # 42

  # 속성집합 패턴 매칭 사용
  sample1 = mkSample { id = "001"; condition = "control"; };
  sample2 = mkSample { id = "002"; condition = "treatment"; replicate = 3; };

  # 가변 인자 사용
  config = mkAnalysisConfig {
    packages = ["numpy" "pandas"];
    threads = 8;
    debug = true;
    timeout = 3600;
  };
}
```

고차 함수와 함수 조합:

```nix
let
  # 고차 함수 예제
  applyToAll = f: list: map f list;
  compose = f: g: x: f (g x);

  # 조건부 함수 적용
  conditional = pred: f: x: if pred x then f x else x;

  # 함수 리스트 적용
  pipeline = functions: input:
    builtins.foldl' (acc: f: f acc) input functions;

in {
  # 고차 함수 사용
  doubled_numbers = applyToAll double [1 2 3 4 5];

  # 함수 조합
  add_then_double = compose double (add 5);
  result = add_then_double 10;                     # (10 + 5) * 2 = 30

  # 파이프라인 처리
  process_sequence = pipeline [
    (s: builtins.replaceStrings ["T"] ["U"] s)     # DNA to RNA
    (s: builtins.stringLength s)                   # 길이 계산
    (l: l / 3)                                     # 코돈 수
  ];

  codon_count = process_sequence "ATCGATCGTAG";    # 11 / 3 = 3
}
```

### let-in과 with 표현식

let-in은 지역 변수를 정의하고, with는 속성집합의 스코프를 확장합니다. 이들은 코드의 가독성과 재사용성을 크게 향상시킵니다.

```nix
# let-in 표현식의 구조
let
  # 변수와 함수 정의 (상호 재귀 가능)
  python_version = "3.8";
  packages = ["numpy" "pandas" "matplotlib"];

  # 함수 정의
  mkPythonEnv = version: pkgs:
    "python${version} with packages: ${toString pkgs}";

  # 상호 재귀 정의
  fibonacci = n: if n <= 1 then n else fibonacci (n-1) + fibonacci (n-2);

  # 중첩 let 표현식
  analysis_config = let
    base_memory = 8;
    thread_multiplier = 2;
  in {
    memory = "${toString (base_memory * thread_multiplier)}GB";
    threads = 4 * thread_multiplier;
  };

in {
  # let에서 정의한 변수들 사용
  environment = mkPythonEnv python_version packages;
  fib_10 = fibonacci 10;
  inherit analysis_config;
}
```

with 표현식의 활용:

```nix
let
  project_config = {
    name = "bioanalysis";
    version = "2.1.0";
    organism = "E.coli";
    samples = 24;
    author = "researcher";
  };

  system_config = {
    threads = 8;
    memory = "32GB";
    storage = "1TB";
    gpu = true;
  };

in {
  # with를 사용한 스코프 확장
  project_summary = with project_config;
    "Project ${name} v${version} studying ${organism} with ${toString samples} samples by ${author}";

  # 다중 with 사용
  resource_summary = with project_config; with system_config;
    "${name} requires ${toString threads} threads and ${memory} memory for ${toString samples} samples";

  # with의 우선순위 (오른쪽이 우선)
  mixed_scope = with project_config; with system_config; {
    # system_config의 name이 있다면 그것이 우선
    inherit name version threads memory;
  };

  # inherit with 패턴
  extracted_config = with project_config; {
    inherit name version organism;  # project_config에서 가져옴
    analysis_date = "2024-01-15";   # 새로 정의
  };
}
```

### 조건문과 제어 구조

Nix의 조건문은 표현식이므로 항상 값을 반환합니다. 이는 함수형 언어의 특징으로, 부작용 없는 조건부 로직을 구성할 수 있습니다.

```nix
let
  # 기본 조건문
  sample_count = 50;
  use_gpu = true;
  organism = "E.coli";

  # 단순 조건문
  analysis_mode = if sample_count > 100 then "batch" else "interactive";

  # 중첩 조건문
  memory_requirement =
    if sample_count < 10 then "4GB"
    else if sample_count < 50 then "16GB"
    else if sample_count < 200 then "32GB"
    else "64GB";

  # 조건부 속성집합
  gpu_config = if use_gpu then {
    gpu_memory = "8GB";
    cuda_version = "11.8";
    gpu_threads = 1024;
  } else {};

  # 조건부 리스트 구성
  packages = ["numpy" "pandas"] ++
    (if use_gpu then ["cupy" "tensorflow-gpu"] else ["tensorflow-cpu"]) ++
    (if organism == "human" then ["pysam" "pybedtools"] else []);

in {
  # 고급 조건부 로직
  environment_config = {
    inherit analysis_mode memory_requirement packages;

    # 조건부 병합
    system = { threads = 4; } // gpu_config;

    # 조건부 함수 적용
    optimizations = if sample_count > 1000
      then ["parallel" "vectorized" "cached"]
      else ["standard"];
  };

  # assert를 통한 조건 검증
  validated_config =
    assert sample_count > 0;
    assert builtins.elem organism ["E.coli" "human" "mouse"];
    environment_config;
}
```

### 재귀와 리스트 처리

Nix에서 반복은 재귀를 통해 구현됩니다. 내장 함수들이 대부분의 일반적인 패턴을 제공하지만, 커스텀 재귀 함수가 필요한 경우도 있습니다.

```nix
let
  # 재귀 함수 예제
  factorial = n: if n <= 1 then 1 else n * factorial (n - 1);

  # 리스트 재귀 처리
  sum_list = list:
    if list == [] then 0
    else builtins.head list + sum_list (builtins.tail list);

  # 더 안전한 리스트 처리
  safe_sum = list:
    builtins.foldl' (acc: x: acc + x) 0 list;

  # 트리 구조 처리 (재귀적 속성집합)
  process_tree = tree:
    if builtins.isAttrs tree
    then builtins.mapAttrs (name: subtree: process_tree subtree) tree
    else if builtins.isList tree
    then map process_tree tree
    else tree;  # 기본값

  # 조건부 재귀
  find_in_list = predicate: list:
    if list == [] then null
    else if predicate (builtins.head list) then builtins.head list
    else find_in_list predicate (builtins.tail list);

in {
  # 재귀 함수 사용
  fact_10 = factorial 10;
  list_sum = sum_list [1 2 3 4 5];
  safe_result = safe_sum [10 20 30];

  # 실제 데이터 처리 예제
  sample_data = [
    { id = "S001"; quality = 95; length = 150; }
    { id = "S002"; quality = 87; length = 200; }
    { id = "S003"; quality = 92; length = 175; }
  ];

  high_quality = find_in_list (s: s.quality > 90) sample_data;

  # 중첩 데이터 처리
  experiment = {
    samples = sample_data;
    analysis = {
      quality_threshold = 90;
      length_filter = 160;
    };
  };

  processed_experiment = process_tree experiment;
}
```

## Practice Section: Nix 언어 실습

### 실습 1: 기본 타입과 변수

```nix
# basic_types.nix
let
  sample_id = "ctrl_001";
  read_count = 1500000;
  quality_score = 28.5;
  is_paired = true;
in {
  # 문자열 조작
  filename = "${sample_id}_processed.fastq";

  # 숫자 계산
  million_reads = read_count / 1000000.0;

  # 타입 확인
  types = {
    id_type = builtins.typeOf sample_id;
    count_type = builtins.typeOf read_count;
    score_type = builtins.typeOf quality_score;
  };
}
```

```bash
nix eval -f basic_types.nix --json
```

### 실습 2: 리스트와 함수

```nix
# list_functions.nix
let
  samples = ["ctrl1" "ctrl2" "treat1" "treat2"];

  # 함수 정의
  add_suffix = suffix: name: "${name}_${suffix}";
  filter_control = builtins.filter (s: builtins.match "ctrl.*" s != null);

in {
  # 리스트 변환
  fastq_files = map (add_suffix "R1.fastq") samples;
  control_samples = filter_control samples;
  sample_count = builtins.length samples;
}
```

```bash
nix eval -f list_functions.nix
```

### 실습 3: 조건문과 패턴 매칭

```nix
# conditionals.nix
let
  sample_size = 150;
  organism = "human";

  memory_calc = size:
    if size < 50 then "4GB"
    else if size < 200 then "16GB"
    else "32GB";

in {
  required_memory = memory_calc sample_size;

  packages = ["numpy"] ++
    (if organism == "human" then ["pysam"] else []) ++
    (if sample_size > 100 then ["dask"] else []);

  analysis_type = if sample_size > 200 then "cluster" else "local";
}
```

```bash
nix eval -f conditionals.nix
```

### 실습 4: let-in과 with 표현식

```nix
# let_with.nix
let
  project = {
    name = "rnaseq";
    samples = 24;
    organism = "mouse";
  };

  config = let
    base_mem = 8;
    threads = 4;
  in {
    memory = "${toString (base_mem * 2)}GB";
    cpu_threads = threads;
  };

in {
  summary = with project;
    "Project ${name}: ${organism} with ${toString samples} samples";

  resources = with config; {
    inherit memory cpu_threads;
    estimated_time = config.cpu_threads * 2;
  };
}
```

```bash
nix eval -f let_with.nix
```

### 실습 5: 실제 환경 구성

```nix
# env_config.nix
{ pkgs ? import <nixpkgs> {} }:
let
  python_version = "38";
  use_gpu = false;

  base_packages = ps: with ps; [numpy pandas matplotlib];
  ml_packages = ps: with ps; [scikit-learn];
  gpu_packages = ps: with ps; [tensorflow];

  select_packages = ps:
    base_packages ps ++ ml_packages ps ++
    (if use_gpu then gpu_packages ps else []);

in {
  pythonEnv = pkgs."python${python_version}".withPackages select_packages;

  shellConfig = {
    name = "bioanalysis-env";
    buildInputs = [ pythonEnv ];
    shellHook = ''
      echo "Python ${python_version} environment ready"
      echo "GPU support: ${if use_gpu then "enabled" else "disabled"}"
    '';
  };
}
```

```bash
nix eval -f env_config.nix.shellConfig --json
```

## 핵심 정리

### 기본 문법 요약

```nix
# 변수와 함수
let x = 42; f = y: y * 2; in f x

# 조건문
if condition then value1 else value2

# 리스트와 속성집합
[ "a" "b" "c" ]
{ name = "value"; }

# 함수 호출
function argument
function { attr1 = val1; attr2 = val2; }
```

### 자주 사용하는 패턴

```nix
# 환경 설정 패턴
{ pkgs ? import <nixpkgs> {} }:
let config = { ... };
in pkgs.mkShell { buildInputs = [ ... ]; }

# 조건부 패키지 패턴
packages ++ (if condition then extra_packages else [])

# 속성집합 패턴 매칭
{ name, version ? "1.0", ... }@args:
```

**다음**: [2.5 Nix Core Concepts](./ch02-5-nix-core.md)
