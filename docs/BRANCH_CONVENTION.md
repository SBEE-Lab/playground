# Branch Management Guide

이 가이드는 playground docs 프로젝트의 브랜치 관리 전략과 워크플로우를 설명합니다.

## 🌳 브랜치 구조

```text
main (🔒 protected)
├── develop (🔄 integration)
├── feature/
│   ├── part1-linux-advanced
│   ├── part2-ml-deep-learning
│   └── part3-genomics-pipeline
├── content/
│   ├── ch05-python-update
│   └── typo-fixes-batch
├── practice/
│   ├── chapter02-nix-exercises
│   └── ml-project-templates
├── infra/
│   ├── ci-workflow-improvements
│   ├── nix-environment-update
│   ├── changelog-enhancements
│   └── build-system-upgrade
├── docs/
│   └── contribution-guide
└── hotfix/
    └── critical-security-update
```

## 🎯 브랜치별 용도

### 메인 브랜치

| 브랜치    | 목적                | 보호 | 배포         |
| --------- | ------------------- | ---- | ------------ |
| `main`    | 안정적인 최종 버전  | ✅   | GitHub Pages |
| `develop` | 개발 중인 내용 통합 | ⚠️   | -            |

### 작업 브랜치

| 접두사      | 용도             | 병합 대상 | 예시                               |
| ----------- | ---------------- | --------- | ---------------------------------- |
| `feature/`  | 새로운 기능/챕터 | `develop` | `feature/part3-genomics-pipeline`  |
| `content/`  | 기존 콘텐츠 개선 | `develop` | `content/ch05-python-update`       |
| `practice/` | 실습 자료 관련   | `develop` | `practice/chapter02-nix-exercises` |
| `infra/`    | 인프라 관련      | `develop` | `infra/ci-workflow`                |
| `docs/`     | 문서 개선        | `develop` | `docs/contribution-guide`          |
| `hotfix/`   | 긴급 수정        | `main`    | `hotfix/critical-security-update`  |

## 🔄 워크플로우

### 1. 일반적인 개발 플로우

```bash
# 1. develop에서 새 브랜치 생성
git checkout develop
git pull origin develop
git checkout -b feature/part2-advanced-ml

# 2. 작업 수행
# ... 개발 작업 ...

# 3. 커밋 (커밋 컨벤션 준수)
git add .
git commit -m "feat(part2): add advanced ML algorithms chapter"

# 4. 푸시 및 PR 생성
git push origin feature/part2-advanced-ml
# GitHub에서 develop <- feature/part2-advanced-ml PR 생성
```

### 2. 긴급 수정 플로우

```bash
# 1. main에서 hotfix 브랜치 생성
git checkout main
git pull origin main
git checkout -b hotfix/critical-security-update

# 2. 수정 작업
# ... 긴급 수정 ...

# 3. 커밋
git commit -m "fix(security): resolve critical vulnerability in auth module"

# 4. main으로 직접 PR
git push origin hotfix/critical-security-update
# GitHub에서 main <- hotfix/critical-security-update PR 생성
```

### 3. 릴리즈 플로우

```bash
# 1. develop의 변경사항을 main으로 병합
# GitHub에서 main <- develop PR 생성 및 리뷰

# 2. main으로 병합되면 자동으로:
# - 문서 빌드
# - 릴리즈 생성 (변경사항이 있는 경우)
# - GitHub Pages 배포
```

### 4. 인프라 관련 작업 플로우

```bash
# 1. CI/CD 워크플로우 개선
git checkout develop
git pull origin develop
git checkout -b infra/improve-pr-preview

# 2. 인프라 작업 수행
# ... GitHub Actions, Nix 환경, 빌드 시스템 등 ...

# 3. 커밋 (인프라 관련 스코프 사용)
git add .
git commit -m "feat(infra): enhance PR preview with changelog integration"

# 4. 푸시 및 PR 생성
git push origin infra/improve-pr-preview
# GitHub에서 develop <- infra/improve-pr-preview PR 생성
```

## 🏗️ 인프라 브랜치 상세 가이드

### infra/ 브랜치가 담당하는 영역

| 영역            | 설명                              | 파일 예시                      |
| --------------- | --------------------------------- | ------------------------------ |
| **CI/CD**       | GitHub Actions, 자동화 파이프라인 | `.github/workflows/`           |
| **빌드 시스템** | 문서 빌드, 배포 설정              | `nix/packages/build-docs.nix`  |
| **개발 환경**   | Nix 환경, 의존성 관리             | `flake.nix`, `nix/shells/`     |
| **도구 설정**   | Changelog, 린팅, 포맷팅           | `.cliff.toml`, `.editorconfig` |
| **보안/시크릿** | SOPS, 암호화 설정                 | `.sops.yaml`                   |
| **모니터링**    | 사이트 상태, 성능 체크            | 모니터링 스크립트              |

