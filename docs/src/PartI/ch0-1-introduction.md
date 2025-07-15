# Part I: Development Environment

SBEE Playground의 전반부에서는 현대적인 개발 환경 구축에 필요한 핵심 기술들을 학습합니다.

## 학습 목표

개발 환경의 **재현 가능성(Reproducibility)** 과 **결정론적 빌드(Deterministic Builds)** 를 달성하여, 모든 개발자가 동일한 환경에서 작업할 수 있도록 하는 것이 주요 목표입니다.

## 핵심 주제

### Chapter 1: Introduction to Nix

함수형 패키지 관리자 Nix를 통해 완전히 재현 가능한 개발 환경을 구축하는 방법을 학습합니다.

- **Programming Paradigm**: 명령형과 함수형 프로그래밍의 차이점
- **Functional Programming**: 함수형 프로그래밍의 핵심 개념
- **Attribute Sets**: Nix의 데이터 구조와 표현 방식
- **Nix Basics**: 기본 문법과 사용법
- **Nix Core Concepts**: 패키지 관리와 환경 격리의 핵심 원리

### Chapter 2: Introduction to Git

협업과 버전 관리를 위한 Git의 핵심 개념과 워크플로우를 다룹니다.

### Chapter 3: Introduction to Cryptography

보안과 인증을 위한 암호학 기초를 학습합니다.

## 부록 (선택적 학습)

실제 운영 환경에 따라 필요한 부분을 선택적으로 학습할 수 있습니다:

- **Appendix A**: **NixOS** - 전체 시스템을 Nix로 관리하는 Linux 배포판
- **Appendix B**: **Nix-Darwin** - macOS에서 시스템 설정을 선언적으로 관리
- **Appendix C**: **Home-Manager** - 사용자 환경과 dotfiles를 Nix로 관리

## 학습 접근법

각 주제는 이론과 실습을 병행하며, 실제 프로젝트에서 바로 적용할 수 있는 실용적인 지식을 제공합니다. 모든 예제와 실습은 이 저장소의 Nix flake 환경에서 직접 실행해볼 수 있습니다.
