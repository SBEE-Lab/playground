# 2.1 Programming Paradigms

## 핵심 개념

프로그래밍 패러다임은 문제를 해결하는 사고방식입니다. 명령형은 "어떻게(How)" 할지 단계를 지시하고, 함수형은 "무엇을(What)" 원하는지 선언합니다. 패키지 관리에서 이 차이는 안정성과 재현성에 결정적 영향을 미칩니다.

### 명령형 프로그래밍: "어떻게(How)" 중심

명령형 프로그래밍은 컴퓨터에게 작업을 수행할 구체적인 단계를 순서대로 지시하는 방식입니다. 변수의 상태를 지속적으로 변경하며 원하는 결과에 도달합니다.

**핵심 특징**:

- **순차적 실행**: 명령어를 위에서 아래로 차례대로 실행
- **상태 변경**: 변수와 메모리 상태를 지속적으로 수정
- **제어 구조**: if, for, while 등으로 실행 흐름 제어
- **부작용**: 함수 실행이 외부 상태에 영향을 미침

```python
# 명령형 방식: 평균 계산 과정
numbers = [245, 189, 567, 123, 445]
total = 0
count = 0

# 단계별로 상태를 변경
for number in numbers:
    total = total + number    # 상태 변경
    count = count + 1         # 상태 변경
    print(f"단계 {count}: 합계={total}")

average = total / count
print(f"최종 평균: {average}")
```

실행 과정에서 변수들의 상태가 계속 변화합니다:

```text
단계 1: 합계=245
단계 2: 합계=434
단계 3: 합계=1001
단계 4: 합계=1124
단계 5: 합계=1569
최종 평균: 313.8
```

### 명령형 패키지 관리의 문제점

전통적인 패키지 관리자들(pip, conda, apt)은 명령형 접근법을 사용합니다. 시스템 상태를 단계적으로 변경하여 원하는 환경을 구성합니다.

```bash
# 명령형 패키지 관리 예시
conda create -n analysis python=3.8    # 환경 생성
conda activate analysis                 # 환경 활성화
pip install biopython==1.78            # 패키지 설치 (시스템 상태 변경)
pip install pandas==1.5.0              # 또 다른 패키지 설치 (상태 변경)
pip install tensorflow==2.8.0          # 의존성 충돌 가능성
```

**발생 가능한 문제들**:

1. **시점 의존성**: 설치 시점에 따라 다른 버전의 의존성이 설치됨

```bash
# 2023년 3월 실행
$ pip install requests
Successfully installed requests-2.28.2 urllib3-1.26.15

# 2023년 8월 실행 (같은 명령어, 다른 결과)
$ pip install requests
Successfully installed requests-2.31.0 urllib3-2.0.4
```

2. **상태 오염**: 새로운 패키지 설치가 기존 환경을 변경

```bash
$ pip install package_a  # numpy 1.21.0 설치됨
$ pip install package_b  # numpy 1.23.0으로 업그레이드됨
# package_a가 의존하던 numpy 1.21.0 사라짐
```

3. **불완전한 롤백**: 이전 상태로 완전한 복원이 어려움

```bash
$ pip uninstall package_b
# numpy는 1.23.0 그대로 남음
# package_a는 1.21.0을 기대하지만 다른 버전 사용
```

### 함수형 프로그래밍: "무엇을(What)" 중심

함수형 프로그래밍은 원하는 결과를 함수들의 조합으로 선언적으로 표현하는 방식입니다. 상태 변경 없이 입력을 출력으로 변환하는 순수 함수들을 조합합니다.

**핵심 특징**:

- **불변성**: 생성된 값은 절대 변경되지 않음
- **순수 함수**: 같은 입력에 항상 같은 출력, 부작용 없음
- **선언적**: 과정보다는 결과를 선언
- **조합성**: 작은 함수들을 조합하여 복잡한 작업 수행

```python
# 함수형 방식: 평균 계산
numbers = [245, 189, 567, 123, 445]

# 중간 상태 변경 없이 직접 계산
average = sum(numbers) / len(numbers)
print(f"평균: {average}")

# 또는 함수 조합으로
from statistics import mean
average = mean(numbers)
print(f"평균: {average}")
```

