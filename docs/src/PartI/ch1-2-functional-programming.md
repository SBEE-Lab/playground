# 3. 함수형 프로그래밍 심화와 의존성 관리

## 3.1 의존성 충돌 문제의 본질

### 복합 의존성 시나리오

현대 소프트웨어에서 패키지들은 복잡한 의존성 관계를 형성합니다:

```text
프로젝트: 데이터 분석 애플리케이션
├── Python 3.8
├── BioPython 1.79
│   ├── NumPy >= 1.17.0
│   └── setuptools
├── TensorFlow 2.8.0
│   ├── NumPy >= 1.20.0, < 1.24.0
│   └── protobuf < 3.20.0
└── Pandas 1.5.0
    ├── NumPy >= 1.21.0
    └── pytz >= 2020.1
```

**충돌 원인**: 각 패키지가 요구하는 의존성 버전 범위가 겹치지 않을 때 설치가 불가능합니다.

### 전통적 해결책의 한계

```bash
# 목적: 의존성 충돌 해결 시도
# 문제점: 시행착오적 접근

pip install biopython==1.79
pip install tensorflow==2.8.0  # NumPy 버전 충돌 발생
pip install pandas==1.5.0      # 추가 버전 충돌 발생
pip uninstall numpy
pip install numpy==1.21.5      # 수동 버전 조정
```

**문제**: 수동적이고 시행착오적인 해결 과정으로 시간이 오래 걸리고 불안정합니다.

## 3.2 함수형 프로그래밍 핵심 개념

### 불변성 (Immutability)

**정의**: 한 번 생성된 데이터는 변경할 수 없습니다.

```python
# 목적: 불변성 개념 이해
# 핵심 개념: 원본 보존, 새 객체 생성

# 문제가 있는 접근: 원본 데이터 변경
data = [1, 2, 3]
data.append(4)  # 원본이 변경됨
print(data)     # [1, 2, 3, 4] - 원본 손실

# 불변성 접근: 새로운 데이터 생성
original_data = [1, 2, 3]
new_data = original_data + [4]  # 새로운 리스트 생성
print(original_data)  # [1, 2, 3] - 원본 보존
print(new_data)       # [1, 2, 3, 4] - 새 데이터
```

**Nix에서의 불변성**:

```nix
# 목적: 패키지 환경의 불변성 보장
# 핵심 개념: 한 번 정의된 것은 변경 불가
let
  pythonVersion = "38";
  # pythonVersion = "39";  # 오류! 재할당 불가능
in {
  buildInputs = [ pkgs.python38 ];  # 항상 같은 버전
}
```

### 순수 함수 (Pure Functions)

**정의**: 같은 입력에 대해 항상 같은 출력을 반환하며, 부작용이 없는 함수입니다.

```python
# 목적: 순수 함수와 비순수 함수 비교
# 핵심 개념: 예측 가능성, 부작용 없음

# 비순수 함수: 외부 상태에 의존
counter = 0
def impure_increment(x):
    global counter
    counter += 1  # 외부 상태 변경
    return x + counter

# 같은 입력이지만 다른 결과
result1 = impure_increment(5)  # 6
result2 = impure_increment(5)  # 7

# 순수 함수: 외부 상태 독립
def pure_increment(x, increment):
    return x + increment

# 같은 입력은 항상 같은 결과
result1 = pure_increment(5, 1)  # 6
result2 = pure_increment(5, 1)  # 6
```

**Nix에서의 순수 함수**:

```nix
# 목적: 결정론적 환경 빌드
# 핵심 개념: 같은 입력 → 같은 출력
buildPythonEnv = pythonVersion: packages:
  pkgs."python${pythonVersion}".withPackages (ps:
    map (pkg: ps.${pkg}) packages
  );

# 같은 입력은 항상 같은 환경 생성
env1 = buildPythonEnv "38" ["pandas" "numpy"];
env2 = buildPythonEnv "38" ["pandas" "numpy"];
# env1과 env2는 완전히 동일
```

### 참조 투명성 (Referential Transparency)

**정의**: 표현식을 그 결과값으로 바꿔도 프로그램 동작이 변하지 않는 성질입니다.

```nix
# 목적: 참조 투명성 확인
# 핵심 개념: 표현식과 값의 교환 가능성
let
  pythonVersion = "38";
  pythonPackage = pkgs."python${pythonVersion}";
in {
  # 다음 두 표현은 완전히 동일
  buildInputs = [ pythonPackage ];
  buildInputs = [ pkgs.python38 ];  # 직접 참조로 교체 가능
}
```

