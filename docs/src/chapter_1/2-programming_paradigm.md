# 2. 프로그래밍 패러다임 이해

> _"Nix는 함수형 언어입니다."_
>
> 이 말이 정확히 무엇을 의미하는지, 왜 중요한지 알아봅시다.

## 2.1 명령형(절차지향) 프로그래밍: "어떻게(How)" 중심

### 🔧 특징

- **순차적 실행**: 위에서 아래로 명령어를 차례대로 실행
- **상태 변화**: 변수의 값을 계속 바꿔가며 작업
- **제어 구조**: if, for, while 등으로 실행 흐름 제어
- **부작용**: 함수 실행이 외부 상태를 변경

### 📝 C 언어 예제: 배열 합계 계산

```c
#include <stdio.h>

int main() {
    int numbers[] = {1, 2, 3, 4, 5};
    int size = 5;
    int sum = 0;                    // 상태 초기화

    for (int i = 0; i < size; i++) {
        sum = sum + numbers[i];     // 상태 변경 (sum 값이 계속 바뀜)
        printf("Step %d: sum = %d\n", i+1, sum);
    }

    printf("Final sum: %d\n", sum);
    return 0;
}
```nix

**실행 과정:**

```nix
Step 1: sum = 1    (sum이 0에서 1로 변경)
Step 2: sum = 3    (sum이 1에서 3으로 변경)
Step 3: sum = 6    (sum이 3에서 6으로 변경)
Step 4: sum = 10   (sum이 6에서 10으로 변경)
Step 5: sum = 15   (sum이 10에서 15로 변경)
Final sum: 15
```nix

### 🐚 Shell Script 예제: 디렉토리별 파일 개수 계산

```bash
#!/bin/bash

# 전체 파일 개수를 세는 스크립트
total=0                              # 상태 초기화

for dir in */; do                    # 각 디렉토리에 대해
    if [ -d "$dir" ]; then          # 디렉토리인지 확인
        count=$(find "$dir" -type f | wc -l)  # 파일 개수 계산
        total=$((total + count))     # 상태 변경 (total 값 누적)
        echo "$dir: $count files"
    fi
done

echo "Total files: $total"           # 최종 결과 출력
```nix

**명령형의 특징 분석:**

```bash
# 변수 값이 계속 변경됨
total=0      # total = 0
total=5      # total = 5 (처음 디렉토리)
total=12     # total = 12 (두 번째 디렉토리 추가)
total=18     # total = 18 (세 번째 디렉토리 추가)
```nix

## 2.2 객체지향 프로그래밍: "무엇(What)" 중심

### 🏗️ 특징

- **캡슐화**: 데이터와 메서드를 하나의 객체로 묶음
- **상속**: 기존 클래스의 특성을 새 클래스가 물려받음
- **다형성**: 같은 인터페이스로 다른 동작 수행
- **추상화**: 복잡한 내부 구현을 숨기고 간단한 인터페이스 제공

### 📝 Python 예제: 계산기 클래스

```python
class Calculator:
    def __init__(self):
        self.history = []           # 객체 상태 (계산 이력)

    def add(self, a, b):
        result = a + b
        self.history.append(f"{a} + {b} = {result}")  # 상태 변경
        return result

    def get_history(self):
        return self.history         # 상태 조회

# 사용 예시
calc = Calculator()
result1 = calc.add(5, 3)           # calc 객체의 상태가 변함
result2 = calc.add(10, 7)          # calc 객체의 상태가 또 변함
print(calc.get_history())          # ['5 + 3 = 8', '10 + 7 = 17']
```nix

**객체지향의 핵심:**

- **상태를 가진 객체**: `Calculator` 객체는 `history` 상태를 유지
- **메서드 호출**: 객체의 상태를 변경하거나 조회
- **캡슐화**: 내부 구현(`history` 관리)을 숨기고 메서드로만 접근

## 2.3 함수형 프로그래밍: "무엇(What)" + 함수 조합

### ⚡ 특징

- **불변성**: 한 번 만든 값은 절대 변경하지 않음
- **순수 함수**: 같은 입력 → 항상 같은 출력, 부작용 없음
- **참조 투명성**: 표현식을 그 값으로 바꿔도 프로그램 동작 불변
- **함수 조합**: 작은 함수들을 조합해서 복잡한 작업 수행

### 📝 JavaScript 예제: 명령형 vs 함수형 비교

**🔴 명령형 스타일 (상태 변경 방식):**

