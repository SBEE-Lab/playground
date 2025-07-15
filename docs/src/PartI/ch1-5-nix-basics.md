# 5. Nix 기초 문법과 실습

## 5.1 Nix 설치

### 설치 방법

```bash
# Linux/macOS 공식 설치
curl -L https://nixos.org/nix/install | sh

# 설치 후 환경 변수 로드
source ~/.nix-profile/etc/profile.d/nix.sh
```

_※ Windows 의 경우 [WSL 설치 후 이용](https://nixos.org/download/#nix-install-windows)하거나 [Docker](https://nixos.org/download/#nix-install-docker) 를 이용해야 합니다._

### 설치 확인

```bash
$ nix --version
nix (Nix) 2.18.1

$ nix-shell -p hello --run hello
Hello, world!
```

## 5.2 기본 데이터 타입

### 기본 타입

```nix
# 문자열
## inline
"protein sequence"
## multi-line
''
  >protein1
  MKFLVLLFNILC
''

# 숫자와 불린
42
3.14
true
false
null

# 문자열 보간
## call back: referential transparency
let name = "biopython";
in "Package: ${name}"  # "Package: biopython"
```

### 리스트

```nix
# 기본 리스트
## 기본적으로 공백으로 구분됨
["python3" "biopython" "pandas"]

# 리스트 연결
["python3"] ++ ["biopython" "pandas"]  # ["python3" "biopython" "pandas"]

# 혼합 타입
[1 "hello" true { version = "1.0"; }]
```

### 속성 집합

```nix
# 기본 속성 집합
{
  name = "protein-analysis";
  version = "1.0";
  packages = ["biopython" "pandas"];
}

# 중첩 속성 집합
{
  experiment = {
    name = "folding-study";
    date = "2023-10-15";
  };
  environment = {
    python = "3.8";
    packages = ["tensorflow" "numpy"];
  };
}

# 속성 접근
let config = { experiment = { name = "test"; }; };
in config.experiment.name  # "test"
```

## 5.3 함수 정의와 호출

### 기본 함수

```nix
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

### 속성 집합을 받는 함수

```nix
# 패턴 매칭과 기본값
buildEnv = { python ? "3.8", packages ? [], gpu ? false }:
  {
    inherit python gpu;
    buildInputs = packages ++ (if gpu then ["tensorflow-gpu"] else []);
  };

# 사용 예시
buildEnv { packages = ["pandas" "numpy"]; }
buildEnv { python = "3.9"; gpu = true; packages = ["tensorflow"]; }
```

## 5.4 let과 with 표현식

### let 표현식

```nix
let
  # 지역 변수 정의
  pythonVersion = "3.8";
  commonPackages = ["biopython" "pandas" "numpy"];

  # 함수 정의
  mkPackageList = packages: map (pkg: "python38Packages.${pkg}") packages;

in {
  # 변수 사용
  python = pythonVersion;
  packages = mkPackageList commonPackages;
}
```

### with 표현식

```nix
let
  config = {
    database = { host = "localhost"; port = 5432; };
    analysis = { method = "blast"; evalue = 1e-10; };
  };

in {
  # with 없이
  connection = "${config.database.host}:${toString config.database.port}";

  # with 사용
  connection2 = with config.database; "${host}:${toString port}";
}
```

## 5.5 조건문과 패턴 매칭

### if-then-else

```nix
let
  useGPU = true;
  environment = "production";

in {
  tensorflow = if useGPU then "tensorflow-gpu" else "tensorflow";

  resources = if environment == "production"
    then { memory = "32GB"; cores = 16; }
    else { memory = "8GB"; cores = 4; };
}
```

### 속성 집합 패턴 매칭

```nix
processExperiment = { name, type ? "analysis", gpu ? false, ... }:
  {
    experiment_name = name;
    requires_gpu = gpu;
    category = type;
  };

# 사용 예시
processExperiment {
  name = "protein-folding";
  gpu = true;
  extra_field = "ignored";
}
```

## 5.6 실습: 생물정보학 분석 환경 구성

### 기본 Python 환경

```nix
# basic-bio-env.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "basic-bio-analysis";

  buildInputs = with pkgs; [
    python38
    python38Packages.biopython
    python38Packages.pandas
    python38Packages.matplotlib
    python38Packages.numpy
  ];

  shellHook = ''
    echo "🧬 생물정보학 분석 환경"
    echo "Python: $(python --version)"
    echo "사용 가능한 패키지: biopython, pandas, matplotlib, numpy"
  '';
}
```

### 고급 분석 환경

```nix
# advanced-bio-env.nix
{ pkgs ? import <nixpkgs> {} }:

let
  # 기본 Python 환경
  python = pkgs.python38;

  # 패키지 그룹 정의
  bioPackages = ps: with ps; [
    biopython
    numpy
    matplotlib
  ];

  dataPackages = ps: with ps; [
    pandas
    seaborn
    jupyter
  ];

  mlPackages = ps: with ps; [
    scikit-learn
    tensorflow
  ];

  # 환경별 패키지 조합
  pythonEnv = python.withPackages (ps:
    bioPackages ps ++ dataPackages ps ++ mlPackages ps
  );