함수형 방식에서는 중간 상태 변경 없이 입력에서 출력으로 직접 변환됩니다.

### 함수형 패키지 관리의 장점

Nix는 함수형 접근법을 패키지 관리에 적용합니다. 환경을 상태 변경이 아닌 함수의 결과로 취급합니다.

```nix
# 함수형 패키지 관리: 환경을 선언적으로 정의
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python38                    # 정확한 버전 지정
    python38Packages.biopython # 호환성 보장된 버전
    python38Packages.pandas    # 자동 의존성 해결
    python38Packages.tensorflow
  ];
}
```

**함수형 접근법의 장점**:

1. **결정론적**: 같은 입력(설정)은 항상 같은 출력(환경) 생성
2. **불변성**: 기존 환경을 변경하지 않고 새로운 환경 생성
3. **안전한 실험**: 새 환경 테스트가 기존 환경에 영향 없음
4. **완전한 롤백**: 이전 환경으로 즉시 완전 복원

### 패러다임 비교: 실제 시나리오

생물정보학 연구에서 자주 발생하는 시나리오를 통해 두 패러다임의 차이를 살펴보겠습니다.

**시나리오**: RNA-seq 분석을 위해 Python 환경에 여러 패키지를 설치해야 하는 상황

**명령형 접근법**:

```bash
# 단계별 환경 구성 (상태 변경)
conda create -n rnaseq python=3.8
conda activate rnaseq
pip install pandas==1.5.0       # 시스템 상태 변경
pip install numpy==1.21.0       # 의존성 추가
pip install scikit-learn         # numpy 버전 충돌 가능성
pip install matplotlib          # 추가 의존성 설치

# 문제 발생 시
pip uninstall scikit-learn      # 부분적 롤백
# numpy, matplotlib은 변경된 상태로 남음
```

**함수형 접근법**:

```nix
# 전체 환경을 하나의 함수로 정의
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.pandas      # 호환성 보장
    python38Packages.numpy       # 정확한 버전 자동 선택
    python38Packages.scikit-learn # 의존성 자동 해결
    python38Packages.matplotlib
  ];
}
```

### 재현성 관점에서의 차이

**명령형의 재현성 문제**:

- 시간에 따른 패키지 저장소 변화
- 설치 순서에 따른 결과 차이
- 시스템 상태에 따른 영향

**함수형의 재현성 보장**:

- 입력이 같으면 결과도 항상 동일
- 시점과 무관한 일관된 환경
- 완전한 의존성 추적

```nix
# 완전한 재현성을 위한 버전 고정
{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/22.11.tar.gz";
    sha256 = "11w3wn2yjhaa5pv20gbfbirvjq6i3m7pqrq2msf0g7cv44vijwgw";
  }) {}
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python38                     # 정확히 Python 3.8.16
    python38Packages.biopython  # 정확히 BioPython 1.79
    python38Packages.pandas     # 정확히 Pandas 1.5.3
  ];
}
```

## Practice Section: 패러다임 차이 체험

### 실습 1: 명령형 패키지 관리 시뮬레이션

```bash
# 전통적인 방식의 문제점 확인
echo "=== 명령형 패키지 관리 시뮬레이션 ==="

# 가상의 패키지 설치 과정 시뮬레이션
echo "1. 기본 Python 환경"
echo "   python: 3.8.0"
echo "   pip 패키지: 없음"

echo -e "\n2. pandas 설치 후"
echo "   python: 3.8.0"
echo "   pandas: 1.5.0"
echo "   numpy: 1.21.0 (pandas 의존성)"

echo -e "\n3. tensorflow 설치 후"
echo "   python: 3.8.0"
echo "   pandas: 1.5.0"
echo "   numpy: 1.23.0 (tensorflow가 요구하는 버전으로 업그레이드)"
echo "   tensorflow: 2.8.0"
echo "   WARNING: pandas가 기대하던 numpy 버전 변경됨"

echo -e "\n4. 문제 발생"
echo "   pandas 일부 기능이 새로운 numpy 버전과 호환성 문제"
```