```javascript
// 숫자 배열에서 짝수만 골라서 제곱한 후 합계 구하기
function sumSquaredEvensImperative(numbers) {
  let result = 0; // 상태 변수

  for (let i = 0; i < numbers.length; i++) {
    if (numbers[i] % 2 === 0) {
      // 짝수 체크
      let squared = numbers[i] * numbers[i];
      result = result + squared; // 상태 변경
    }
  }

  return result;
}

const numbers = [1, 2, 3, 4, 5, 6];
console.log(sumSquaredEvensImperative(numbers)); // 56 (4 + 16 + 36)
```nix

**🟢 함수형 스타일 (불변성 + 함수 조합):**

```javascript
// 같은 작업을 함수형으로
function sumSquaredEvensFunctional(numbers) {
  return numbers
    .filter((n) => n % 2 === 0) // 짝수만 필터 [2, 4, 6]
    .map((n) => n * n) // 제곱 [4, 16, 36]
    .reduce((sum, n) => sum + n, 0); // 합계 56
}

const numbers = [1, 2, 3, 4, 5, 6];
console.log(sumSquaredEvensFunctional(numbers)); // 56
```nix

### 🔍 두 방식의 차이점 분석

| 특성          | 명령형                      | 함수형           |
| ------------- | --------------------------- | ---------------- |
| **변수 변경** | `result = result + squared` | 변수 변경 없음   |
| **실행 방식** | 순차적 명령어               | 함수 체이닝      |
| **가독성**    | "어떻게" 계산하는지         | "무엇을" 하는지  |
| **재사용성**  | 낮음 (상태 의존)            | 높음 (순수함수)  |
| **테스트**    | 어려움 (상태 관리)          | 쉬움 (입력→출력) |

### 🧮 순수 함수 vs 비순수 함수

**🔴 비순수 함수 (부작용 있음):**

```javascript
let globalCounter = 0;

function impureIncrement(value) {
  globalCounter++; // 전역 상태 변경 (부작용)
  console.log("Incrementing..."); // 출력 (부작용)
  return value + globalCounter;
}

console.log(impureIncrement(5)); // 6 (globalCounter = 1)
console.log(impureIncrement(5)); // 7 (globalCounter = 2)
// 같은 입력(5)인데 다른 출력! 예측 불가능
```nix

**🟢 순수 함수 (부작용 없음):**

```javascript
function pureIncrement(value, counter) {
  return {
    result: value + counter,
    newCounter: counter + 1,
  };
}

console.log(pureIncrement(5, 1)); // { result: 6, newCounter: 2 }
console.log(pureIncrement(5, 1)); // { result: 6, newCounter: 2 }
// 같은 입력 → 항상 같은 출력! 예측 가능
```nix

## 2.4 패러다임별 실제 사용 사례

### 🔧 명령형이 적합한 경우

```c
// 시스템 프로그래밍: 메모리 직접 관리
void* my_malloc(size_t size) {
    void* ptr = malloc(size);          // 시스템 호출
    if (ptr == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    memset(ptr, 0, size);              // 메모리 초기화
    return ptr;
}
```nix

### 🏗️ 객체지향이 적합한 경우

```python
# GUI 프로그래밍: 상태를 가진 컴포넌트
class Button:
    def __init__(self, text):
        self.text = text
        self.is_pressed = False
        self.click_handlers = []

    def click(self):
        self.is_pressed = True         # 상태 변경
        for handler in self.click_handlers:
            handler()                  # 이벤트 처리
```nix

### ⚡ 함수형이 적합한 경우

```javascript
// 데이터 변환 파이프라인
const processUserData = (users) =>
  users
    .filter((user) => user.isActive)
    .map((user) => ({
      ...user,
      fullName: `${user.firstName} ${user.lastName}`,
    }))
    .sort((a, b) => a.fullName.localeCompare(b.fullName));
```nix

## 2.5 Nix가 함수형인 이유

### 🎯 Nix에서 함수형 특성들

### 1. 불변성 (Immutability)

```nix
# 한 번 정의된 값은 변경 불가
let
    version = "1.0.0";
    # version = "2.0.0";  # 에러! 다시 할당 불가
in
    version
```nix

### 2. 순수 함수 (Pure Functions)

```nix
# 같은 입력 → 항상 같은 결과
buildPackage = { name, version, src }: {
    inherit name version src;
    buildCommand = "make install";
};

# 호출할 때마다 동일한 결과
pkg1 = buildPackage { name = "hello"; version = "1.0"; src = ./.; };
pkg2 = buildPackage { name = "hello"; version = "1.0"; src = ./.; };
# pkg1과 pkg2는 완전히 동일함
```nix

