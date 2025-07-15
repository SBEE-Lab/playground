# Chapter 1: Nix 이해를 위한 기초

## 1. 도입부: 왜 Nix인가?

> _"내 컴퓨터에서는 되는데..."_
>
> 개발자라면 한 번쯤 들어봤을 이 말. 우리는 왜 이런 상황에 반복적으로 마주치게 될까요?

### 1.1 개발 환경의 영원한 문제들

#### 📱 시나리오: 새로운 프로젝트 참여 첫날

당신은 새로운 팀에 합류했습니다. 기존 프로젝트를 로컬에서 실행해보려고 하는데...

```bash
$ git clone https://github.com/team/awesome-project.git
$ cd awesome-project
$ npm install
npm ERR! peer dep missing: react@^17.0.0, required by react-router@^5.2.0

$ python setup.py install
Error: Python 3.8 required, but you have 3.9

$ make build
/bin/sh: gcc-9: command not found
```nix

**결과**: 반나절이 지나도록 개발 환경 세팅에만 매달리게 됩니다. 😤

#### 🔄 의존성 지옥(Dependency Hell)

```bash
# 프로젝트 A: Python 3.8 + Django 3.2
# 프로젝트 B: Python 3.9 + Django 4.0
# 프로젝트 C: Python 3.7 + Flask 2.0

# 어떻게 모두 동시에 관리할 것인가?
```nix

**기존 해결책들의 한계:**

- **Docker**: 무겁고, 개발용 도구 설치가 복잡
- **가상환경**: 언어별로 각각 다른 도구 (virtualenv, nvm, rbenv...)
- **시스템 전역 설치**: 버전 충돌과 롤백 불가

#### 🎯 재현 가능성(Reproducibility) 문제

```bash
# 2주 전에 작동했던 빌드가 갑자기...
$ npm run build
Error: Module not found - package version updated

# 1개월 전 배포한 서버와 로컬 환경이 다름
Local: Node.js 16.14.0
Server: Node.js 16.13.2
# 미묘한 차이가 큰 버그로...
```nix

**왜 이런 일이 생길까?**

- 패키지 저장소의 변화 (npm, pypi, apt 등)
- 시간에 따른 의존성 업데이트
- OS별, 아키텍처별 차이점
- 설치 순서에 따른 다른 결과

### 1.2 Nix가 제시하는 해답

#### 🧮 순수 함수형 패키지 관리

```nix
# shell.nix - 프로젝트 개발 환경 정의
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs-16_x      # 정확한 버전 명시
    python38         # Python 3.8 고정
    gcc9             # GCC 9.x 사용
  ];
}
```nix

```bash
# 어느 컴퓨터에서든 동일한 환경
$ nix-shell
[nix-shell]$ node --version
v16.14.0                    # 항상 같은 버전

[nix-shell]$ python --version
Python 3.8.10               # 정확히 3.8

[nix-shell]$ gcc --version
gcc (GCC) 9.4.0             # 지정된 버전
```nix

**핵심 원리:**

- **불변성**: 한 번 빌드된 패키지는 절대 변하지 않음
- **격리성**: 각 환경은 완전히 독립적
- **결정론적**: 같은 입력 → 항상 같은 출력

#### ⚡ 원자적 업데이트와 안전한 롤백

```bash
# 시스템 업데이트 (NixOS의 경우)
$ sudo nixos-rebuild switch --upgrade

# 문제가 생겼다면? 즉시 이전 상태로 롤백
$ sudo nixos-rebuild switch --rollback

# 또는 부팅 시 이전 버전 선택 가능
# 시스템이 완전히 망가지는 일은 없음!
```nix

#### 🎯 완벽한 재현성

```nix
# flake.lock - 모든 의존성의 정확한 버전과 해시
{
  "nodes": {
    "nixpkgs": {
      "locked": {
        "lastModified": 1641899475,
        "narHash": "sha256-...",
        "rev": "9bb1e7dc123..."
      }
    }
  }
}
```nix

**결과**:

- 6개월 후에도 정확히 같은 환경 복원 가능
- 팀원 간 100% 동일한 개발 환경
- CI/CD와 프로덕션 환경 일치 보장

### 1.3 Nix 생태계 개요

#### 🏗️ Nix 생태계의 구성요소

```nix
┌─────────────────────────────────────────┐
│                 NixOS                   │  ← 완전한 운영체제
│         (Linux Distribution)            │
├─────────────────────────────────────────┤
│            Home Manager                 │  ← 사용자 환경 관리
│         (Dotfiles & User Env)           │
├─────────────────────────────────────────┤
│               nixpkgs                   │  ← 패키지 저장소
│         (Package Collection)            │
├─────────────────────────────────────────┤
│            Nix Language                 │  ← 설정 언어
│         (Functional DSL)                │
├─────────────────────────────────────────┤
│             Nix Store                   │  ← 패키지 저장소 (Local)
│         (/nix/store/...)                │
└─────────────────────────────────────────┘
```nix

#### 🎯 이 튜토리얼에서 배울 내용

**Chapter 1 (현재)**: Nix 언어와 기초 개념

- 함수형 프로그래밍 패러다임 이해
- Nix 언어 문법과 속성 집합
- 개발 환경 구성 (`shell.nix`)

**Chapter 2 (예정)**: NixOS와 시스템 관리

- Linux 시스템 관리 기초
- NixOS 설정 파일 작성
- 서비스와 네트워크 구성

#### 🚀 학습 후 달성할 수 있는 것들

**단기 목표 (Chapter 1 완료 후):**

- [ ] 재현 가능한 개발 환경 구성
- [ ] 팀원과 정확히 같은 도구 버전 사용
- [ ] 프로젝트별 격리된 환경 관리
- [ ] 복잡한 의존성 문제 해결

**장기 목표 (전체 과정 완료 후):**

- [ ] 개인 워크스테이션을 코드로 관리
- [ ] 서버 인프라를 선언적으로 구성
- [ ] 팀 전체 개발 환경 표준화
- [ ] 데브옵스 자동화 구현

### 1.4 시작하기 전에

#### ✅ 사전 요구사항

**필수 지식:**

- [ ] 기본적인 프로그래밍 경험 (어떤 언어든)
- [ ] 터미널/명령줄 사용 경험
- [ ] Git 기본 사용법

**도움이 되는 배경 지식:**

- [ ] Linux/Unix 명령어 기초
- [ ] JSON, YAML 등 설정 파일 경험
- [ ] Docker, 가상환경 사용 경험

**예상 학습 시간**: 총 2-3시간

- 읽기: 1.5시간
- 실습: 1시간
- 과제: 30분-1시간 (개인차)

---

🎉 **준비되셨나요?**

다음 섹션에서는 Nix를 이해하는 데 핵심인 [**프로그래밍 패러다임**](./2-programming_paradigm.md)부터 차근차근 알아보겠습니다.

함수형 프로그래밍이 처음이어도 걱정하지 마세요. 실제 코드 예제와 함께 쉽게 설명해드릴게요! 🚀