### 실습 2: Nix 함수형 접근 체험

```bash
# 함수형 패키지 관리 체험
echo "=== Nix 함수형 접근법 ==="

# 기본 분석 환경 정의
cat > analysis-env.nix << 'EOF'
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    python3Packages.pandas
    python3Packages.numpy
  ];

  shellHook = ''
    echo "기본 분석 환경"
    echo "Python: $(python --version)"
    python -c "import pandas; print(f'Pandas: {pandas.__version__}')"
  '';
}
EOF

echo "기본 환경 정의 완료"
echo "실행: nix-shell analysis-env.nix"
```

### 실습 3: 환경 격리 확인

```bash
# 다른 환경 정의
cat > ml-env.nix << 'EOF'
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    python3Packages.tensorflow
    python3Packages.scikit-learn
    python3Packages.numpy
  ];

  shellHook = ''
    echo "머신러닝 환경"
    echo "TensorFlow와 scikit-learn 포함"
    python -c "
try:
    import tensorflow as tf
    print(f'TensorFlow: {tf.__version__}')
except:
    print('TensorFlow 사용 불가')
"
  '';
}
EOF

echo "머신러닝 환경 정의 완료"
echo "두 환경이 서로 영향을 주지 않음을 확인할 수 있습니다"
```

### 실습 4: 재현성 테스트

```bash
# 재현 가능한 환경 정의
cat > reproducible-env.nix << 'EOF'
{ pkgs ? import (fetchTarball {
    # 특정 nixpkgs 버전 고정
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-23.11.tar.gz";
    sha256 = "1ndiv385w1qyb3b18vw13991fzb9wg4cl21wglk89grsfsnra41k";
  }) {}
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python3                    # 정확한 버전 고정
    python3Packages.biopython
    python3Packages.pandas
  ];

  shellHook = ''
    echo "재현 가능한 환경"
    echo "언제 실행해도 동일한 패키지 버전"
    python --version
  '';
}
EOF

echo "재현 가능한 환경 정의 완료"
echo "이 환경은 1년 후에도 동일한 결과를 보장합니다"
```

### 실습 5: 함수 조합 패턴

```bash
# 재사용 가능한 환경 구성 요소
cat > composable-env.nix << 'EOF'
{ pkgs ? import <nixpkgs> {} }:

let
  # 기본 Python 환경
  basePython = pkgs.python3;

  # 패키지 그룹들
  dataPackages = ps: with ps; [ pandas numpy matplotlib ];
  bioPackages = ps: with ps; [ biopython ];
  mlPackages = ps: with ps; [ scikit-learn ];

in {
  # 조합으로 다양한 환경 생성
  dataEnv = basePython.withPackages dataPackages;

  bioEnv = basePython.withPackages (ps:
    dataPackages ps ++ bioPackages ps
  );

  fullEnv = basePython.withPackages (ps:
    dataPackages ps ++ bioPackages ps ++ mlPackages ps
  );
}
EOF

echo "조합 가능한 환경 정의 완료"
echo "작은 구성 요소들을 조합하여 다양한 환경 생성"
```

## 핵심 정리

### 패러다임 비교 요약

| 특성       | 명령형 (전통적) | 함수형 (Nix) |
| ---------- | --------------- | ------------ |
| **접근법** | 단계별 명령     | 선언적 정의  |
| **상태**   | 가변, 변경됨    | 불변, 보존됨 |
| **재현성** | 시점 의존적     | 항상 동일    |
| **롤백**   | 부분적, 복잡    | 완전, 즉시   |
| **격리**   | 불완전          | 완전         |
| **실험**   | 위험            | 안전         |

### 실무 선택 가이드

```nix
# 함수형 패키지 관리가 적합한 경우
# - 재현성이 중요한 연구
# - 여러 프로젝트 동시 진행
# - 팀 협업 환경
# - 장기간 유지보수

# 간단한 환경 정의 예시
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    python3Packages.requests
  ];
}
```

**다음**: [2.2 Functional Programming](./ch02-2-functional-programming.md)
