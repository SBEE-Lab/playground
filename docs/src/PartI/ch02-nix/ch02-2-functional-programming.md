# 2.2 Functional Programming Fundamentals

## 핵심 개념

함수형 프로그래밍의 핵심 원리인 불변성, 순수 함수, 참조 투명성은 패키지 관리에서 예측 가능하고 재현 가능한 환경을 보장합니다. Nix는 이러한 원리를 통해 의존성 충돌과 환경 불일치 문제를 근본적으로 해결합니다.

### 불변성 (Immutability)

불변성은 한 번 생성된 데이터를 절대 변경하지 않는 원칙입니다. 전통적인 패키지 관리에서는 시스템 전역 상태가 지속적으로 변경되어 예측 불가능한 결과를 초래하지만, Nix는 불변성을 통해 이 문제를 해결합니다.

```bash
# 전통적 방식: 상태 변경으로 인한 문제
pip install numpy==1.21.0        # 시스템 상태 변경
pip install tensorflow==2.8.0     # numpy가 1.23.0으로 업그레이드됨
python analyze.py                 # 기존 코드가 다른 numpy 버전으로 실행됨 - 예측 불가능
```

Nix의 불변성 구현:

```nix
# Nix Store에서의 불변성
# /nix/store/abc123...numpy-1.21.0/  - 절대 변경되지 않음
# /nix/store/def456...numpy-1.23.0/  - 새로운 경로에 설치
# 두 버전이 동시에 존재하며 서로 간섭하지 않음

# 환경 정의에서의 불변성
let pythonVersion = "38";
in {
  # pythonVersion = "39";  # 오류! 재할당 불가능
  environment = {
    python = "python${pythonVersion}";
    packages = ["numpy" "pandas"];  # 리스트도 불변
  };
}
```

불변성의 실제 활용:

```nix
# 환경 버전 관리
let
  version_2023_01 = {
    python = "38";
    numpy = "1.21.0";
    tensorflow = "2.8.0";
  };

  version_2023_06 = {
    python = "38";
    numpy = "1.23.0";
    tensorflow = "2.11.0";
  };
in {
  # 두 환경이 동시에 존재, 서로 간섭 없음
  old_analysis = buildEnv version_2023_01;    # 기존 분석 재현
  new_analysis = buildEnv version_2023_06;    # 새로운 분석
}
```

### 순수 함수 (Pure Functions)

순수 함수는 동일한 입력에 대해 항상 동일한 출력을 반환하며, 외부 상태를 변경하지 않습니다. Nix의 모든 빌드 과정은 순수 함수로 설계되어 완전한 재현성을 보장합니다.

```python
# 순수 함수와 비순수 함수 비교
import random
import time

# 비순수 함수: 같은 입력이지만 다른 출력
def impure_analysis(data):
    seed = int(time.time())  # 현재 시간에 의존
    random.seed(seed)
    noise = random.random()   # 매번 다른 값
    return sum(data) + noise

result1 = impure_analysis([1, 2, 3])  # 6.123...
result2 = impure_analysis([1, 2, 3])  # 6.789... (다른 결과)

# 순수 함수: 같은 입력은 항상 같은 출력
def pure_analysis(data, seed=42):
    random.seed(seed)        # 고정된 시드
    noise = random.random()   # 항상 같은 값
    return sum(data) + noise

result1 = pure_analysis([1, 2, 3])  # 6.6394...
result2 = pure_analysis([1, 2, 3])  # 6.6394... (같은 결과)
```

Nix에서의 순수 함수 구현:

```nix
# 환경 빌드 함수 - 순수 함수
buildPythonEnv = { python, packages, version ? "stable" }:
  python.withPackages (ps:
    map (pkg: ps.${pkg}) packages
  );

# 같은 입력은 항상 같은 출력
env1 = buildPythonEnv {
  python = pkgs.python38;
  packages = ["numpy" "pandas"];
};

env2 = buildPythonEnv {
  python = pkgs.python38;
  packages = ["numpy" "pandas"];
};

# env1과 env2는 완전히 동일한 환경
# 시점, 시스템 상태와 무관하게 항상 같은 결과
```

의존성 해결의 순수성:

