# 2. 프로그래밍 패러다임 이해

## 2.1 명령형 프로그래밍: "어떻게(How)" 중심

### 정의와 특징

**명령형 프로그래밍**은 컴퓨터에게 수행할 작업의 순서를 단계별로 지시하는 방식입니다.

**핵심 특징**:

- **순차적 실행**: 명령어를 위에서 아래로 차례대로 실행
- **상태 변경**: 변수 값을 지속적으로 수정
- **제어 구조**: if, for, while로 실행 흐름 제어

### 코드 예제

```python
# 목적: 평균 계산 과정 단계별 실행
# 핵심 개념: 상태 변경, 순차적 처리

lengths = [245, 189, 567, 123, 445]
total = 0
count = 0

for length in lengths:
    total = total + length    # 상태 변경
    count = count + 1         # 상태 변경

average = total / count
print(f"평균: {average}")
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

### 패키지 관리에서의 명령형 접근

```bash
# 목적: 환경 구성 과정 단계별 실행
# 핵심 개념: 시스템 상태 순차적 변경

conda create -n analysis python=3.8
conda activate analysis
pip install biopython==1.78
pip install pandas==1.5.0
pip install matplotlib==3.6.0
```

**문제점**: 각 단계에서 시스템 상태가 변경되며, 중간 실패 시 일관성이 깨집니다.

## 2.2 함수형 프로그래밍: "무엇(What)" 중심

### 정의와 특징

**함수형 프로그래밍**은 원하는 결과를 함수들의 조합으로 표현하는 방식입니다.

**핵심 특징**:

- **불변성**: 한 번 생성된 값은 변경하지 않음
- **순수 함수**: 같은 입력에 항상 같은 출력
- **조합성**: 작은 함수들을 연결하여 복잡한 작업 수행

### 코드 예제

```python
# 목적: 평균 계산을 함수 조합으로 표현
# 핵심 개념: 불변성, 함수 조합

lengths = [245, 189, 567, 123, 445]

# 중간 상태 변경 없이 직접 계산
average = sum(lengths) / len(lengths)
print(f"평균: {average}")

# 또는 함수 조합으로
from statistics import mean
average = mean(lengths)
```

**핵심 차이점**: 중간 상태 변경 없이 입력에서 출력으로 직접 변환합니다.

### 패키지 관리에서의 함수형 접근

```nix
# 목적: 환경을 선언적으로 정의
# 핵심 개념: 불변성, 결정론적 빌드
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.biopython
    python38Packages.pandas
    python38Packages.matplotlib
  ];
}
```

**장점**: 전체가 하나의 함수처럼 동작하여 입력(nixpkgs)에서 출력(완성된 환경)으로 결정론적 변환을 수행합니다.

## 2.3 패러다임 비교 분석

### 패키지 관리 관점에서의 차이점

| 특성          | 명령형 접근             | 함수형 접근         |
| ------------- | ----------------------- | ------------------- |
| **실행 방식** | 단계별 명령 실행        | 선언적 정의         |
| **상태 관리** | 시스템 상태 지속적 변경 | 불변 상태           |
| **재현성**    | 실행 시점에 따라 다름   | 항상 동일           |
| **오류 처리** | 중간 실패 시 불일치     | 전체 성공 또는 실패 |
| **롤백**      | 복잡한 역추적 필요      | 즉시 이전 상태 복원 |

### 실제 문제 시나리오

**명령형 환경 구성의 문제**:

```bash
# 시간에 따른 상태 변화로 인한 문제
2023년 3월: pip install numpy==1.21.0
2023년 6월: pip install tensorflow  # numpy 1.23.0으로 자동 업데이트
2023년 9월: 기존 코드 실행 오류  # numpy 버전 변경으로 인한 충돌
```

**함수형 환경 구성의 해결**:

```nix
# 목적: 시점에 관계없이 동일한 환경 보장
# 핵심 개념: 버전 고정, 불변성
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.numpy      # 항상 호환되는 버전
    python38Packages.tensorflow # 자동 의존성 해결
  ];
}
```

## 2.4 Nix가 함수형 접근을 선택한 이유

### 소프트웨어 환경 관리의 요구사항

1. **재현성**: 같은 설정으로 항상 같은 환경 생성
2. **안정성**: 환경 변경이 기존 작업에 영향을 주지 않음
3. **격리**: 서로 다른 프로젝트 간 간섭 방지
4. **추적성**: 환경 변경사항을 명확히 기록

### 함수형 접근의 해결책

**불변성으로 안정성 확보**:

```nix
# 목적: 환경 정의의 불변성 보장
# 핵심 개념: 한 번 정의된 환경은 절대 변하지 않음
let pythonEnv = pkgs.python38.withPackages (ps: [ps.pandas]);
in pythonEnv  # 이 환경은 영원히 동일
```

**순수 함수로 재현성 보장**:

```nix
# 목적: 결정론적 환경 생성
# 핵심 개념: 같은 입력은 항상 같은 출력
buildEnv = { python, packages }:
  python.withPackages (ps: map (pkg: ps.${pkg}) packages);

# 언제 실행해도 동일한 환경 생성
env = buildEnv { python = pkgs.python38; packages = ["pandas"]; };
```

**조합성으로 유연성 제공**:

```nix
# 목적: 기본 환경들의 조합을 통한 새 환경 생성
# 핵심 개념: 함수 조합, 재사용성
let
  baseEnv = [ pkgs.python38 pkgs.git ];
  dataPackages = [ pkgs.python38Packages.pandas ];
  webPackages = [ pkgs.python38Packages.flask ];
in {
  dataEnv = baseEnv ++ dataPackages;
  webEnv = baseEnv ++ webPackages;
  fullEnv = baseEnv ++ dataPackages ++ webPackages;
}
```

## 2.5 실무에서의 적용

### 환경 관리 워크플로우 비교

**명령형 방식**:

```bash
# 환경 설정이 절차적이고 상태 의존적
conda create -n project python=3.8
conda activate project
pip install -r requirements.txt  # 실행 시점에 따라 다른 버전
python setup.py install
```

**함수형 방식**:

```nix
# 환경 설정이 선언적이고 결정론적
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.pandas
    python38Packages.flask
  ];
}
```

### 팀 협업에서의 이점

**함수형 접근의 장점**:

- 환경 설정 파일이 코드와 함께 버전 관리됨
- 새로운 팀원이 즉시 동일한 환경 구성 가능
- 환경 변경사항이 명시적으로 추적됨
- 롤백과 브랜치별 환경 관리가 간단함

---

**요약**: 함수형 프로그래밍은 불변성과 순수 함수를 통해 예측 가능하고 재현 가능한 시스템을 만듭니다. Nix는 이 원리를 패키지 관리에 적용하여 명령형 도구들의 근본적 한계를 해결합니다.
