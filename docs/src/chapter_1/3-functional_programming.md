# 3. 함수형 프로그래밍 심화와 빌드 시스템

> _"Python 2.7 지원이 종료되었습니다. 모든 패키지를 업데이트하세요."_
>
> 이 한 줄이 얼마나 많은 개발자들을 절망에 빠뜨렸는지... 🥲

## 3.1 의존성 지옥의 실체

### 📚 시나리오: 파이썬 프로젝트의 악몽

2년 전에 완벽하게 작동하던 프로젝트를 다시 실행해보려는 상황입니다.

**🔴 기존 명령형 접근법:**

```bash
# 2022년에 작성된 requirements.txt
django==3.2.0
celery==5.1.0
redis==3.5.3
numpy==1.21.0
requests==2.25.1
```nix

```bash
# 2024년에 다시 설치 시도
$ pip install -r requirements.txt

ERROR: Cannot install django==3.2.0 because these package versions have conflicts:
- django==3.2.0 requires Python>=3.6,<4.0
- numpy==1.21.0 requires Python>=3.7
- celery==5.1.0 has security vulnerability CVE-2023-12345

$ pip install django==4.2.0  # 최신 버전으로 업데이트 시도
ERROR: django==4.2.0 is incompatible with celery==5.1.0
```nix

### 🕸️ 의존성 그래프의 복잡성

```nix
🎯 프로젝트
├── Django 3.2.0
│   ├── Python >= 3.6, < 4.0
│   ├── asgiref >= 3.3.2, < 4
│   └── sqlparse >= 0.2.2
│       └── setuptools >= 40.0  ⚠️ (이미 다른 버전 설치됨)
├── Celery 5.1.0
│   ├── Python >= 3.6
│   ├── kombu >= 5.1.0, < 6.0
│   │   └── amqp >= 5.0.6
│   │       └── vine >= 5.0.0
│   └── click >= 7.0, < 9.0  ⚠️ (Django admin과 충돌)
└── NumPy 1.21.0
    ├── Python >= 3.7  ⚠️ (Django 요구사항과 충돌)
    └── setuptools >= 40.0  ⚠️ (이미 다른 버전 필요)
```nix

### 💥 Breaking Changes의 연쇄 반응

**Python 2 → 3 전환 사례:**

```python
# Python 2.7에서 작동하던 코드
print "Hello, World!"          # 2.7: OK, 3.x: SyntaxError
result = 10 / 3                 # 2.7: 3, 3.x: 3.333...
unicode_str = u"안녕하세요"      # 2.7: 필수, 3.x: 기본값

# 라이브러리별 호환성 문제
import urllib2                  # 2.7: OK, 3.x: ModuleNotFoundError
import urllib.request           # 3.x 전용
```nix

**실제 프로젝트에서 발생한 문제:**

```bash
# 패키지별 Python 3 지원 시점이 다름
Django: 1.11 (2017년) → 2.0 (Python 3만 지원)
NumPy: 1.16 (2019년) → Python 2 지원 종료
TensorFlow: 2.0 (2019년) → Python 2 지원 종료
requests: 2.18 (2017년) → 여전히 Python 2 지원

# 하나의 프로젝트에서 모든 조건을 만족하는 것이 불가능!
```nix

## 3.2 명령형 빌드 시스템의 근본적 문제

### 🔄 상태 기반 설치의 문제점

**전역 상태 의존성:**

```bash
# 시스템 전역에 설치 (명령형 방식)
sudo apt install python3-pip       # 시스템 상태 변경
pip install django                  # 사용자 환경 상태 변경
pip install numpy                   # 기존 환경에 추가 변경

# 상태가 누적되면서 예측 불가능해짐
pip list | wc -l                    # 몇 개가 설치되어 있는지도 모름
pip freeze > requirements.txt       # 현재 상태를 파일로 저장 시도
```nix

**시간에 따른 상태 변화:**

```bash
# 1월 1일
pip install requests==2.25.1        # requests 2.25.1 설치

# 3월 15일
pip install some-package             # some-package가 requests >= 2.26.0 요구
# pip이 자동으로 requests를 2.28.0으로 업데이트

# 6월 1일
python old_script.py                # requests 2.25.1 기준으로 작성된 스크립트
# AttributeError: 'Response' object has no attribute 'ok'
# (requests 2.26.0에서 API가 변경됨)
```nix

### 🏗️ 빌드 과정의 비결정성

