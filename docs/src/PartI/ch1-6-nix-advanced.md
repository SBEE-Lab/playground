# 6. Nix 핵심 개념과 동작 원리

## 6.1 파생(Derivations): 연구 프로토콜의 디지털 버전

### 개념 이해

**파생(Derivation)**은 실험실의 프로토콜 문서와 같습니다. 필요한 재료, 절차, 예상 결과가 명시된 "레시피"입니다.

```bash
# 파생 확인하기
$ nix show-derivation -f basic-bio-env.nix
{
  "/nix/store/abc123...bio-env.drv": {
    "outputs": {
      "out": {
        "path": "/nix/store/def456...bio-env"
      }
    },
    "inputDrvs": {
      "/nix/store/ghi789...python3.drv": ["out"],
      "/nix/store/jkl012...biopython.drv": ["out"]
    },
    "builder": "/nix/store/.../bash",
    "args": ["-e", "/nix/store/.../builder.sh"]
  }
}
```

**연구실 비유**:

- **재료 목록**: `inputDrvs` (Python, BioPython 등)
- **실험 절차**: `builder` 스크립트
- **예상 결과**: `outputs` 경로

## 6.2 Nix Store: 연구실의 시약 창고

### 구조 관찰

```bash
# Nix Store 구조 확인
$ ls /nix/store/ | head -5
0123456789abcdef-python3-3.8.16
1a2b3c4d5e6f7890-biopython-1.81
2b3c4d5e6f789012-pandas-1.5.3
3c4d5e6f78901234-matplotlib-3.6.2
4d5e6f7890123456-bio-analysis-env
```

**경로 구조**: `/nix/store/[32자리해시]-[패키지명]-[버전]/`

### 해시 기반 주소 지정

```bash
# 같은 "재료"는 같은 해시
$ nix-build -E 'with import <nixpkgs> {}; python38'
/nix/store/abc123...python3-3.8.16

$ nix-build -E 'with import <nixpkgs> {}; python38'
/nix/store/abc123...python3-3.8.16  # 동일한 경로

# 다른 "재료"는 다른 해시
$ nix-build -E 'with import <nixpkgs> {}; python39'
/nix/store/xyz789...python3-3.9.18  # 다른 경로
```

**연구실 비유**: 시약 병의 바코드처럼 각 패키지는 고유 식별자를 가집니다.

## 6.3 의존성 추적: 실험 재료의 이력 관리

### 의존성 관계 확인

```bash
# 환경 구성 후 의존성 확인
$ nix-shell basic-bio-env.nix
[nix-shell]$ exit

# 생성된 환경의 의존성 추적
$ nix-store --query --references result
/nix/store/abc123...python3-3.8.16
/nix/store/def456...biopython-1.81
/nix/store/ghi789...pandas-1.5.3
/nix/store/jkl012...numpy-1.23.5
```

### 의존성 트리 시각화

```bash
# 전체 의존성 트리
$ nix-store --query --tree result | head -10
/nix/store/result...bio-analysis-env
├───/nix/store/abc123...python3-3.8.16
│   ├───/nix/store/lib001...glibc-2.37
│   └───/nix/store/lib002...openssl-3.0.9
├───/nix/store/def456...biopython-1.81
│   ├───/nix/store/abc123...python3-3.8.16
│   └───/nix/store/jkl012...numpy-1.23.5
└───/nix/store/ghi789...pandas-1.5.3
    └───/nix/store/jkl012...numpy-1.23.5
```

**연구실 비유**: 실험에 사용된 모든 시약의 로트 번호와 공급업체를 추적하는 것과 같습니다.

## 6.4 격리와 재현성: 독립적인 실험실

### 환경 격리 확인

```bash
# 시스템에는 Python이 설치되지 않음
$ python --version
bash: python: command not found

# Nix 환경에서만 사용 가능
$ nix-shell -p python38
[nix-shell]$ python --version
Python 3.8.16

[nix-shell]$ exit
$ python --version  # 다시 사용 불가
bash: python: command not found
```

### 동시 버전 관리

```bash
# 여러 Python 버전 동시 사용
$ nix-shell -p python38 --run "python --version"
Python 3.8.16

$ nix-shell -p python39 --run "python --version"
Python 3.9.18

$ nix-shell -p python310 --run "python --version"
Python 3.10.13
```

**연구실 비유**: 각 실험실이 서로 다른 시약 버전을 사용해도 간섭하지 않습니다.

## 6.5 바이너리 캐시: 시약의 공동 구매

