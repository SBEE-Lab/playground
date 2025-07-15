# 2. 프로그래밍 패러다임 이해

## 2.1 실험실에서의 접근 방식

### 실험 프로토콜의 두 가지 작성법

연구실에서 실험 프로토콜을 작성하는 방식을 생각해봅시다.

#### **방법 A: 단계별 지시사항**

```text
1. 37도 배양기를 켠다
2. 배지 100ml를 준비한다
3. 세포를 배지에 접종한다
4. 24시간 배양한다
5. 세포 농도를 측정한다
```

#### **방법 B: 결과 중심 명세**

```text
목표: 1x10^6 cells/ml 농도의 세포 배양액
조건: 37°C, 24시간, LB 배지
재료: E.coli strain BL21
```

두 방법 모두 같은 결과를 얻지만, 접근 방식이 다릅니다.

## 2.2 명령형 프로그래밍: "어떻게(How)" 중심

### 정의와 특징

**명령형 프로그래밍**은 컴퓨터에게 수행할 작업의 순서를 단계별로 지시하는 방식입니다.

**특징**:

- 순차적 실행: 위에서 아래로 명령어 실행
- 상태 변경: 변수 값을 계속 수정
- 제어 구조: if, for, while로 흐름 제어

### 데이터 분석 예제

```python
# 명령형: 단백질 길이 평균 계산
protein_lengths = [245, 189, 567, 123, 445]
total = 0
count = 0

for length in protein_lengths:
    total = total + length    # 상태 변경
    count = count + 1         # 상태 변경

average = total / count
print(f"평균 길이: {average}")
```

**실행 과정**:

```text
step 1: total=245, count=1
step 2: total=434, count=2
step 3: total=1001, count=3
step 4: total=1124, count=4
step 5: total=1569, count=5
result: average=313.8
```

### 환경 관리에서의 명령형 접근

```bash
# 분석 환경 구성 (명령형)
conda create -n analysis python=3.8
conda activate analysis
pip install biopython==1.78
pip install pandas==1.5.0
pip install matplotlib==3.6.0

# 문제: 각 단계에서 시스템 상태가 변경됨
# 중간에 실패하면 불일치 상태가 됨
```

## 2.3 함수형 프로그래밍: "무엇(What)" 중심

### 정의와 특징

**함수형 프로그래밍**은 원하는 결과를 함수들의 조합으로 표현하는 방식입니다.

**특징**:

- 불변성: 한 번 만든 값은 변경하지 않음
- 순수 함수: 같은 입력에 항상 같은 출력
- 조합성: 작은 함수들을 연결하여 복잡한 작업 수행

### 데이터 분석에서의 함수형 접근 예제

```python
# 함수형: 단백질 길이 평균 계산
protein_lengths = [245, 189, 567, 123, 445]

average = sum(protein_lengths) / len(protein_lengths)
print(f"평균 길이: {average}")

# 또는 함수 조합으로
from statistics import mean
average = mean(protein_lengths)
```

**핵심 차이점**: 중간 상태 변경 없이 직접 결과를 계산합니다.

### 환경 관리에서의 함수형 접근

```nix
# 분석 환경 구성 (함수형)
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.biopython
    python38Packages.pandas
    python38Packages.matplotlib
  ];
}

# 전체가 하나의 "함수"처럼 동작
# 입력(nixpkgs) → 출력(완성된 환경)
```

## 2.4 연구 관점에서의 비교

### 실험 프로토콜과의 유사성

| 측면          | 명령형 (단계별 지시)              | 함수형 (결과 명세)            |
| ------------- | --------------------------------- | ----------------------------- |
| **실험 기록** | "37도로 설정하고, 배지를 넣고..." | "37도에서 24시간 배양된 세포" |
| **재현성**    | 순서 중요, 중간 실패시 문제       | 조건만 맞으면 동일한 결과     |
| **문제 해결** | 어느 단계에서 문제가 생겼나?      | 최종 조건이 맞는가?           |
| **공유**      | 긴 프로토콜 문서                  | 간단한 조건 명세              |

### 패키지 관리 비교

**명령형 환경 구성의 문제**:

```bash
# 시간에 따른 상태 변화
2023년 3월: pip install numpy==1.21.0
2023년 6월: pip install tensorflow  # numpy 1.23.0으로 자동 업데이트
2023년 9월: 기존 코드 실행 오류  # numpy 버전 변경으로 인한 문제
```

**함수형 환경 구성의 장점**:

