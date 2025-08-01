# Commit Convention Guide

이 문서는 playground docs 프로젝트의 커밋 메시지 작성 규칙을 정의합니다. 이 규칙을 따르면 자동화된 changelog 생성과 체계적인 버전 관리가 가능합니다.

## 📋 목차

- [기본 원칙](#-기본-원칙)
- [커밋 메시지 구조](#-커밋-메시지-구조)
- [커밋 타입](#-커밋-타입)
- [스코프 정의](#-스코프-정의)
- [실제 예시](#-스코프-정의)
- [특별한 경우들](#-특별한-경우들)
- [도구 사용법](#-도구-사용법)

## 🎯 기본 원칙

1. **[Conventional Commits](https://conventionalcommits.org/) 규격 준수**
2. **명확하고 간결한 메시지 작성**
3. **영어 사용 (일관성을 위해)**
4. **현재형 동사 사용** (`fix` not `fixed`)
5. **첫 글자 소문자** (타입 제외)

## 📝 커밋 메시지 구조

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### 예시

```text
feat(part2): add machine learning fundamentals chapter

새로운 ML 기초 개념과 scikit-learn 실습 예제를 추가했습니다.
TensorFlow 기본 예제도 포함되어 있습니다.

Closes #42
```

## 🏷️ 커밋 타입

| 타입       | 설명                                 | Changelog 포함 |
| ---------- | ------------------------------------ | -------------- |
| `feat`     | 새로운 기능, 챕터, 실습 추가         | ✅             |
| `fix`      | 버그 수정, 오타 수정, 코드 오류 수정 | ✅             |
| `docs`     | 문서 개선, 설명 보완 (내용 변경)     | ✅             |
| `style`    | 포맷팅, 스타일링 (내용 변경 없음)    | ✅             |
| `refactor` | 코드/구조 리팩토링                   | ✅             |
| `perf`     | 성능 개선, 빌드 최적화               | ✅             |
| `test`     | 테스트 추가, 실습 검증               | ❌             |
| `chore`    | 빌드, 의존성, 설정 변경              | ❌             |
| `ci`       | CI/CD 파이프라인 관련                | ❌             |
| `revert`   | 이전 커밋 되돌리기                   | ✅             |

## 🎯 스코프 정의

### 파트별 스코프 (책 구조 기반)

| 스코프  | 설명                      | 포함 내용                                                 |
| ------- | ------------------------- | --------------------------------------------------------- |
| `part1` | 기초 도구 및 환경         | Linux, Nix, Git, Security                                 |
| `part2` | 프로그래밍 및 데이터 과학 | Python, Data Science, ML                                  |
| `part3` | 생물정보학 도구           | Data Formats, Sequence Analysis, Omics, Synthetic Biology |
| `part4` | 고급 워크플로우           | Research Workflows, HPC, CI/CD                            |

### 챕터별 스코프

| 스코프 | 설명              |
| ------ | ----------------- |
| `ch01` | Linux 기초        |
| `ch02` | Nix 패키지 관리   |
| `ch03` | Git 버전 관리     |
| `ch04` | 보안 기초         |
| `ch05` | Python 프로그래밍 |
| `ch06` | 데이터 사이언스   |
| `ch07` | 머신러닝          |
| `ch08` | 데이터 포맷       |
| `ch09` | 서열 분석         |
| `ch10` | 오믹스 분석       |
| `ch11` | 합성생물학 도구   |
| `ch12` | 진화 공학         |
| `ch13` | 연구 워크플로우   |
| `ch14` | 고성능 컴퓨팅     |
| `ch15` | 연구용 CI/CD      |

### 기능별 스코프

| 스코프     | 설명                |
| ---------- | ------------------- |
| `practice` | 실습 자료 관련      |
| `docs`     | 문서 빌드/구조 관련 |
| `nix`      | Nix 설정 및 패키지  |
| `build`    | 빌드 시스템         |
| `release`  | 릴리즈 관련         |

## 💡 실제 예시

### ✅ 좋은 예시

```bash
# 새로운 챕터 추가
feat(part3): add genomics data visualization chapter

# 실습 자료 추가
feat(practice): add protein folding simulation exercises

# 버그 수정
fix(ch05-python): correct matplotlib import error in example

# 문서 개선
docs(part2): improve pandas tutorial explanations

# 구조 개편
refactor(docs): reorganize chapter numbering system

# Nix 관련
chore(nix): update python dependencies to latest versions

# 실습 오류 수정
fix(practice): fix broken symlinks in chapter02 exercises

# 성능 개선
perf(build): optimize mdbook compilation speed

# 스타일 개선
style(part1): improve code block formatting consistency
```

### ❌ 나쁜 예시

```bash
# 너무 모호함
fix: stuff

# 타입 없음
update chapter 5

# 대문자 시작
Fix: Update Python Examples

# 과거형 사용
fixed: corrected the bug in nix configuration

# 너무 김
feat(ch05-python): add a very comprehensive and detailed machine learning tutorial with tensorflow keras scikit-learn pandas numpy matplotlib seaborn plotly and many other libraries
```

## 🚨 특별한 경우들

### Breaking Changes

구조적 변경이나 기존 사용자에게 영향을 주는 변경사항:

```bash
feat(structure)!: reorganize entire book structure

BREAKING CHANGE: Chapter numbering has completely changed.
All existing bookmarks and references need to be updated.
```

### 멀티 스코프

여러 영역에 영향을 주는 경우:

```bash
feat(part2,part3): add unified data analysis workflow

# 또는 더 구체적으로
refactor(ch06-data_science,ch10-omics): standardize data loading patterns
```

### 이슈 참조

GitHub 이슈와 연결:

```bash
fix(ch02-nix): resolve flake build issues

Fixes #123, closes #124
```

### 협업자 크레딧

```bash
feat(part4): add kubernetes deployment guide

Co-authored-by: Jane Doe <jane@example.com>
```

## 🛠️ 도구 사용법

### 커밋 전 확인

```bash
# 변경사항 미리보기
nix run .#preview

# 또는 개발 환경에서
changelog-preview
```

### 커밋 템플릿 설정

```bash
# Git 커밋 템플릿 설정
git config commit.template .gitmessage
```

`.gitmessage` 파일:

```text
# <type>[scope]: <description>
#
# [optional body]
#
# [optional footer]

# 예시:
# feat(part2): add new machine learning chapter
#
# 새로운 ML 알고리즘 설명과 실습 예제 추가
#
# Closes #42
```

### 릴리즈 생성

```bash
# 자동 릴리즈 (날짜 기반)
nix run .#release

# 또는 개발 환경에서
release
```

## 📊 커밋 메시지 통계

릴리즈별 커밋 분포 확인:

```bash
# 마지막 릴리즈 이후 커밋 타입별 통계
git log $(git describe --tags --abbrev=0)..HEAD --oneline | \
  grep -oE '^[a-f0-9]+ (feat|fix|docs|style|refactor|perf|test|chore|ci)' | \
  cut -d' ' -f2 | sort | uniq -c | sort -nr
```

## ❓ FAQ

### Q: 작은 오타 수정도 `fix` 타입을 써야 하나요?

A: 네, 사용자에게 보이는 내용의 오타는 `fix` 타입을 사용합니다.

### Q: 실습 파일만 수정했을 때는 어떤 스코프를 쓰나요?

A: `practice` 스코프를 사용하거나, 특정 챕터와 관련이 있다면 해당 챕터 스코프를 사용합니다.

### Q: Nix 설정 변경은 어떤 타입을 쓰나요?

A: 사용자에게 영향을 주지 않는 내부 설정은 `chore(nix)`, 기능 개선이라면 `feat(nix)`를 사용합니다.

### Q: 여러 챕터에 걸친 수정은 어떻게 하나요?

A: 파트 스코프(`part1`, `part2` 등)를 사용하거나 가장 주요한 챕터 스코프를 선택합니다.

---

> 💡 **팁**: `git log --oneline | head -20` 명령어로 최근 커밋들의 패턴을 확인해보세요!

이 가이드를 따르면 자동화된 changelog와 체계적인 버전 관리가 가능합니다. 궁금한 점이 있다면 이슈를 통해 문의해 주세요.