### 3. 참조 투명성 (Referential Transparency)

```nix
let
    pythonVersion = "3.8";
    pythonPackage = pkgs.python38;  # pythonVersion에 의존
in
{
    # pythonPackage를 pkgs.python38로 바꿔도 결과 동일
    buildInputs = [ pythonPackage ];
}
```nix

### 🔄 명령형 vs Nix 패키지 관리 비교

**🔴 명령형 패키지 관리:**

```bash
# 순차적으로 상태 변경
sudo apt update                    # 패키지 목록 상태 변경
sudo apt install python3          # 시스템 상태 변경
pip install django                 # Python 환경 상태 변경
# 각 단계에서 시스템 상태가 변함
# 중간에 실패하면 불일치 상태
```nix

**🟢 함수형 패키지 관리 (Nix):**

```nix
# 선언적으로 최종 상태 정의
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
    buildInputs = with pkgs; [
        python38                   # 정확한 버전
        python38Packages.django    # 정확한 Django 버전
    ];
}
# 전체가 하나의 "함수" 처럼 동작
# 입력(nixpkgs) → 출력(환경) 변환
```nix

## 2.6 패러다임 선택 가이드

### 🤔 어떤 패러다임을 언제 사용할까?

```nix
📊 복잡도 vs 예측가능성 매트릭스

높은 예측가능성  ↑
                │  [함수형]        [함수형 + 객체지향]
                │  • 설정 관리     • 복잡한 도메인 모델
                │  • 데이터 변환   • 함수형 언어
                │  • Nix          • Scala, F#
                │
                │  [명령형]        [객체지향]
                │  • 시스템 프로그래밍  • 엔터프라이즈 앱
                │  • 성능 최적화   • GUI 프로그래밍
                │  • 저수준 제어   • 게임 개발
                │
                └─────────────────────────────────→
                낮은 복잡도                    높은 복잡도
```nix

### 🎯 Nix가 함수형을 선택한 이유

### 1. 예측 가능성 (Predictability)

```nix
# 같은 설정 파일 → 항상 같은 시스템
{ config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        vim git curl
    ];
}
# 언제 어디서 실행해도 동일한 결과
```nix

### 2. 조합 가능성 (Composability)

```nix
# 작은 함수들을 조합해서 복잡한 시스템 구성
webServer = { port, content }: { ... };
database = { dbname, user }: { ... };
monitoring = { targets }: { ... };

# 조합
fullStack = {
    services = {
        nginx = webServer { port = 80; content = ./web; };
        postgresql = database { dbname = "myapp"; user = "admin"; };
        prometheus = monitoring { targets = ["localhost:3000"]; };
    };
};
```nix

### 3. 안전성 (Safety)

```nix
# 불변성으로 인한 안전성
# 실수로 시스템을 망가뜨리는 일이 없음
# 언제든 이전 상태로 롤백 가능
```nix

---

## 🎓 섹션 2 요약

| 패러다임     | 핵심 특징              | 장점                         | 단점                          | Nix와의 관련성          |
| ------------ | ---------------------- | ---------------------------- | ----------------------------- | ----------------------- |
| **명령형**   | 순차 실행, 상태 변경   | 직관적, 성능 최적화 용이     | 예측 어려움, 버그 발생 위험   | ❌ 시스템 관리에 부적합 |
| **객체지향** | 캡슐화, 상속, 다형성   | 코드 재사용, 모듈화          | 복잡성 증가, 상태 관리 어려움 | 🔶 부분적 활용          |
| **함수형**   | 불변성, 순수함수, 조합 | 예측 가능, 테스트 용이, 안전 | 학습 곡선, 성능 오버헤드      | ✅ **Nix의 핵심**       |

**🔑 핵심 깨달음:**

- Nix는 **시스템 관리**를 **함수형 프로그래밍**으로 접근
- 설정 파일 = 순수 함수 = 같은 입력 → 같은 시스템
- 불변성 → 안전한 업데이트 → 언제든 롤백 가능

---

🎯 **다음 섹션 예고**

이제 함수형 프로그래밍의 핵심 개념들을 더 자세히 알아봅시다:

- **불변성**이 정확히 무엇인지
- **순수 함수**를 어떻게 작성하는지
- **참조 투명성**이 Nix에서 어떻게 활용되는지

준비되셨나요? 🚀
