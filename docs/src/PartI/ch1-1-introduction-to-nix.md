# Chapter 1: Nix 이해를 위한 기초

## 1.1 연구 환경 관리의 문제

### 연구실에서

당신이 연구실에 합류했습니다. 당신은 오래 전 졸업한 선배가 작성한 단백질 분석 코드를 실행해보려고 합니다.

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

두 시간 후에도, 두 달 뒤에도 여전히 이 코드는 실행되지 않습니다.

### 의존성 충돌

**문제의 본질**: 서로 다른 패키지들이 요구하는 라이브러리 버전이 충돌합니다.

```text
프로젝트 A: Python 3.8 + biopython 1.78 + pandas 1.3.0
프로젝트 B: Python 3.10 + biopython 1.81 + pandas 2.0.0
프로젝트 C: Python 3.9 + tensorflow 2.10 + numpy 1.23.0
```

한 컴퓨터에서 이 모든 조합을 동시에 관리하는 것은 불가능합니다.

### 기존 해결책들의 한계

**conda/mamba**:

- 환경 파일이 시간에 따라 변화
- 패키지 저장소 변경으로 인한 설치 실패
- 환경 복제시 미묘한 차이 발생

**Docker**:

- 용량이 크고 설정이 복잡
- 개발 도구 설치가 번거로움
- GUI 애플리케이션 실행 어려움

**pip + virtualenv**:

- 시스템 라이브러리 의존성 해결 불가
- Python 버전 관리 별도 필요
- 패키지 외 도구들(R, 명령행 도구) 관리 어려움

## 1.2 Nix가 제시하는 해법

### 완전한 재현성

Nix는 **함수형 패키지 관리**를 통해 재현성을 보장합니다.

```nix
# analysis-env.nix
{ pkgs ? import <nixpkgs> {} }:     # 이 부분이 함수의 입력입니다.

# 아래 블럭이 이 함수의 출력입니다.
pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.biopython
    python38Packages.pandas
    python38Packages.matplotlib
  ];
}
```

```bash
# 어느 컴퓨터에서든 동일한 환경
$ nix-shell analysis-env.nix
[nix-shell]$ python --version
Python 3.8.16

[nix-shell]$ python -c "import pandas; print(pandas.__version__)"
1.5.3
```

6개월 후에도, 다른 연구자의 컴퓨터에서도 정확히 같은 결과가 나옵니다.

### 핵심 원리

**불변성(Immutability)**: 한 번 설치된 패키지는 절대 변경되지 않습니다.
**격리(Isolation)**: 각 프로젝트는 완전히 독립된 환경을 가집니다.
**결정론적 빌드(Deterministic Build)**: 같은 설정으로는 항상 같은 환경이 만들어집니다.

## 1.3 연구자 관점에서의 장점

### 실험 재현성 확보

```bash
# 논문과 함께 환경 설정 파일 공유
$ git clone https://github.com/lab/protein-study.git
$ cd protein-study
$ nix-shell
[nix-shell]$ python run_analysis.py
# 논문과 정확히 같은 결과 획득
```

### 안전한 환경 실험

```bash
# 새로운 도구 시험해보기
$ nix-shell -p python39 python39Packages.scikit-learn
[nix-shell]$ python  # 새로운 버전으로 테스트

$ exit  # 원래 환경으로 복귀
$ python --version  # 기존 환경은 그대로
```

### 팀 협업 효율성

**기존 방식**:

- 환경 설정 문서가 계속 변경됨
- 새로운 팀원의 환경 구성에 반나절 소요

**Nix 방식**:

- 환경 설정 파일 하나로 모든 것 해결
- 설정 파일이 코드와 함께 버전 관리
- 5분 만에 완전히 동일한 환경 구성

## 1.4 Nix 생태계 개요

### 구성 요소

```text
┌─────────────────────────────────────────┐
│               nixpkgs                   │  ← 30만개+ 패키지 저장소
│        (Package Collection)             │
├─────────────────────────────────────────┤
│            Nix Language                 │  ← 설정 언어
│         (Configuration DSL)             │
├─────────────────────────────────────────┤
│             Nix Store                   │  ← 패키지 저장소
│         (/nix/store/...)                │
└─────────────────────────────────────────┘
```

### 연구에서 활용할 수 있는 도구들

**기초 도구**:

- Python, R, Julia
- pandas, matplotlib, ggplot2
- Jupyter notebook

**생물정보학 도구**:

- biopython, bioconductor
- BLAST, Clustal, MUSCLE
- FastQC, samtools, bcftools

**데이터 과학 도구**:

- scikit-learn, tensorflow, pytorch
- 통계 분석 패키지
- 데이터베이스 클라이언트

## 1.5 학습 로드맵

### 이 튜토리얼에서 배울 내용

**Chapter 1 (현재)**: Nix의 가치 제안과 기본 개념

**Chapter 2**: 함수형 접근법의 이해

**Chapter 3**: 함수형 프로그래밍 심화

**Chapter 4**: 설정을 데이터로 관리하기

**Chapter 5**: 실제 환경 구성 실습

**Chapter 6**: 시스템 동작 원리 이해

### 학습 후 달성 목표

**즉시 활용**:

- 재현 가능한 분석 환경 구성
- 프로젝트별 도구 관리
- 팀원과 환경 설정 공유

**장기 활용**:

- 연구 인프라 자동화
- 복잡한 분석 파이프라인 관리
- 논문 재현성 패키지 제작

### 필요한 배경 지식

**필수**:

- 기본적인 터미널 사용법
- 텍스트 파일 편집
- 간단한 명령어 실행 경험

**도움이 되는 것**:

- Python 스크립트 실행 경험
- conda/pip 사용 경험
- Git 기본 사용법

## 1.6 간단한 예시

### 빠른 시작

Nix가 설치되어 있다면 바로 시도해볼 수 있습니다:

```bash
# Python 분석 환경 즉시 생성
$ nix-shell -p python3 python3Packages.pandas python3Packages.matplotlib

[nix-shell]$ python3 -c "
import pandas as pd
import matplotlib.pyplot as plt
data = pd.DataFrame({'x': [1,2,3], 'y': [2,4,6]})
print('Pandas 작동 확인:', data.sum())
"
```

### 다음 단계

이제 Nix가 **왜** 이런 방식으로 동작하는지, **어떻게** 재현성을 보장하는지 알아봅시다.

다음 장에서는 Nix의 **함수형 프로그래밍 패러다임**을 탐구하여 기존 도구들과의 근본적 차이점을 이해하겠습니다.

---

**요약**: Nix는 연구 환경의 재현성 문제를 함수형 패키지 관리로 해결합니다. 실험 프로토콜을 문서화하듯이 컴퓨팅 환경을 코드로 정의하여 언제든 동일한 환경을 재구성할 수 있습니다.