```bash
# 같은 Dockerfile이 다른 시점에 다른 결과 생성
FROM python:3.9
COPY requirements.txt .
RUN pip install -r requirements.txt  # 매번 다른 결과!

# 2023년 1월 빌드: numpy==1.21.0
# 2023년 6월 빌드: numpy==1.24.0 (자동 업데이트)
# 2023년 12월 빌드: ERROR (Python 3.9 지원 종료)
```nix

**문제의 근본 원인:**

1. **Mutable State**: 시스템 상태가 지속적으로 변경됨
2. **Side Effects**: 패키지 설치가 전역 환경에 영향
3. **Time Dependency**: 같은 명령이 시점에 따라 다른 결과
4. **Implicit Dependencies**: 숨겨진 의존성들의 존재

## 3.3 함수형 프로그래밍의 핵심 개념들

### 🔒 불변성(Immutability): "절대 변하지 않는다"

**🔴 가변성 문제 (JavaScript 예제):**

```javascript
// 배열을 "정렬"한다고 했는데...
function sortNumbers(numbers) {
  return numbers.sort((a, b) => a - b); // 원본 배열을 변경!
}

const originalNumbers = [3, 1, 4, 1, 5];
const sorted = sortNumbers(originalNumbers);

console.log(originalNumbers); // [1, 1, 3, 4, 5] - 어? 원본이 바뀜!
console.log(sorted); // [1, 1, 3, 4, 5]
// 예상치 못한 부작용 발생!
```nix

**🟢 불변성 접근법:**

```javascript
// 원본을 절대 변경하지 않음
function sortNumbersImmutable(numbers) {
  return [...numbers].sort((a, b) => a - b); // 복사본을 만든 후 정렬
}

const originalNumbers = [3, 1, 4, 1, 5];
const sorted = sortNumbersImmutable(originalNumbers);

console.log(originalNumbers); // [3, 1, 4, 1, 5] - 원본 그대로!
console.log(sorted); // [1, 1, 3, 4, 5]
// 예측 가능하고 안전함
```nix

**빌드 시스템에 적용:**

```nix
# Nix에서의 불변성
let
    pythonEnv = python38.withPackages (ps: with ps; [
        django_3_2     # 정확한 버전 고정
        celery         # 호환되는 버전 자동 선택
        numpy          # 의존성 충돌 해결됨
    ]);
in
    pythonEnv
# pythonEnv는 한 번 만들어지면 절대 변하지 않음
# 6개월 후에도 동일한 환경 보장
```nix

### ⚡ 순수 함수(Pure Functions): "예측 가능한 입출력"

**🔴 비순수 함수의 문제:**

```python
# 외부 상태에 의존하는 패키지 설치 함수
import subprocess
import os

installed_packages = set()  # 전역 상태

def install_package(package_name):
    """패키지를 설치하고 설치된 패키지 목록을 업데이트"""
    if package_name in installed_packages:
        return "Already installed"

    # 외부 시스템 상태 변경 (부작용)
    result = subprocess.run(['pip', 'install', package_name])

    if result.returncode == 0:
        installed_packages.add(package_name)  # 전역 상태 변경
        return "Installed successfully"
    else:
        return "Installation failed"

# 같은 함수를 호출해도 결과가 다를 수 있음
print(install_package("requests"))  # "Installed successfully"
print(install_package("requests"))  # "Already installed"
# 네트워크 상태, 시스템 상태에 따라 결과 변경될 수 있음
```nix

**🟢 순수 함수 접근법:**

```python
def create_package_spec(name, version, dependencies=None):
    """패키지 스펙을 생성 (순수 함수)"""
    if dependencies is None:
        dependencies = []

    return {
        'name': name,
        'version': version,
        'dependencies': dependencies,
        'hash': f"sha256-{hash(name + version)}"  # 결정론적 해시
    }

def resolve_dependencies(package_specs):
    """의존성을 해결 (순수 함수)"""
    resolved = {}
    for spec in package_specs:
        resolved[spec['name']] = spec
        # 의존성 해결 로직 (외부 상태 변경 없음)
    return resolved

# 같은 입력 → 항상 같은 출력
django_spec = create_package_spec("django", "3.2.0", ["asgiref"])
celery_spec = create_package_spec("celery", "5.1.0", ["kombu"])

specs = [django_spec, celery_spec]
resolved1 = resolve_dependencies(specs)
resolved2 = resolve_dependencies(specs)
# resolved1과 resolved2는 완전히 동일함 (보장됨)
```nix

### 🔗 참조 투명성(Referential Transparency): "표현식 = 값"