```nix
# 의존성 해결 함수 - 수학적으로 결정론적
resolveDependencies = packages:
  let
    # 모든 의존성을 수집하고 버전 호환성 계산
    allDeps = flattenDependencies packages;
    compatible = filterCompatible allDeps;
    resolved = solveVersionConstraints compatible;
  in resolved;

# 같은 패키지 리스트는 항상 같은 의존성 해결 결과
tensorflow_deps = resolveDependencies ["tensorflow" "numpy" "pandas"];
# 언제 실행해도 같은 버전 조합이 선택됨
```

### 참조 투명성 (Referential Transparency)

참조 투명성은 표현식을 그 결과값으로 교체해도 프로그램의 동작이 변하지 않는 성질입니다. Nix에서는 모든 패키지 참조가 참조 투명성을 만족합니다.

```nix
# 참조 투명성 예제
let
  pythonVersion = "38";
  pythonPackage = pkgs."python${pythonVersion}";
  numpyPackage = pkgs.python38Packages.numpy;
in {
  # 다음 표현들은 모두 동등하며 교체 가능
  environment1 = {
    buildInputs = [ pythonPackage numpyPackage ];
  };

  environment2 = {
    buildInputs = [ pkgs.python38 pkgs.python38Packages.numpy ];
  };

  environment3 = {
    buildInputs = [ pkgs."python38" pkgs.python38Packages."numpy" ];
  };

  # 모든 environment는 완전히 동일
}
```

표현식 치환의 안전성:

```nix
# 함수 정의
mkAnalysisEnv = python: ps: python.withPackages ps;

# 사용 방법 1: 함수 호출
env1 = mkAnalysisEnv pkgs.python38 (ps: [ps.numpy ps.pandas]);

# 사용 방법 2: 함수를 인라인으로 치환
env2 = pkgs.python38.withPackages (ps: [ps.numpy ps.pandas]);

# env1과 env2는 완전히 동일 - 참조 투명성
```

### 의존성 관리에서의 함수형 원리 적용

함수형 원리들이 결합되어 복잡한 의존성 문제를 해결하는 방식을 살펴보겠습니다.

```nix
# 복합 환경 구성에서의 함수형 접근
let
  # 기본 도구들 (불변)
  baseTools = ["git" "curl" "wget"];

  # 언어별 패키지 정의 (순수 함수)
  pythonPackages = ps: with ps; [numpy pandas matplotlib];
  rPackages = rps: with rps; [ggplot2 dplyr tidyr];

  # 환경 조합 함수 (참조 투명)
  combineEnvs = python: r: basePackages:
    let
      pythonEnv = python.withPackages pythonPackages;
      rEnv = r.withPackages rPackages;
    in basePackages ++ [pythonEnv rEnv];

in {
  # 다양한 환경 조합 - 모두 예측 가능하고 재현 가능
  dataScience = combineEnvs pkgs.python38 pkgs.R baseTools;
  machineLearning = combineEnvs pkgs.python39 pkgs.R (baseTools ++ ["docker"]);

  # 환경 간 격리 보장 - 서로 간섭하지 않음
  oldProject = combineEnvs pkgs.python37 pkgs.R baseTools;
  newProject = combineEnvs pkgs.python310 pkgs.R baseTools;
}
```

### 함수형 vs 명령형 비교

생물정보학 연구 환경에서의 실제 차이점을 구체적으로 살펴보겠습니다.

**명령형 방식의 문제점:**

```bash
# 시간에 따른 환경 변화 (명령형)
# 2023년 1월
conda create -n bioproject python=3.8
conda activate bioproject
conda install biopython=1.79 numpy=1.21.0

# 2023년 6월 - 패키지 추가
conda install tensorflow=2.8.0
# numpy가 자동으로 1.23.0으로 업그레이드됨

# 2023년 12월 - 문제 발생
python old_analysis.py
# 에러: numpy 1.23.0과 호환되지 않는 코드
```

**함수형 방식의 해결:**

```nix
# 환경 정의 (함수형) - 시점 무관 재현성
{ pkgs ? import <nixpkgs> {} }:

let
  # 2023년 1월 환경 정의
  bioproject_v1 = pkgs.python38.withPackages (ps: with ps; [
    biopython   # 1.79
    numpy       # 1.21.0 (자동 호환성 해결)
  ]);

  # 2023년 6월 환경 정의
  bioproject_v2 = pkgs.python38.withPackages (ps: with ps; [
    biopython   # 1.79
    numpy       # 1.21.0 (기존 호환성 유지)
    tensorflow  # 2.8.0
  ]);

in {
  # 두 환경이 동시에 존재
  old_analysis = pkgs.mkShell { buildInputs = [ bioproject_v1 ]; };
  new_analysis = pkgs.mkShell { buildInputs = [ bioproject_v2 ]; };
}
```

