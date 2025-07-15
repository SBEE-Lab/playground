# playground

## Introduciton

본 playground 코스는 합성생물학 ⋅ 인공진화공학 연구실의 개발 환경 및 인프라 접근을 위한 기본기 학습을 위해 개설되었습니다.

이 코스에서는 세부적인 기초 내용까지 모두 다루지 않으므로, 과제를 통해 학습자 여러분께서 스스로 채워나가셔야 합니다.

## 🛠️ 사전 요구사항

이 프로젝트를 사용하려면 [Nix](https://nixos.org/download/)가 필요합니다.

### macOS/Linux에 Nix 설치

```bash
sh <(curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix)
```

### Windows (WSL2)

```bash
sh <(curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix)
```

### Docker 사용

```bash
docker run -it nixos/nix
```

또는 [Docker를 통한 Nix 설치](https://nixos.org/download/#nix-install-docker)를 참조하세요.

## 🚀 시작하기

### 1. 저장소 클론

```bash
git clone https://github.com/sbee-lab/playground
cd playground
```

### 2. 개발 환경 진입

```bash
nix develop
```

또는 한번 개발 환경 진입 이후부터는,

```bash
direnv allow
```

<!-- ### 3. 저장소 초기화 -->

<!-- ```bash -->
<!-- just init-repo -->
<!-- ``` -->

<!-- ### 4. 첫 번째 챕터 시작 -->

<!-- ```bash -->
<!-- # 힌트 확인 -->
<!-- just hint 01 -->

<!-- # 챕터 해독 (비밀번호 추측 필요) -->
<!-- just decrypt-chapter 01 "your-password-guess" -->

<!-- # 메인 책에 병합 -->
<!-- just merge-chapter 01 -->

<!-- # 진행상황 확인 -->
<!-- just show-progress -->
<!-- ``` -->

<!-- ## 📚 사용 가능한 명령어 -->

<!-- ### 학습자용 명령어 -->

<!-- - `just hint CHAPTER_NUM` - 챕터 힌트 보기 -->
<!-- - `just decrypt-chapter CHAPTER_NUM PASSWORD` - 챕터 해독 -->
<!-- - `just merge-chapter CHAPTER_NUM` - 해독된 챕터를 메인 책에 병합 -->
<!-- - `just show-progress` - 현재 학습 진행상황 확인 -->
<!-- - `just build-book` - 완성된 책 빌드 -->
<!-- - `just serve-book` - 로컬에서 책 서빙 -->
<!-- - `just list-chapters` - 모든 챕터 목록 보기 -->

<!-- ### 강사용 명령어 -->

<!-- - `just create-chapter CHAPTER_NUM` - 새 챕터 생성 -->
<!-- - `just encrypt-chapter CHAPTER_NUM PASSWORD` - 챕터 암호화 -->
<!-- - `just add-hint CHAPTER_NUM HINT` - 챕터 힌트 추가 -->

<!-- ## 📖 학습 방법 -->

<!-- 1. **힌트 확인**: `just hint N`으로 챕터 힌트를 확인합니다 -->
<!-- 2. **문제 해결**: 힌트를 바탕으로 비밀번호를 추측하거나 과제를 해결합니다 -->
<!-- 3. **챕터 해독**: 올바른 비밀번호로 챕터를 해독합니다 -->
<!-- 4. **내용 학습**: 해독된 챕터의 내용을 학습합니다 -->
<!-- 5. **책에 통합**: 학습한 챕터를 개인 학습서에 통합합니다 -->
<!-- 6. **다음 단계**: 다음 챕터로 진행합니다 -->

<!-- ## 🔐 보안 및 암호화 -->

<!-- - **Age 암호화**: 각 챕터는 age 암호화를 사용하여 보호됩니다 -->
<!-- - **비밀번호 관리**: 비밀번호는 학습 내용과 연관성 있게 설계됩니다 -->
<!-- - **자동 정리**: 암호화 키는 사용 후 자동으로 정리됩니다 -->

<!-- ## 📁 프로젝트 구조 -->

<!-- ```text -->
<!-- learning-playground/ -->
<!-- ├── flake.nix              # Nix 환경 설정 -->
<!-- ├── justfile              # 작업 자동화 명령어 -->
<!-- ├── scripts/              # 자동화 스크립트들 -->
<!-- ├── docs/                 # 메인 문서 (mdbook) -->
<!-- ├── chapters/             # 암호화된 챕터들 -->
<!-- ├── templates/            # 템플릿 파일들 -->
<!-- ├── hints/                # 챕터별 힌트 -->
<!-- └── .keys/                # 암호화 키 (자동 관리) -->
<!-- ``` -->

<!-- ## 🎓 학습 팁 -->

<!-- - **순차적 학습**: 챕터를 순서대로 해결하는 것이 좋습니다 -->
<!-- - **힌트 활용**: 막힐 때는 힌트를 적극 활용하세요 -->
<!-- - **진행상황 확인**: 정기적으로 진행상황을 확인하세요 -->
<!-- - **완성된 책**: 모든 챕터를 완료하면 완전한 개인 학습서가 완성됩니다 -->
