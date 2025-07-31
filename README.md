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