### 인프라 관련 커밋 스코프

```bash
# 인프라 관련 커밋 예시
feat(infra): add automated changelog generation
fix(ci): resolve build cache issues in GitHub Actions
chore(nix): update development dependencies
feat(tools): implement pre-commit hooks for markdown
fix(build): resolve mdBook compilation errors
feat(deploy): add blue-green deployment strategy
```

## 🔧 로컬 개발 설정

### Git 설정

```bash
# 브랜치별 자동 푸시 설정
git config push.default current

# 커밋 템플릿 설정
git config commit.template .gitmessage

# 브랜치 자동 정리 설정
git config fetch.prune true
```

### 개발 환경 스크립트

```bash
# scripts/dev-setup.sh
#!/bin/bash

# Nix 개발 환경 진입
echo "🏗️  Entering Nix development shell..."
nix develop

# 브랜치 상태 확인
echo "📊 Current branch status:"
git status --short
git log --oneline -5

# 체인지로그 미리보기
echo "📖 Unreleased changes:"
changelog-preview
```

## 📋 PR 체크리스트

### 새 기능/콘텐츠 추가 시

- [ ] 적절한 브랜치명 사용 (`feature/`, `content/`, `infra/` 등)
- [ ] 커밋 메시지가 컨벤션 준수
- [ ] 새로운 파일이 적절한 위치에 배치
- [ ] 실습 파일이 있다면 `practice` 디렉토리에 정리
- [ ] 빌드 테스트 통과
- [ ] 충돌(conflict) 해결 완료

### 인프라 변경 시 추가 체크리스트

- [ ] CI/CD 변경 시 기존 워크플로우와 호환성 확인
- [ ] Nix 환경 변경 시 `nix develop` 테스트
- [ ] 새로운 의존성 추가 시 라이선스 확인
- [ ] 보안 관련 변경 시 시크릿 노출 여부 확인
- [ ] 빌드 시스템 변경 시 로컬/CI 양쪽에서 테스트
  > > > > > > > d29a018 (feat(docs, ci): add contribution guide on docs/)

### 병합 전 확인사항

- [ ] CI/CD 파이프라인 통과
- [ ] 최소 1명의 리뷰어 승인
- [ ] 모든 대화(conversation) 해결
- [ ] develop 브랜치와 충돌 없음

## 🚨 브랜치 보호 규칙

### main 브랜치

```yaml
# GitHub 브랜치 보호 설정
protection_rules:
  main:
    required_status_checks: true
    required_pull_request_reviews:
      required_approving_review_count: 1
      dismiss_stale_reviews: true
    enforce_admins: false
    restrictions: null
```

### develop 브랜치

```yaml
protection_rules:
  develop:
    required_status_checks: true
    required_pull_request_reviews:
      required_approving_review_count: 1
    enforce_admins: false
```

## 🧹 브랜치 정리

### 자동 정리

- **병합된 브랜치**: PR 병합 시 자동 삭제
- **오래된 브랜치**: 30일 이상 미사용 시 알림

### 수동 정리

```bash
# 로컬 브랜치 정리
git branch --merged | grep -v '\*\|main\|develop' | xargs -n 1 git branch -d

# 원격 브랜치 정보 동기화
git remote prune origin

# 오래된 브랜치 확인
git for-each-ref --format='%(refname:short) %(committerdate)' refs/heads | sort -k2
```

## 📊 브랜치 통계

### 활성 브랜치 모니터링

```bash
# scripts/branch-stats.sh
#!/bin/bash

echo "📊 Branch Statistics"
echo "==================="

echo "🌟 Active branches:"
git branch -r --sort=-committerdate | head -10

echo ""
echo "📈 Commit activity (last 7 days):"
git log --all --since="7 days ago" --oneline --pretty=format:"%h %an %s" | head -20

echo ""
echo "🔀 Recent merges:"
git log --merges --oneline -10
```

## ❓ FAQ

### Q: feature 브랜치를 언제 develop으로 병합해야 하나요?

A: 기능이 완성되고 테스트를 통과했을 때 병합합니다. 작은 단위로 자주 병합하는 것을 권장합니다.

### Q: main과 develop 사이의 차이가 너무 클 때는?

A: 정기적으로 (주 1-2회) develop을 main으로 병합하여 차이를 최소화합니다.

### Q: hotfix는 develop에도 반영해야 하나요?

A: 네, hotfix가 main에 병합된 후 develop에도 cherry-pick하거나 병합해야 합니다.

### Q: 브랜치명을 잘못 지었을 때는?

A: 로컬에서는 `git branch -m old-name new-name`, 원격에서는 새 이름으로 푸시 후 기존 브랜치 삭제합니다.

---

> 💡 **팁**: `git log --graph --pretty=oneline --abbrev-commit --all` 명령어로 브랜치 히스토리를 시각적으로 확인할 수 있습니다!