## Practice Section: 함수형 원리 실습

### 실습 1: 불변성 확인

```bash
cd ~/bioproject/practice

# Python으로 불변성 개념 확인
cat > immutability_demo.py << 'EOF'
# 가변 객체의 문제
data = [1, 2, 3]
original = data
data.append(4)
print(f"Original: {original}")  # [1, 2, 3, 4] - 의도치 않은 변경

# 불변 접근법
data = [1, 2, 3]
new_data = data + [4]
print(f"Original: {data}")      # [1, 2, 3] - 원본 보존
print(f"New: {new_data}")       # [1, 2, 3, 4] - 새 데이터
EOF

python immutability_demo.py
```

### 실습 2: 순수 함수 비교

```bash
# 순수 함수와 비순수 함수 비교
cat > pure_function_demo.py << 'EOF'
import random

# 비순수 함수
def impure_analyze(sequences):
    random.seed()  # 매번 다른 시드
    noise = random.random()
    return len(sequences) + noise

# 순수 함수
def pure_analyze(sequences, seed=42):
    random.seed(seed)  # 고정 시드
    noise = random.random()
    return len(sequences) + noise

sequences = ["ATCG", "GCTA", "TTAA"]
print("비순수:", impure_analyze(sequences), impure_analyze(sequences))
print("순수:", pure_analyze(sequences), pure_analyze(sequences))
EOF

python pure_function_demo.py
```

### 실습 3: Nix 환경 불변성

```bash
# Nix 환경 불변성 테스트
cat > env_immutable.nix << 'EOF'
{pkgs ? import <nixpkgs> {}}:
let
  baseEnv = ["git" "curl"];
  pythonEnv = pkgs.python38.withPackages (ps: [ps.numpy]);
in {
  environment = baseEnv ++ [pythonEnv];
  # baseEnv는 변경되지 않음 - 불변성
}
EOF

nix eval -f env_immutable.nix --json
```

### 실습 4: 환경 조합

```bash
# 함수형 환경 조합
cat > compose_env.nix << 'EOF'
{pkgs ? import <nixpkgs> {}}:
let
  makeEnv = python: extraPkgs:
    python.withPackages (ps: with ps; [numpy] ++ extraPkgs);

  dataEnv = makeEnv pkgs.python38 (ps: [ps.pandas]);
  mlEnv = makeEnv pkgs.python38 (ps: [ps.scikit-learn]);
in {
  data = dataEnv;
  ml = mlEnv;
}
EOF

nix eval -f compose_env.nix
```

### 실습 5: 참조 투명성 확인

```bash
# 참조 투명성 테스트
cat > reference_transparency.nix << 'EOF'
{pkgs ? import <nixpkgs> {}}:
let
  pythonVer = "38";
  # 다음 두 표현은 완전히 동일
  env1 = pkgs."python${pythonVer}";
  env2 = pkgs.python38;
in {
  same = env1 == env2;  # true - 참조 투명성
  env1_path = env1;
  env2_path = env2;
}
EOF

nix eval -f reference_transparency.nix
```

## 핵심 정리

### 함수형 원리 요약

```nix
# 불변성: 한 번 정의된 값은 변경 불가
let value = "immutable";
in { inherit value; }

# 순수 함수: 같은 입력 → 같은 출력
buildEnv = packages: python.withPackages (ps: packages);

# 참조 투명성: 표현식을 값으로 치환 가능
let pkg = pkgs.python38;
in { env1 = pkg; env2 = pkgs.python38; }  # 동일
```

### 실용적 패턴

```bash
# 환경 격리 패턴
nix-shell env1.nix      # 프로젝트 1
nix-shell env2.nix      # 프로젝트 2 (완전 격리)

# 재현성 보장 패턴
nix-shell --pure env.nix    # 외부 환경 차단
```

**다음**: [2.3 Attribute Sets and Configuration](./ch02-3-attribute-sets.md)
