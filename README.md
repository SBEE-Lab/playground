# playground

## Introduciton

본 playground 코스는 합성생물학 ⋅ 인공진화공학 연구실의 개발 환경 및 인프라 접근을 위한 기본기 학습을 위해 개설되었습니다.

이 코스에서는 세부적인 기초 내용까지 모두 다루지 않으므로, 과제를 통해 학습자 여러분께서 스스로 채워나가셔야 합니다.

## 🛠️ 사전 요구사항

이 프로젝트를 사용하려면 [Nix](https://nixos.org/download/)가 필요합니다.

### macOS/Linux에 Nix 설치

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

### Linux에 Nix 설치

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

### Windows (WSL2)

1. Windows CMD 에서 WSL 설치

```bash
wsl --install
```

1. wsl 에서 Nix 설치

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
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
nix develop .#chapter1
nix develop .#chapter2
...
```

## 🤝 기여하기

본 문서는 참여 구성원 모두가 함께 만들어가는 페이지입니다.
오타를 발견하거나 개선 사항, 새로운 파트나 챕터를 제안하고 싶으시다면, 다음의 두 방법을 통해 본 문서에 기여하실 수 있습니다.

### Issue

GitHub Issue 를 통해 개선 사항을 관리하제에 요청할 수 있습니다.

### Pull-Request

GitHub Pull Request 를 통해 개선 사항을 직접 수정/편집하여 제안하실 수 있습니다.
본 저장소를 `clone` 하신 뒤, 적절한 `branch` 를 생성하여 `commit` 을 작성하여 저장소로 `push` 하시면 됩니다.

자세한 내용은 다음 guide 를 참고해주세요.

- [branch 규정 알아보기](./docs/BRANCH_CONVENTION.md)
- [commit 규정 알아보기](./docs/COMMIT_CONVENTION.md)