in pkgs.mkShell {
  name = "advanced-bio-analysis";

  buildInputs = [
    pythonEnv
    pkgs.blast
    pkgs.clustal-omega
  ];

  shellHook = ''
    echo "🧬 고급 생물정보학 분석 환경"
    echo "Python + ML: $(python -c 'import tensorflow; print(tensorflow.__version__)')"
    echo "서열 분석 도구: blast, clustal-omega"
    echo "Jupyter 노트북: jupyter notebook"
  '';
}
```

### 프로젝트별 환경 구성

```nix
# project-envs.nix
{ pkgs ? import <nixpkgs> {} }:

let
  # 공통 함수
  mkBioEnv = { name, python ? pkgs.python38, extraPackages ? [], tools ? [] }:
    pkgs.mkShell {
      inherit name;

      buildInputs = [
        (python.withPackages (ps: with ps; [
          biopython
          pandas
          matplotlib
        ] ++ extraPackages))
      ] ++ tools;

      shellHook = ''
        echo "🧬 ${name} 환경"
        echo "Python: $(python --version)"
      '';
    };

in {
  # 단백질 구조 분석
  protein_folding = mkBioEnv {
    name = "protein-folding";
    extraPackages = ps: with ps; [tensorflow keras];
    tools = with pkgs; [blast];
  };

  # 시퀀스 분석
  sequence_analysis = mkBioEnv {
    name = "sequence-analysis";
    extraPackages = ps: with ps; [seaborn];
    tools = with pkgs; [clustal-omega muscle];
  };

  # 마이크로바이옴 분석
  microbiome = mkBioEnv {
    name = "microbiome-analysis";
    python = pkgs.python39;
    extraPackages = ps: with ps; [scikit-learn];
    tools = with pkgs; [R rPackages.phyloseq];
  };
}
```

## 5.7 실행 및 테스트

### 기본 환경 실행

```bash
# 기본 환경
$ nix-shell basic-bio-env.nix
🧬 생물정보학 분석 환경
Python: Python 3.8.16
사용 가능한 패키지: biopython, pandas, matplotlib, numpy

[nix-shell]$ python -c "
from Bio import SeqIO
import pandas as pd
print('BioPython과 Pandas 사용 가능')
"

# 고급 환경
$ nix-shell advanced-bio-env.nix
🧬 고급 생물정보학 분석 환경
Python + ML: 2.11.0
서열 분석 도구: blast, clustal-omega
Jupyter 노트북: jupyter notebook

[nix-shell]$ jupyter notebook
```

### 프로젝트별 환경 실행

```bash
# 단백질 구조 분석
$ nix-shell project-envs.nix -A protein_folding
🧬 protein-folding 환경
Python: Python 3.8.16

[nix-shell]$ python -c "import tensorflow; print('TensorFlow 사용 가능')"

# 시퀀스 분석
$ nix-shell project-envs.nix -A sequence_analysis
🧬 sequence-analysis 환경
Python: Python 3.8.16

[nix-shell]$ clustalo --help
```

## 5.8 기본 명령어 정리

### 개발 환경 관리

```bash
# 임시 패키지 사용
nix-shell -p python3 python3Packages.biopython

# 환경 파일 실행
nix-shell myenv.nix

# 특정 속성 실행
nix-shell myenvs.nix -A protein_analysis

# 명령 실행 후 종료
nix-shell -p python3 --run "python --version"
```

### 정보 조회

```bash
# 패키지 검색
nix search nixpkgs biopython

# 표현식 평가
nix eval -f myconfig.nix

# JSON 출력
nix eval -f myconfig.nix --json
```

## 5.9 실제 분석 예제

### 단백질 서열 분석 스크립트

```python
# protein_analysis.py
from Bio import SeqIO
import pandas as pd
import matplotlib.pyplot as plt

# FASTA 파일 읽기
sequences = list(SeqIO.parse("proteins.fasta", "fasta"))

# 길이 분석
lengths = [len(seq.seq) for seq in sequences]
df = pd.DataFrame({
    'id': [seq.id for seq in sequences],
    'length': lengths
})

# 통계 출력
print(f"총 서열 개수: {len(sequences)}")
print(f"평균 길이: {df['length'].mean():.1f}")
print(f"최소 길이: {df['length'].min()}")
print(f"최대 길이: {df['length'].max()}")

# 히스토그램 생성
plt.figure(figsize=(10, 6))
plt.hist(lengths, bins=20, alpha=0.7, edgecolor='black')
plt.title('단백질 서열 길이 분포')
plt.xlabel('서열 길이')
plt.ylabel('빈도')
plt.savefig('length_distribution.png')
print("히스토그램 저장: length_distribution.png")
```

### 실행 방법

```bash
# 환경 준비
$ nix-shell basic-bio-env.nix

# 분석 실행
[nix-shell]$ python protein_analysis.py
총 서열 개수: 100
평균 길이: 315.2
최소 길이: 89
최대 길이: 1205
히스토그램 저장: length_distribution.png
```

---

**요약**: Nix 기본 문법을 익히고 실제 생물정보학 분석 환경을 구성했습니다. 다음 장에서는 Nix의 내부 동작 원리와 패키지 관리 시스템을 자세히 알아보겠습니다.