**개념 설명:**

```javascript
// 참조 투명하지 않은 함수
let counter = 0;
function getNextId() {
  return ++counter; // 호출할 때마다 다른 값
}

const user1 = { id: getNextId(), name: "Alice" }; // id: 1
const user2 = { id: getNextId(), name: "Bob" }; // id: 2
// getNextId()를 1로 바꿀 수 없음 (참조 투명하지 않음)

// 참조 투명한 함수
function createUser(id, name) {
  return { id: id, name: name };
}

const user3 = createUser(1, "Alice");
const user4 = createUser(2, "Bob");
// createUser(1, "Alice")를 { id: 1, name: "Alice" }로 바꿔도 동일함
```nix

**Nix에서의 참조 투명성:**

```nix
let
    # 모든 표현식이 참조 투명함
    pythonVersion = "3.8";
    djangoVersion = "3.2.0";

    # 이 표현식들을 값으로 바꿔도 동일함
    python = pkgs.python38;              # pythonVersion = "3.8"과 연결
    django = pkgs.python38Packages.django_3_2;  # djangoVersion과 연결
in
{
    buildInputs = [ python django ];
    # python을 pkgs.python38로 바꿔도 결과 동일
    # django를 pkgs.python38Packages.django_3_2로 바꿔도 결과 동일
}
```nix

## 3.4 함수형 빌드 시스템의 장점

### 🎯 결정론적 빌드 (Deterministic Builds)

**🔴 기존 방식의 비결정성:**

```dockerfile
# 이 Dockerfile은 매번 다른 결과를 만들 수 있음
FROM ubuntu:20.04
RUN apt update && apt install -y python3-pip  # 시점에 따라 다른 패키지
RUN pip install django                         # 최신 버전이 계속 변함
COPY . /app
```nix

**🟢 Nix의 결정론적 접근:**

```nix
# 이 표현식은 언제나 동일한 결과 생성
{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/21.11.tar.gz";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  }) {}
}:

pkgs.dockerTools.buildImage {
  name = "my-app";
  contents = with pkgs; [
    python38
    python38Packages.django_3_2  # 정확한 버전 고정
  ];
}
# 1년 후에 빌드해도 완전히 동일한 이미지 생성
```nix

### 🔄 구성 가능성(Composability)

**작은 순수 함수들의 조합:**

```nix
# 기본 Python 환경
basePython = pkgs.python38;

# 웹 개발 도구들
webTools = python-packages: with python-packages; [
  django_3_2
  gunicorn
  psycopg2
];

# 데이터 분석 도구들
dataTools = python-packages: with python-packages; [
  numpy
  pandas
  matplotlib
];

# 개발 도구들
devTools = python-packages: with python-packages; [
  pytest
  black
  flake8
];

# 환경별 조합
webDevEnv = basePython.withPackages (ps:
  webTools ps ++ devTools ps
);

dataAnalysisEnv = basePython.withPackages (ps:
  dataTools ps ++ devTools ps
);

fullStackEnv = basePython.withPackages (ps:
  webTools ps ++ dataTools ps ++ devTools ps
);
```nix

### 🛡️ 격리와 안전성

**프로젝트별 완전 격리:**

```bash
# 프로젝트 A (Django 3.2)
cd project-a
nix-shell
[nix-shell]$ python --version  # Python 3.8
[nix-shell]$ django-admin --version  # 3.2.0
[nix-shell]$ exit

# 프로젝트 B (Django 4.0)
cd project-b
nix-shell
[nix-shell]$ python --version  # Python 3.9
[nix-shell]$ django-admin --version  # 4.0.0
[nix-shell]$ exit

# 시스템 환경 (영향 없음)
$ python --version  # 시스템 기본 Python
$ django-admin --version  # command not found
# 완전히 격리됨!
```nix

## 3.5 실제 사례: 의존성 지옥 해결

### 📊 복잡한 데이터 파이프라인 프로젝트

**상황:** 머신러닝 파이프라인에서 발생한 실제 문제

```python
# requirements.txt (2022년 작성)
tensorflow==2.8.0      # Python 3.7-3.10 지원
pandas==1.4.2          # numpy >= 1.18.5 요구
numpy==1.21.0          # tensorflow와 pandas 모두에서 사용
scikit-learn==1.0.2    # numpy >= 1.14.6, scipy >= 1.1.0 요구
scipy==1.8.0           # numpy >= 1.17.3 요구
matplotlib==3.5.1      # numpy >= 1.17 요구
jupyter==1.0.0         # ipython 등 의존
```nix

