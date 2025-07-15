# Chapter 1: Nix 이해를 위한 기초

## 1.1 소프트웨어 의존성 관리의 문제

### 의존성 충돌 문제

소프트웨어 개발에서 패키지 의존성 관리는 복잡한 문제입니다. 다음 상황을 고려해보겠습니다:

```bash
$ python protein_analysis.py
ModuleNotFoundError: No module named 'biopython'

$ pip install biopython
$ python protein_analysis.py
ImportError: pandas version 1.5.0 required, but you have 2.1.0

$ pip install pandas==1.5.0
ERROR: tensorflow 2.10.0 requires numpy>=1.20.0,<1.24.0,
       but pandas 1.5.0 requires numpy>=1.21.0
```

### 의존성 그래프의 복잡성

현대 소프트웨어는 다수의 라이브러리에 의존하며, 각 라이브러리는 서로 다른 버전 요구사항을 가집니다:

```text
프로젝트: 데이터 분석
├── Python 3.8
├── BioPython 1.79 → NumPy >= 1.17.0
├── TensorFlow 2.8.0 → NumPy >= 1.20.0, < 1.24.0
└── Pandas 1.5.0 → NumPy >= 1.21.0
```

이러한 의존성 충돌은 다음 문제들을 야기합니다:

- **버전 불일치**: 서로 다른 패키지가 요구하는 의존성 버전이 충돌
- **환경 오염**: 시스템 전역 패키지 설치로 인한 기존 환경 파괴
- **재현성 부족**: 시간과 환경에 따라 다른 패키지 버전 설치

### 기존 도구들의 한계

**가상환경 기반 도구 (conda, virtualenv)**:

- 환경 파일의 시간에 따른 변화
- 시스템 라이브러리 의존성 미해결
- 환경 복제 시 미묘한 차이 발생

**컨테이너 기반 도구 (Docker)**:

- 높은 용량과 복잡한 설정
- 개발 도구 통합의 어려움
- 플랫폼별 호환성 문제

## 1.2 Nix의 해결 접근법

### 함수형 패키지 관리

Nix는 **함수형 프로그래밍** 원리를 패키지 관리에 적용하여 재현성을 보장합니다:

```nix
# 목적: 분석 환경 정의
# 핵심 개념: 선언적 환경 구성
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.biopython
    python38Packages.pandas
    python38Packages.tensorflow
  ];
}
```

### 핵심 원리

- **불변성 (Immutability)**: 설치된 패키지는 절대 변경되지 않습니다.
- **격리 (Isolation)**: 각 프로젝트는 독립된 환경을 가집니다.
- **결정론적 빌드 (Deterministic Build)**: 같은 설정은 항상 같은 환경을 생성합니다.

### 실행 결과

```bash
$ nix-shell analysis-env.nix
[nix-shell]$ python --version
Python 3.8.16

[nix-shell]$ python -c "import pandas; print(pandas.__version__)"
1.5.3
```

동일한 설정 파일로 6개월 후에도 정확히 같은 환경이 구성됩니다.

## 1.3 Nix의 핵심 가치

### 완전한 재현성

**문제**: 기존 도구는 시점에 따라 다른 환경을 만듭니다.
**해결**: Nix는 설정 파일로 환경을 완전히 결정합니다.

```bash
# 언제든지 동일한 환경
$ nix-shell
[nix-shell]$ python analysis.py  # 항상 같은 결과
```

### 안전한 실험 환경

**문제**: 새로운 도구 시험이 기존 환경을 파괴할 수 있습니다.
**해결**: Nix는 완전히 격리된 임시 환경을 제공합니다.

```bash
# 임시 환경에서 새 버전 테스트
$ nix-shell -p python39 python39Packages.scikit-learn
[nix-shell]$ python  # 새 버전으로 테스트

$ exit  # 기존 환경 복귀
$ python --version  # 기존 환경 그대로 유지
```

### 효율적 팀 협업

**문제**: 팀원별로 다른 환경 설정으로 인한 비일관성
**해결**: 환경 설정을 코드와 함께 버전 관리

```bash
$ git clone https://github.com/team/project.git
$ cd project
$ nix-shell  # 5분 내 동일한 환경 구성
[nix-shell]$ python run_analysis.py
```

## 1.4 Nix 생태계 구조

### 구성 요소

```text
┌─────────────────────────────────────────┐
│               nixpkgs                   │  ← 120,000+ 패키지 저장소
│        (Package Collection)             │
├─────────────────────────────────────────┤
│            Nix Language                 │  ← 설정 정의 언어
│         (Configuration DSL)             │
├─────────────────────────────────────────┤
│             Nix Store                   │  ← 불변 패키지 저장소
│         (/nix/store/...)                │
└─────────────────────────────────────────┘
```

### 주요 도구들

**개발 환경**: Python, R, Node.js, Java 등 모든 주요 언어
**과학 계산**: NumPy, TensorFlow, PyTorch, Jupyter
**데이터 과학**: Pandas, Matplotlib, R packages
**시스템 도구**: Git, Docker, 편집기, 빌드 도구

## 1.5 학습 목표와 구조

### 이 장에서 다룰 내용

- **Chapter 1.2**: 프로그래밍 패러다임 - 명령형과 함수형 접근법 비교
- **Chapter 1.3**: 함수형 프로그래밍 - 불변성, 순수함수, 참조투명성
- **Chapter 1.4**: 속성집합 - Nix의 데이터 구조와 설정 관리
- **Chapter 1.5**: Nix 기초 - 설치, 문법, 기본 명령어
- **Chapter 1.6**: 핵심 개념 - Derivation, Nix Store, 동작 원리

### 학습 후 달성 목표

**즉시 활용**:

- 재현 가능한 개발 환경 구성
- 프로젝트별 도구 격리 관리
- 팀 환경 설정 공유

**심화 활용**:

- 복잡한 의존성 관계 해결
- 시스템 레벨 환경 관리
- CI/CD 파이프라인 통합

### 필요한 배경 지식

**필수**:

- 기본 터미널 사용법
- 텍스트 파일 편집
- 프로그래밍 언어 경험 (Python, JavaScript 등)

**권장**:

- 패키지 관리자 사용 경험 (pip, npm, apt 등)
- 가상환경 개념 이해
- Git 기본 사용법

## 1.6 간단한 시작 예제

### 즉시 실행 가능한 예제

Nix가 설치되어 있다면 다음을 시도해볼 수 있습니다:

```bash
# 목적: Python 데이터 분석 환경 즉시 생성
# 핵심 개념: 임시 환경, 패키지 격리

$ nix-shell -p python3 python3Packages.pandas python3Packages.matplotlib

[nix-shell]$ python3 -c "
import pandas as pd
import matplotlib.pyplot as plt
data = pd.DataFrame({'x': [1,2,3], 'y': [2,4,6]})
print('환경 구성 완료:', data.sum())
"
```

### 다음 단계

다음 장에서는 Nix가 **왜** 함수형 접근법을 채택했는지, 명령형 접근법과 **어떤** 차이가 있는지 살펴보겠습니다.

---

**요약**: Nix는 함수형 패키지 관리를 통해 의존성 충돌과 재현성 문제를 해결합니다. 불변성과 격리를 통해 안정적이고 예측 가능한 개발 환경을 제공합니다.
