# 3. 함수형 프로그래밍 심화와 빌드 시스템

## 3.1 연구 데이터 관리에서의 의존성 문제

### 실제 연구 시나리오

당신이 6개월 전 작성한 단백질 분석 코드를 다시 실행하려고 합니다.

```bash
$ python protein_analysis.py
ModuleNotFoundError: No module named 'biopython'

$ pip install biopython
$ python protein_analysis.py
ValueError: DataFrame.append() has been removed in pandas 2.0

$ pip install pandas==1.5.0
ERROR: tensorflow 2.13.0 requires numpy>=1.24.0,
       but pandas 1.5.0 requires numpy<1.24.0
```

**문제**: 패키지들이 서로 다른 의존성을 요구하여 호환 가능한 조합을 찾기 어렵습니다.

### 의존성 그래프의 복잡성

```text
프로젝트: 단백질 구조 분석
├── Python 3.8
├── BioPython 1.79
│   ├── NumPy >= 1.17.0
│   └── setuptools
├── TensorFlow 2.8.0
│   ├── NumPy >= 1.20.0, < 1.24.0  ⚠️
│   └── protobuf < 3.20.0
└── Pandas 1.5.0
    ├── NumPy >= 1.21.0  ⚠️
    └── pytz >= 2020.1
```

BioPython, TensorFlow, Pandas 모두, 실행을 위해서는 NumPy를 필요로 합니다.
이렇게 각 패키지가 요구(의존)하는 것을 특정 패키지에 대한 **의존성** 이라고 하며, 이 의존성들 간의 관계를 위와 같이 그래프로 나타낸 것을 **의존성 그래프**라고 합니다.

일반적으로, 위 예제처럼 각 패키지가 요구하는 의존성(NumPy) 버전이 다르면 설치가 불가능합니다.

## 3.2 함수형 프로그래밍 핵심 개념

### 불변성(Immutability): 데이터의 안정성

**연구 맥락**: 실험 데이터는 수집 후 절대 변경하지 않습니다.

```python
# 문제가 있는 접근: 원본 데이터 변경
protein_data = load_sequences("proteins.fasta")
protein_data.append(new_sequence)  # 원본이 변경됨(임의로 추가됨)!
analyze(protein_data)  # 어떤 데이터를 분석한 건지 불분명

# 불변성 접근: 새로운 데이터셋 생성
original_data = load_sequences("proteins.fasta")
extended_data = original_data + [new_sequence]  # 새로운 데이터셋
analyze(extended_data)  # 분석 대상이 명확
```

**Nix에서의 불변성**: 한 번 정의된 것은 변경될 수 없습니다.

```nix
let
  pythonVersion = "3.8";  # 한 번 정의되면 변경 불가
  # pythonVersion = "3.9";  # 오류! 재할당 불가능
in {
  buildInputs = [ pkgs.python38 ];  # 항상 같은 버전
}
```

### 순수 함수(Pure Functions): 예측 가능한 결과

**연구 맥락**: 같은 조건의 실험은 항상 같은 결과를 만들어야 합니다.

```python
# 비순수 함수: 외부 상태에 의존
current_temperature = 25  # 전역 변수

def enzyme_activity(substrate_conc):
    global current_temperature
    current_temperature += 2  # 외부 상태 변경
    return substrate_conc * current_temperature * 0.1

# 같은 입력이지만 다른 결과
result1 = enzyme_activity(10)  # 27
result2 = enzyme_activity(10)  # 29

# 순수 함수: 외부 상태 독립
def pure_enzyme_activity(substrate_conc, temperature):
    return substrate_conc * temperature * 0.1

# 같은 입력은 항상 같은 결과
result1 = pure_enzyme_activity(10, 25)  # 25
result2 = pure_enzyme_activity(10, 25)  # 25
```

**Nix에서의 순수 함수**:

```nix
# 패키지 빌드 함수 (순수 함수)
buildPythonEnv = pythonVersion: packages:
  pkgs."python${pythonVersion}".withPackages (ps:
    map (pkg: ps.${pkg}) packages
  );

# 같은 입력 → 항상 같은 환경
env1 = buildPythonEnv "38" ["pandas" "numpy"];
env2 = buildPythonEnv "38" ["pandas" "numpy"];
# env1과 env2는 완전히 동일함
```

### 참조 투명성(Referential Transparency): 표현식과 값의 교환

**개념**: 표현식을 그 결과값으로 바꿔도 프로그램 동작이 변하지 않습니다.

```nix
let
  pythonVersion = "38";
  pythonPackage = pkgs."python${pythonVersion}";  # 계산된 값
in {
  # 다음 두 표현은 완전히 동일함
  buildInputs = [ pythonPackage ];
  buildInputs = [ pkgs.python38 ];  # 직접 참조
}
```

## 3.3 의존성 지옥의 함수형 해결

### 전통적 접근의 한계

```bash
# 시간에 따른 환경 변화
2023년 3월: pip install tensorflow==2.8.0  # numpy 1.21.0
2023년 6월: pip install pandas==2.0.0      # numpy 1.24.0 요구
2023년 9월: 기존 TensorFlow 코드 실행 불가  # numpy 호환성 문제
```

**문제**: 패키지 설치가 기존 환경을 변경하여 예측 불가능한 상태를 만듭니다.

### Nix의 함수형 해결책

**격리된 환경 구성**:

