# Chapter 2: Development Environment with Nix

## 핵심 개념

Nix는 함수형 패키지 관리자로, 재현 가능하고 결정론적인 개발 환경을 제공합니다. 생물정보학 연구에서 중요한 의존성 충돌 해결과 환경 일관성 문제를 근본적으로 해결합니다.

### 소프트웨어 의존성 관리 문제

현대 생물정보학 연구는 수많은 소프트웨어 도구에 의존합니다. Python, R, BLAST, BWA, SAMtools 등 각 도구는 서로 다른 버전의 라이브러리를 요구하며, 이는 복잡한 의존성 충돌을 야기합니다.

```bash
# 전형적인 의존성 충돌 시나리오
$ pip install biopython==1.79
$ pip install tensorflow==2.8.0
ERROR: tensorflow requires numpy>=1.20.0,<1.24.0
       but biopython requires numpy>=1.17.0

$ conda install -c bioconda blast
$ conda install -c conda-forge pytorch
ERROR: Package conflicts detected
```

이러한 문제들의 근본 원인:

1. **전역 네임스페이스**: 시스템 전체에서 하나의 버전만 설치 가능
2. **가변 상태**: 패키지 설치/제거가 기존 환경을 변경
3. **시점 의존성**: 설치 시점에 따라 다른 버전 설치
4. **불완전한 격리**: 가상환경도 시스템 라이브러리에 의존

### Nix의 해결 접근법

Nix는 함수형 프로그래밍 원리를 패키지 관리에 적용하여 이러한 문제들을 근본적으로 해결합니다:

**불변성(Immutability)**: 설치된 패키지는 절대 변경되지 않습니다. 각 패키지는 고유한 해시를 가진 경로에 저장되며, 내용이 바뀌면 새로운 경로에 새로 설치됩니다.

```bash
/nix/store/abc123...python3-3.8.16/
/nix/store/def456...python3-3.9.18/
/nix/store/ghi789...numpy-1.21.0-python3.8/
/nix/store/jkl012...numpy-1.23.0-python3.9/
```

**순수 함수**: 같은 입력(설정)은 항상 같은 출력(환경)을 생성합니다. 시점이나 시스템 상태에 관계없이 동일한 환경이 구성됩니다.

**완전한 격리**: 각 패키지는 명시적으로 선언된 의존성만 참조할 수 있으며, 시스템의 다른 부분과 완전히 격리됩니다.

### Nix 언어와 표현식

Nix는 자체 함수형 언어를 사용하여 패키지와 환경을 선언적으로 정의합니다. 이 언어는 JSON과 유사하지만 변수, 함수, 조건문을 지원합니다.

```nix
# 기본 개발 환경 정의
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    python3Packages.biopython
    python3Packages.numpy
    python3Packages.pandas
  ];

  shellHook = ''
    echo "생물정보학 분석 환경"
    python --version
  '';
}
```

### Nix Store와 패키지 관리

Nix Store는 모든 패키지가 저장되는 불변 저장소입니다. 각 패키지는 입력(소스 코드, 의존성, 빌드 스크립트)의 해시를 기반으로 한 고유한 경로에 저장됩니다.

**경로 구조**: `/nix/store/[32자리 해시]-[패키지명]-[버전]/`

**결정론적 빌드**: 같은 입력으로 빌드하면 항상 같은 결과를 생성합니다. 이는 완전한 재현성을 보장합니다.

**참조 투명성**: 패키지의 의존성이 명시적으로 기록되어 있어, 실행 시점에 정확히 어떤 버전의 라이브러리를 사용하는지 추적 가능합니다.

### 개발 워크플로우에서의 장점

**프로젝트별 환경**: 각 연구 프로젝트가 독립된 환경을 가질 수 있습니다.

```nix
# RNA-seq 분석 환경
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    python3Packages.pandas
    python3Packages.matplotlib
    r-packages.DESeq2
    salmon
    fastp
  ];
}
```

**팀 협업**: 환경 설정을 코드와 함께 버전 관리하여 모든 팀원이 동일한 환경을 사용할 수 있습니다.

**실험과 롤백**: 새로운 도구를 안전하게 실험하고, 문제가 생기면 즉시 이전 환경으로 복원할 수 있습니다.

## 학습 로드맵

### Chapter 2.1: Programming Paradigms

명령형과 함수형 프로그래밍의 차이점을 이해하고, 패키지 관리에서 함수형 접근법의 장점을 학습합니다.

### Chapter 2.2: Functional Programming

불변성, 순수 함수, 참조 투명성 등 함수형 프로그래밍의 핵심 개념과 Nix에서의 적용을 다룹니다.

### Chapter 2.3: Attribute Sets

Nix의 데이터 구조인 속성집합을 이해하고, 구조화된 설정 관리 방법을 학습합니다.

### Chapter 2.4: Nix Basics

Nix 언어의 기본 문법과 패키지 관리 명령어를 실습하며 개발 환경 구성 방법을 익힙니다.

### Chapter 2.5: Nix Core Concepts

Derivation, Nix Store, 의존성 추적 등 Nix의 내부 동작 원리를 심화 학습합니다.

## 사전 요구사항

**설치**: Nix 패키지 관리자가 시스템에 설치되어 있어야 합니다.

```bash
# Linux/macOS 설치
# Windows 의 경우 WSL2 를 설치 후, WSL2 위에 Nix 설치 필요
curl -L https://nixos.org/nix/install | sh
source ~/.nix-profile/etc/profile.d/nix.sh

# 설치 확인
nix --version
```

**배경 지식**:

- 기본적인 패키지 관리 경험 (pip, conda, apt 등)
- 명령줄 인터페이스 사용법
- 프로그래밍 언어 사용 경험 (Python, R 등)

---

**다음**: [2.1 Programming Paradigms](./ch02-1-programming-paradigm.md)