## 3.3 의존성 해결의 함수형 접근

### 격리된 환경 구성

```nix
# 목적: 서로 다른 프로젝트 간 완전 격리
# 핵심 개념: 환경 독립성

# tensorflow-env.nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.tensorflow
    python38Packages.numpy  # 자동으로 호환 버전 선택
  ];
}

# pandas-env.nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.pandas
    python38Packages.numpy  # 다른 버전 사용 가능
  ];
}
```

### 조합 가능한 환경 설계

```nix
# 목적: 재사용 가능한 환경 구성 요소 정의
# 핵심 개념: 함수 조합, 모듈화
let
  basePython = pkgs.python38;

  # 도구별 패키지 그룹
  dataTools = ps: with ps; [ pandas numpy matplotlib ];
  mlTools = ps: with ps; [ tensorflow scikit-learn ];
  bioTools = ps: with ps; [ biopython ];

in {
  # 필요에 따라 조합
  dataEnv = basePython.withPackages dataTools;
  mlEnv = basePython.withPackages mlTools;

  # 전체 환경 (자동 호환성 해결)
  fullEnv = basePython.withPackages (ps:
    dataTools ps ++ mlTools ps ++ bioTools ps
  );
}
```

## 3.4 재현 가능한 환경 관리

### 정확한 버전 고정

```nix
# 목적: 완전한 재현성 보장
# 핵심 개념: 소스 고정, 버전 명시
{ pkgs ? import (fetchTarball {
    # 특정 nixpkgs 커밋 고정
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
  ];
}
```

### 환경 간 호환성 보장

```nix
# 목적: 복합 의존성 자동 해결
# 핵심 개념: 의존성 그래프 계산
let
  pythonEnv = pkgs.python38.withPackages (ps: with ps; [
    # Nix가 자동으로 호환 가능한 버전 조합 계산
    biopython    # NumPy 1.21.x 요구
    tensorflow   # NumPy 1.20.x-1.23.x 요구
    pandas       # NumPy 1.21.x+ 요구
    # 결과: NumPy 1.21.x가 자동 선택됨
  ]);
in pkgs.mkShell {
  buildInputs = [ pythonEnv ];
}
```

## 3.5 함수형 vs 명령형 패키지 관리 비교

### 특성 비교

| 특성            | 명령형 (pip/conda) | 함수형 (Nix)      |
| --------------- | ------------------ | ----------------- |
| **의존성 해결** | 수동, 시행착오적   | 자동, 수학적 계산 |
| **환경 격리**   | 부분적 (가상환경)  | 완전 격리         |
| **재현성**      | 시점 의존적        | 항상 동일         |
| **롤백**        | 복잡한 수동 과정   | 즉시 가능         |
| **환경 공유**   | 문서 + 설치 과정   | 설정 파일 하나    |
| **병렬 버전**   | 어려움             | 자연스럽게 지원   |

### 실제 작업 효율성

```text
새로운 분석 환경 구성 시간:

명령형 방식:
- 가상환경 생성: 5분
- 패키지 설치 시도: 30분
- 의존성 충돌 해결: 2시간
- 문서화: 30분
총 시간: 3시간 5분

함수형 방식 (Nix):
- shell.nix 작성: 10분
- nix-shell 실행: 5분
총 시간: 15분
```

## 3.6 실무 적용 사례

### 프로젝트별 환경 관리

```bash
# 목적: 프로젝트 간 완전한 환경 격리
# 핵심 개념: 독립성, 재현성

# 프로젝트 A: 기계학습
cd project-ml
nix-shell  # TensorFlow 환경 자동 구성

# 프로젝트 B: 웹 개발
cd project-web
nix-shell  # Flask 환경 자동 구성

# 두 환경이 서로 간섭하지 않음
```

### 팀 협업 워크플로우

```bash
# 목적: 팀 전체 환경 일관성 보장
# 핵심 개념: 버전 관리 통합

git clone https://github.com/team/project.git
cd project
nix-shell  # 모든 팀원이 동일한 환경 즉시 구성
python run_analysis.py  # 즉시 작업 시작 가능
```

---

**요약**: 함수형 프로그래밍의 불변성, 순수 함수, 참조 투명성은 의존성 관리에서 예측 가능하고 재현 가능한 환경을 보장합니다. Nix는 이 원리들을 통해 복잡한 의존성 충돌을 자동으로 해결합니다.