```nix
# tensorflow-env.nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.tensorflow  # 호환되는 numpy 자동 선택
    python38Packages.numpy       # 정확한 버전 조합
  ];
}

# pandas-env.nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.pandas      # 다른 numpy 버전 사용 가능
    python38Packages.numpy
  ];
}
```

**사용법**:

```bash
# TensorFlow 작업
$ nix-shell tensorflow-env.nix
[nix-shell]$ python tf_model.py

# Pandas 작업 (완전히 별개 환경)
$ nix-shell pandas-env.nix
[nix-shell]$ python data_analysis.py
```

### 조합 가능한 환경 설계

```nix
# 기본 도구들을 함수로 정의
let
  basePython = pkgs.python38;

  bioTools = python-pkgs: with python-pkgs; [
    biopython
    numpy
    matplotlib
  ];

  mlTools = python-pkgs: with python-pkgs; [
    tensorflow
    scikit-learn
    pandas
  ];

  dataTools = python-pkgs: with python-pkgs; [
    pandas
    jupyter
    seaborn
  ];

in {
  # 필요에 따라 조합
  bioEnv = basePython.withPackages bioTools;
  mlEnv = basePython.withPackages mlTools;
  dataEnv = basePython.withPackages dataTools;

  # 전체 환경 (자동으로 호환성 해결)
  fullEnv = basePython.withPackages (ps:
    bioTools ps ++ mlTools ps ++ dataTools ps
  );
}
```

## 3.4 재현 가능한 연구 환경

### 문제 상황: 논문 재현 실패

```bash
# 논문 저자가 제공한 설치 방법
pip install -r requirements.txt

# requirements.txt 내용
biopython>=1.78
pandas>=1.5.0
tensorflow>=2.8.0
numpy>=1.20.0
```

**문제**: `>=` 버전 지정으로 인해 설치 시점에 따라 다른 환경이 구성됩니다.

### Nix 해결책: 정확한 버전 고정

```nix
# paper-reproduction.nix
{ pkgs ? import (fetchTarball {
    # 특정 시점의 nixpkgs 고정
    url = "https://github.com/NixOS/nixpkgs/archive/22.11.tar.gz";
    sha256 = "11w3wn2yjhaa5pv20gbfbirvjq6i3m7pqrq2msf0g7cv44vijwgw";
  }) {}
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python38                      # Python 3.8.16
    python38Packages.biopython    # BioPython 1.79
    python38Packages.pandas       # Pandas 1.5.3
    python38Packages.tensorflow   # TensorFlow 2.11.0
    python38Packages.numpy        # NumPy 1.23.5
  ];

  shellHook = ''
    echo "논문 재현 환경 준비 완료"
    echo "모든 패키지 버전이 고정되어 있습니다"
  '';
}
```

**결과**: 2년 후에도 정확히 같은 환경이 재현됩니다.

## 3.5 실제 연구 워크플로우 적용

### 프로젝트별 환경 관리

```nix
# protein-folding/shell.nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  name = "protein-folding-analysis";
  buildInputs = with pkgs; [
    python38
    python38Packages.biopython
    python38Packages.tensorflow
    python38Packages.matplotlib
  ];
}

# microbiome/shell.nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  name = "microbiome-analysis";
  buildInputs = with pkgs; [
    python39                    # 다른 Python 버전
    python39Packages.pandas
    python39Packages.scikit-learn
    R                          # R 통계 환경 추가
    rPackages.phyloseq
  ];
}
```

### 팀 협업과 환경 공유

```bash
# 연구실 동료와 환경 공유
$ git clone https://github.com/lab/protein-study.git
$ cd protein-study
$ nix-shell  # shell.nix 자동 실행
[nix-shell]$ python run_analysis.py  # 즉시 분석 시작
```

**장점**:

- 환경 설정 파일이 코드와 함께 버전 관리됨
- 새로운 팀원이 5분 내에 동일한 환경 구성
- 환경 변경사항이 명확히 추적됨

## 3.6 함수형 vs 명령형: 연구 환경 관리 비교

| 특성            | 명령형 (conda/pip) | 함수형 (Nix)   |
| --------------- | ------------------ | -------------- |
| **재현성**      | 시점에 따라 다름   | 항상 동일      |
| **격리**        | 부분적 (가상환경)  | 완전 격리      |
| **롤백**        | 어려움             | 즉시 가능      |
| **의존성 해결** | 수동 관리          | 자동 해결      |
| **환경 공유**   | 문서 + 설치 과정   | 설정 파일 하나 |
| **안정성**      | 변경 위험 있음     | 기존 환경 보호 |

### 실제 작업 시간 비교

```text
새로운 분석 환경 구성:

명령형 방식:
- 가상환경 생성: 5분
- 패키지 설치 시도: 30분
- 의존성 충돌 해결: 2시간
- 문서 작성: 30분
총 시간: 3시간 5분

함수형 방식 (Nix):
- shell.nix 작성: 10분
- nix-shell 실행: 5분 (최초 다운로드)
총 시간: 15분
```

---

**요약**: 함수형 프로그래밍의 불변성, 순수 함수, 참조 투명성은 연구 환경 관리에서 재현성과 안정성을 보장합니다. Nix는 이 원리들을 패키지 관리에 적용하여 의존성 지옥을 근본적으로 해결합니다. 다음 장에서는 이러한 개념들이 데이터 구조인 속성 집합으로 어떻게 구현되는지 알아보겠습니다.