```nix
# 언제나 동일한 환경 생성
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.numpy  # 항상 호환되는 버전 조합
    python38Packages.tensorflow
  ];
}
```

## 2.5 재현성 관점에서의 분석

### 실험 재현성과 코드 재현성

**생물학 실험에서**:

- 온도, pH, 시간 등 모든 조건을 정확히 기록
- 같은 조건이면 같은 결과를 기대
- 조건이 바뀌면 결과도 달라질 수 있음

**컴퓨팅 환경에서**:

- 소프트웨어 버전, 라이브러리, 설정이 조건
- 같은 환경이면 같은 결과를 기대
- 환경이 바뀌면 결과도 달라질 수 있음

### 명령형 접근의 재현성 문제

```bash
# 연구자 A의 환경 (2023년 3월)
pip install pandas==1.5.0
pip install numpy==1.21.0
python analysis.py  # 성공

# 연구자 B의 재현 시도 (2023년 9월)
pip install pandas==1.5.0
pip install numpy==1.21.0  # 실제로는 1.24.0이 설치됨
python analysis.py  # 오류 발생
```

**문제**: 같은 명령어라도 시점에 따라 다른 결과가 나옵니다.

### 함수형 접근의 재현성 보장

```nix
# environment.nix
{ pkgs ? import (fetchTarball {
    # 소스를 가져온 시점, 빌드 정보를 포함한 해시를 통해 의존성을 고정
    url = "https://github.com/NixOS/nixpkgs/archive/21.11.tar.gz";
    sha256 = "162dywda2dvfj1248afxjkqf5slsl2w8qhzxhi8a8nyv7xhz5mli";
  }) {}
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.pandas  # 정확히 1.5.3
    python38Packages.numpy   # 정확히 1.21.6
  ];
}
```

**결과**: 언제든지, 어디서든지 정확히 같은 환경이 생성됩니다.

## 2.6 Nix가 함수형 접근을 선택한 이유

### 연구 환경 관리의 요구사항

1. **재현성**: 논문 결과를 다른 연구자가 재현할 수 있어야 함
2. **안정성**: 환경 변경이 기존 작업에 영향을 주면 안됨
3. **격리**: 서로 다른 프로젝트가 간섭하면 안됨
4. **공유**: 팀원들과 동일한 환경을 사용해야 함

### 함수형 접근이 제공하는 해결책

**불변성**으로 안정성 확보:

```nix
# 한 번 정의된 환경은 절대 변하지 않음
let pythonEnv = pkgs.python38.withPackages (ps: [ps.pandas]);
in pythonEnv  # 이 환경은 영원히 동일함
```

**순수 함수**로 재현성 보장:

```nix
# 같은 입력 → 항상 같은 출력
buildEnv { python = "3.8"; packages = ["pandas"]; }
# 언제 실행해도 동일한 환경 생성
```

**조합성**으로 유연성 제공:

```nix
# 기본 환경들을 조합하여 새로운 환경 생성
webEnv = baseEnv ++ webPackages;
analysisEnv = baseEnv ++ dataPackages;
fullEnv = baseEnv ++ webPackages ++ dataPackages;
```

## 2.7 실제 연구 워크플로우에서의 적용

### 논문 재현 시나리오

**기존 방식**:

```bash
# README.md의 설치 지시사항
conda create -n paper-env python=3.8
pip install -r requirements.txt  # 100개 패키지 목록
python setup.py install
# 성공률: 환경에 따라 실패
```

**Nix 방식**:

```nix
# paper-env.nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    # 모든 의존성이 자동으로 해결됨
    python38
    python38Packages.numpy
    python38Packages.pandas
    # ... 기타 필요한 패키지들
  ];
}
```

```bash
$ nix-shell paper-env.nix
# 성공률: 100% (항상 동일한 환경)
```

### 팀 협업 시나리오

**함수형 접근의 장점**:

- 환경 설정 파일이 코드와 함께 버전 관리됨
- 새로운 팀원이 즉시 동일한 환경 구성 가능
- 환경 변경사항이 명확히 추적됨

---

**요약**: 함수형 프로그래밍은 실험 프로토콜에서 "결과 중심 명세"와 같은 접근법입니다. Nix는 이 원리를 패키지 관리에 적용하여 완전한 재현성과 안정성을 제공합니다. 다음 장에서는 함수형 프로그래밍의 핵심 개념들을 더 자세히 살펴보겠습니다.
