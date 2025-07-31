# 🛠️ 사전 요구사항

## 필수 배경 지식

- 기본적인 컴퓨터 사용 경험
- 텍스트 파일 편집 능력
- 프로그래밍 언어 경험 (Python, R 등 중 하나 이상)

## 권장 배경 지식

- 생물학 기초 지식 (생물정보학 파트)
- 통계학 기초 (데이터 분석 파트)
- Linux/Unix 사용 경험

---

## 시스템 요구사항

### 1. Install Nix

- 터미널에서 다음 명령어로 Nix 를 설치합니다.
- Windows 사용자의 경우, [WSL2 를 먼저 설치](https://learn.microsoft.com/ko-kr/windows/wsl/install)한 후 Ubuntu Terminal 에서 아래 코드를 실행해야 합니다.

  ```bash
  curl -L https://nixos.org/nix/install | sh
  ```

### 2. Source your shell or restart the Terminal

- 설치가 완료되면 아래의 코드를 실행하거나 터미널을 재시작하여 shell 환경을 재구성합니다.

  ```bash
  source ~/.nix-profile/etc/profile.d/nix.sh
  ```

- **설치 확인**

  ```bash
  nix --version
  ```

---

## 🛠️ 실습 환경 구성

실습을 위해 [playground repository](https://github.com/sbee-lab/playground) 를 clone 하여야 합니다.

```bash
git clone https://github.com/sbee-lab/playground
```

모든 실습은 clone 한 repository 의 `./practices` directory 에서 수행됩니다.

```bash
# clone 한 repository 로 이동
cd playground
```

```bash
# 실습을 위한 directory 로 이동
cd ./practice
```

실습을 위한 환경은 Chapter 별 Nix 환경에서 진행됩니다:

```bash
nix develop .#chapter1
nix develop .#chapter2
nix develop .#chapter3
```

---

이제 본격적으로 PartI: Foundation 부터 학습을 진행합시다.

다음: [PartI: Foundation](../PartI/overview.md)