**🔴 2024년에 발생한 문제들:**

```bash
$ pip install -r requirements.txt

ERROR: tensorflow 2.8.0 requires protobuf<3.20,>=3.9.2,
       but you have protobuf 4.21.0 which is incompatible.

ERROR: pandas 1.4.2 requires numpy>=1.18.5,
       but tensorflow 2.8.0 requires numpy>=1.20.0,<1.24.

ERROR: scikit-learn 1.0.2 has security vulnerability CVE-2023-XXXX

# 업데이트 시도
$ pip install tensorflow==2.12.0
ERROR: tensorflow 2.12.0 requires Python>=3.8, but you have 3.7

$ pyenv install 3.8.16
$ pip install tensorflow==2.12.0
ERROR: Your NumPy version is too old. Please upgrade to >=1.23.0

$ pip install numpy==1.23.0
ERROR: pandas 1.4.2 is incompatible with numpy 1.23.0
```nix

**🟢 Nix로 해결:**

```nix
# ml-pipeline.nix
{ pkgs ? import <nixpkgs> {} }:

let
  # Python 3.8로 고정
  python = pkgs.python38;

  # 호환되는 패키지 조합 자동 해결
  pythonEnv = python.withPackages (ps: with ps; [
    tensorflow
    pandas
    numpy
    scikit-learn
    scipy
    matplotlib
    jupyter
  ]);

in pkgs.mkShell {
  buildInputs = [ pythonEnv ];

  shellHook = ''
    echo "ML Pipeline Environment Ready!"
    echo "Python: $(python --version)"
    echo "TensorFlow: $(python -c 'import tensorflow; print(tensorflow.__version__)')"
    echo "All dependencies resolved automatically"
  '';
}
```nix

```bash
# 사용법
$ nix-shell ml-pipeline.nix
ML Pipeline Environment Ready!
Python: Python 3.8.16
TensorFlow: 2.11.0
All dependencies resolved automatically

# 6개월 후에도 동일한 환경
$ nix-shell ml-pipeline.nix
# 완전히 동일한 출력!
```nix

## 3.6 함수형 vs 명령형: 빌드 시스템 비교

| 특성            | 명령형 (apt, pip, npm)   | 함수형 (Nix) |
| --------------- | ------------------------ | ------------ |
| **결정론성**    | ❌ 시점에 따라 다름      | ✅ 항상 동일 |
| **롤백**        | ❌ 매우 어려움           | ✅ 즉시 가능 |
| **격리**        | ⚠️ 부분적 (venv, docker) | ✅ 완전 격리 |
| **의존성 해결** | ❌ 수동 관리             | ✅ 자동 해결 |
| **재현성**      | ❌ 어려움                | ✅ 완벽함    |
| **학습 곡선**   | ✅ 쉬움                  | ⚠️ 가파름    |
| **디버깅**      | ❌ 어려움                | ✅ 쉬움      |

**실제 시간 비교:**

```nix
📊 새 팀원의 환경 구성 시간

명령형 방식:
- 의존성 설치 시도: 30분
- 충돌 해결 및 검색: 2시간
- 버전 맞추기: 1시간
- 문서 업데이트: 30분
총합: 4시간 (그리고 여전히 불완전할 수 있음)

함수형 방식 (Nix):
- nix-shell 실행: 5분 (최초 다운로드)
- 환경 확인: 1분
총합: 6분 (완벽하게 동일한 환경)
```nix

---

## 🎓 섹션 3 요약

**🔑 핵심 깨달음:**

1. **의존성 지옥의 근본 원인**

   - 가변 상태 (Mutable State)
   - 부작용 (Side Effects)
   - 시간 의존성 (Time Dependency)

2. **함수형 해결책**

   - **불변성** → 패키지는 절대 변하지 않음
   - **순수 함수** → 같은 설정 → 같은 환경
   - **참조 투명성** → 표현식을 값으로 대체 가능

3. **실무적 장점**
   - 결정론적 빌드
   - 완벽한 재현성
   - 안전한 롤백
   - 자동 의존성 해결

**🚀 다음에 배울 것:**

- Nix에서 이 함수형 개념들이 어떻게 **속성 집합(Attribute Sets)**으로 구현되는지
- JSON, jq와의 연관성을 통한 점진적 이해

---

함수형 프로그래밍이 단순한 프로그래밍 기법이 아니라, **시스템 관리 혁신**의 핵심임을 이해하셨나요? 🎯