### 캐시 동작 관찰

```bash
# 새로운 패키지 설치 시 캐시에서 다운로드
$ nix-shell -p blast
downloading 'https://cache.nixos.org/...blast-2.13.0.drv'
copying path '/nix/store/...blast-2.13.0' from 'https://cache.nixos.org'...

[nix-shell]$ blast --version
# 즉시 사용 가능
```

### 캐시 설정 확인

```bash
# 현재 캐시 서버 확인
$ nix show-config | grep substituters
substituters = https://cache.nixos.org
```

**연구실 비유**: 대학의 중앙 시약 창고에서 공통으로 사용하는 시약을 공급받는 것과 같습니다.

## 6.6 재현성 검증 실험

### 환경 복제 테스트

```bash
# 환경 정의 파일 생성
$ cat > reproducible-env.nix << 'EOF'
{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/22.11.tar.gz";
    sha256 = "11w3wn2yjhaa5pv20gbfbirvjq6i3m7pqrq2msf0g7cv44vijwgw";
  }) {}
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python38
    python38Packages.biopython
    python38Packages.pandas
  ];
}
EOF

# 첫 번째 실행
$ nix-shell reproducible-env.nix --run "python -c 'import sys; print(sys.version)'"
Python 3.8.16 ...

# 6개월 후 재실행 (동일한 결과 보장)
$ nix-shell reproducible-env.nix --run "python -c 'import sys; print(sys.version)'"
Python 3.8.16 ...  # 정확히 같은 버전
```

### 논문 재현 시나리오

```nix
# paper-reproduction.nix - 논문 재현용 환경
{ pkgs ? import (fetchTarball {
    # 논문 작성 시점의 패키지 고정
    url = "https://github.com/NixOS/nixpkgs/archive/22.11.tar.gz";
    sha256 = "11w3wn2yjhaa5pv20gbfbirvjq6i3m7pqrq2msf0g7cv44vijwgw";
  }) {}
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python38                      # Python 3.8.16
    python38Packages.tensorflow   # TensorFlow 2.11.0
    python38Packages.biopython    # BioPython 1.81
    blast                         # BLAST 2.13.0
  ];

  shellHook = ''
    echo "논문 재현 환경 (2022.11 기준)"
    echo "모든 도구 버전이 고정되어 있습니다"
  '';
}
```

## 6.7 가비지 컬렉션: 시약 창고 정리

### 사용하지 않는 패키지 확인

```bash
# 사용 중인 패키지와 죽은 패키지 구분
$ nix-store --gc --print-dead | head -5
finding garbage collector roots...
/nix/store/old123...unused-package-1.0
/nix/store/old456...temporary-build
...would delete 50 paths (2.1G)

$ nix-store --gc --print-live | head -5
/nix/store/abc123...python3-3.8.16
/nix/store/def456...current-environment
```

### 정리 실행

```bash
# 현재 스토어 크기
$ du -sh /nix/store
8.5G    /nix/store

# 가비지 컬렉션 실행
$ nix-collect-garbage
deleting '/nix/store/old123...unused-package'
...
2.1G freed

# 정리 후 크기
$ du -sh /nix/store
6.4G    /nix/store
```

**연구실 비유**: 사용하지 않는 오래된 시약을 주기적으로 폐기하여 창고 공간을 확보하는 것과 같습니다.

## 6.8 실제 연구 워크플로우에서의 활용

### 프로젝트 수명주기

```bash
# 1. 새 프로젝트 시작
$ git clone https://github.com/lab/protein-study.git
$ cd protein-study

# 2. 환경 자동 구성
$ nix-shell  # shell.nix 자동 실행
🧬 단백질 분석 환경 준비 완료

# 3. 분석 실행
[nix-shell]$ python run_analysis.py

# 4. 결과 공유 (환경 포함)
$ git add shell.nix results/
$ git commit -m "분석 완료: 환경 설정 포함"
$ git push
```

### 팀 협업 시나리오

```bash
# 동료 연구자의 환경 재현
$ git pull origin main
$ nix-shell  # 동일한 환경 즉시 구성
🧬 단백질 분석 환경 준비 완료
# 5분 내에 완전히 동일한 분석 환경 확보
```

---

**요약**: Nix는 해시 기반 식별, 의존성 추적, 환경 격리를 통해 실행 환경의 재현성을 보장하며, 바이너리 캐시로 효율성을 제공합니다. 이제 여러분은 개발 환경을 정확히 문서화하고 재현할 수 있습니다.
