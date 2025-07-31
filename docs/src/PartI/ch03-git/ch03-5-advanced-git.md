# 3.5 Advanced Git and Troubleshooting

## 핵심 개념

고급 Git 기능과 문제 해결 기법은 복잡한 생물정보학 프로젝트에서 발생하는 다양한 상황을 효과적으로 관리하는 데 필수적입니다. 대용량 데이터셋, 장기간 실행되는 분석, 복잡한 협업 환경에서 Git을 안정적으로 활용하기 위한 고급 기법들을 다룹니다.

### Git Stash: 작업 임시 저장

Stash는 현재 작업 중인 변경사항을 임시로 저장하여 브랜치를 깔끔하게 전환하거나 긴급한 작업을 수행할 수 있게 합니다. 생물정보학 연구에서는 장시간 실행되는 분석 중 긴급한 버그 수정이나 매개변수 조정이 필요할 때 유용합니다.

```bash
# 기본 stash 사용법
git stash                           # 현재 변경사항을 stash에 저장
git stash push -m "WIP: optimize memory usage in alignment"  # 메시지와 함께 저장
git stash list                      # stash 목록 확인
git stash show                      # 최신 stash 내용 요약
git stash show -p                   # 상세한 diff 확인

# stash 복원
git stash pop                       # 최신 stash를 적용하고 삭제
git stash apply                     # stash를 적용하지만 삭제하지 않음
git stash apply stash@{2}          # 특정 stash 적용
git stash drop stash@{1}           # 특정 stash 삭제
git stash clear                    # 모든 stash 삭제
```

고급 stash 활용:

```bash
# 선택적 stash
git stash push --keep-index         # 스테이징된 파일은 유지하고 나머지만 stash
git stash push --include-untracked  # 추적되지 않는 파일도 포함
git stash push -p                   # 대화형으로 일부분만 stash

# 특정 파일만 stash
git stash push -m "Save config changes" config/pipeline.yaml
git stash push -- "*.log"          # 패턴 매칭으로 특정 파일들만

# stash 브랜치 생성
git stash branch feature-memory-fix stash@{0}  # stash로부터 새 브랜치 생성

# 실제 사용 시나리오
# 상황: RNA-seq 분석 매개변수를 조정 중인데 긴급한 버그 수정이 필요
git stash push -m "WIP: RNA-seq parameter optimization"
git checkout main
git checkout -b hotfix-alignment-bug
# ... 버그 수정 작업 ...
git checkout feature-rna-seq-params
git stash pop
```

### Cherry-pick: 선택적 커밋 적용

Cherry-pick은 특정 커밋만을 선택적으로 다른 브랜치에 적용하는 기능입니다. 생물정보학에서는 실험 브랜치의 특정 개선사항만을 메인 브랜치에 백포트하거나, 버그 수정을 여러 브랜치에 적용할 때 유용합니다.

```bash
# 기본 cherry-pick
git cherry-pick abc1234             # 특정 커밋을 현재 브랜치에 적용
git cherry-pick abc1234..def5678    # 커밋 범위 적용 (abc1234는 제외)
git cherry-pick abc1234^..def5678   # 커밋 범위 적용 (abc1234 포함)

# 여러 커밋 cherry-pick
git cherry-pick abc1234 def5678 ghi9012

# cherry-pick 옵션들
git cherry-pick -n abc1234          # 커밋하지 않고 변경사항만 적용
git cherry-pick -x abc1234          # 원본 커밋 정보를 메시지에 추가
git cherry-pick --no-commit abc1234 # 자동 커밋 비활성화

# 충돌 해결
git cherry-pick abc1234
# 충돌 발생 시
git status                          # 충돌 파일 확인
# ... 충돌 해결 ...
git add resolved-file.py
git cherry-pick --continue          # cherry-pick 계속
git cherry-pick --abort             # cherry-pick 취소
```

실제 사용 사례:

```bash
# 시나리오: 실험 브랜치의 성능 최적화를 메인 브랜치에 적용
git log --oneline experiment/deep-learning
# a1b2c3d feat: optimize GPU memory usage
# e4f5g6h feat: add neural network layer
# i7j8k9l fix: memory leak in training loop

git checkout main
git cherry-pick a1b2c3d             # GPU 메모리 최적화만 적용
git cherry-pick i7j8k9l             # 메모리 누수 수정도 적용
# 신경망 레이어는 실험적이므로 제외

# 여러 브랜치에 버그 수정 적용
bug_fix_commit="m1n2o3p"
for branch in release/v2.0 release/v2.1 develop; do
    git checkout $branch
    git cherry-pick $bug_fix_commit
done
```

### Git Rebase 고급 활용

Rebase는 커밋 이력을 정리하고 선형적으로 만드는 강력한 도구입니다. 대화형 rebase를 통해 커밋 메시지 수정, 커밋 분할/병합, 순서 변경 등이 가능합니다.

```bash
# 대화형 rebase
git rebase -i HEAD~5                # 최근 5개 커밋 편집
git rebase -i main                  # main 이후의 모든 커밋 편집

# rebase 편집 옵션들:
# pick (p): 커밋 그대로 사용
# reword (r): 커밋 메시지 수정
# edit (e): 커밋 수정 (파일 변경 가능)
# squash (s): 이전 커밋과 합치고 메시지 수정
# fixup (f): 이전 커밋과 합치고 메시지 버리기
# drop (d): 커밋 삭제
```

대화형 rebase 예시:

```bash
# 편집기에서 표시되는 내용
pick a1b2c3d feat: add quality control module
pick e4f5g6h fix: typo in variable name
pick i7j8k9l feat: improve memory efficiency
pick m1n2o3p fix: handle empty input files
pick q5r6s7t docs: update README with examples

# 편집 후:
pick a1b2c3d feat: add quality control module
fixup e4f5g6h fix: typo in variable name
pick i7j8k9l feat: improve memory efficiency
squash m1n2o3p fix: handle empty input files
reword q5r6s7t docs: update README with examples

# 결과: 5개 커밋이 3개로 정리됨
```

커밋 분할과 수정:

```bash
# 특정 커밋을 여러 개로 분할
git rebase -i HEAD~3
# 편집기에서 분할하려는 커밋을 'edit'으로 변경

# rebase가 해당 커밋에서 멈춤
git reset HEAD~                     # 커밋 취소하고 변경사항을 작업 디렉토리로
git add scripts/qc.py              # 첫 번째 부분만 스테이징
git commit -m "feat: add quality control core functions"
git add config/qc_params.yaml     # 두 번째 부분 스테이징
git commit -m "config: add QC parameter defaults"
git rebase --continue              # rebase 계속
```

### Git Hooks: 자동화와 정책 강제

Git hooks는 특정 Git 이벤트가 발생할 때 자동으로 실행되는 스크립트입니다. 생물정보학 프로젝트에서는 코드 품질 검사, 테스트 자동 실행, 데이터 검증 등에 활용할 수 있습니다.

```bash
# hooks 디렉토리 확인
ls -la .git/hooks/
# 기본적으로 .sample 파일들이 있음

# pre-commit hook 생성 (커밋 전 실행)
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# 생물정보학 프로젝트용 pre-commit hook

echo "Running pre-commit checks..."

# Python 코드 스타일 검사
if command -v black &> /dev/null; then
    echo "Checking Python code format..."
    black --check scripts/ || {
        echo "Code formatting issues found. Run 'black scripts/' to fix."
        exit 1
    }
fi

# 테스트 실행
if [ -d "tests" ]; then
    echo "Running tests..."
    python -m pytest tests/ || {
        echo "Tests failed. Please fix before committing."
        exit 1
    }
fi

# 대용량 파일 검사
echo "Checking for large files..."
for file in $(git diff --cached --name-only); do
    if [ -f "$file" ]; then
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        if [ "$size" -gt 104857600 ]; then  # 100MB
            echo "Error: $file is larger than 100MB"
            echo "Large data files should not be committed to Git"
            exit 1
        fi
    fi
done

echo "Pre-commit checks passed!"
EOF

chmod +x .git/hooks/pre-commit
```

다른 유용한 hooks:

```bash
# commit-msg hook (커밋 메시지 검증)
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash
# 커밋 메시지 형식 검증

commit_regex='^(feat|fix|docs|style|refactor|test|chore|data|analysis)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format!"
    echo "Format: type(scope): description"
    echo "Example: feat(alignment): add BWA-MEM2 support"
    exit 1
fi
EOF

chmod +x .git/hooks/commit-msg

# pre-push hook (푸시 전 실행)
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
# 푸시 전 통합 테스트 실행

echo "Running integration tests before push..."
if [ -f "run_integration_tests.sh" ]; then
    ./run_integration_tests.sh || {
        echo "Integration tests failed. Push aborted."
        exit 1
    }
fi
EOF

chmod +x .git/hooks/pre-push
```

### 대용량 파일과 성능 최적화

생물정보학 프로젝트는 종종 대용량 데이터 파일을 다룹니다. Git은 기본적으로 이런 파일에 최적화되어 있지 않으므로 특별한 관리가 필요합니다.

```bash
# Git LFS (Large File Storage) 설정
git lfs install                     # LFS 활성화
git lfs track "*.bam"               # BAM 파일을 LFS로 관리
git lfs track "*.fastq.gz"          # 압축된 FASTQ 파일
git lfs track "data/large/*"        # 특정 디렉토리

# .gitattributes 파일 자동 생성 확인
cat .gitattributes
# *.bam filter=lfs diff=lfs merge=lfs -text
# *.fastq.gz filter=lfs diff=lfs merge=lfs -text

# LFS 파일 상태 확인
git lfs ls-files                    # LFS로 관리되는 파일 목록
git lfs status                      # LFS 파일 상태

# 기존 대용량 파일을 LFS로 마이그레이션
git lfs migrate import --include="*.bam" --everything
```

저장소 최적화:

```bash
# 저장소 크기 확인
git count-objects -vH
# count 2847
# size 45.67 MiB
# in-pack 28234
# packs 1
# size-pack 123.45 MiB

# 가비지 컬렉션
git gc                              # 표준 정리
git gc --aggressive                 # 더 철저한 정리 (시간이 오래 걸림)

# 참조되지 않는 객체 제거
git prune                           # 2주 이상 된 객체 제거
git prune --expire=1.week          # 1주 이상 된 객체 제거

# 저장소 압축 최적화
git repack -ad                      # 모든 객체를 하나의 팩 파일로 압축

# 히스토리에서 완전히 파일 제거 (위험!)
git filter-branch --tree-filter 'rm -f large_data.bam' HEAD
git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin
git gc --prune=now
```

### 문제 해결과 복구

Git 사용 중 발생할 수 있는 다양한 문제 상황과 해결 방법을 다룹니다.

**커밋 복구**:

```bash
# 실수로 삭제한 커밋 복구
git reflog                          # 최근 HEAD 이동 이력 확인
git show HEAD@{5}                   # 5단계 전 상태 확인
git reset --hard HEAD@{5}           # 해당 상태로 복구

# 삭제된 브랜치 복구
git reflog --all | grep branch-name
git checkout -b recovered-branch commit-hash

# 특정 파일의 이전 버전 복구
git checkout HEAD~3 -- important-script.py    # 3커밋 전 버전으로 복구
git checkout branch-name -- missing-file.py   # 다른 브랜치에서 파일 가져오기
```

**머지 충돌 고급 해결**:

```bash
# 복잡한 충돌 상황에서 전략 선택
git merge -X ours feature-branch               # 충돌 시 현재 브랜치 우선
git merge -X theirs feature-branch             # 충돌 시 머지 브랜치 우선

# 특정 파일만 선택적으로 해결
git checkout --ours scripts/config.py         # 현재 브랜치 버전 선택
git checkout --theirs scripts/analysis.py     # 머지 브랜치 버전 선택
git add scripts/config.py scripts/analysis.py
git commit

# 3-way diff로 충돌 해결
git mergetool --tool=vimdiff                   # 시각적 도구 사용
```

**corrupted 저장소 복구**:

```bash
# 저장소 무결성 검사
git fsck --full                     # 전체 무결성 검사
git fsck --unreachable             # 참조되지 않는 객체 확인

# 객체 손상 시 복구
git hash-object -w file.txt         # 파일에서 객체 재생성
git update-index --add file.txt     # 인덱스 업데이트

# 백업에서 복구
git remote add backup /path/to/backup/repo
git fetch backup
git reset --hard backup/main       # 백업으로 완전 복구
```

**성능 문제 진단**:

```bash
# 느린 명령어 디버깅
git config --global core.preloadindex true    # 인덱스 미리 로드
git config --global core.fscache true         # 파일시스템 캐시 활성화
git config --global gc.auto 256               # 자동 GC 빈도 조정

# 큰 파일 찾기
git rev-list --objects --all | \
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
  sed -n 's/^blob //p' | \
  sort --numeric-sort --key=2 | \
  tail -10                          # 가장 큰 10개 파일

# 히스토리 분석
git log --stat --summary | grep -E "^ (create|delete) mode" | wc -l    # 생성/삭제된 파일 수
git shortlog -sn                                                        # 기여자별 커밋 수
```

## Practice Section: 고급 Git 기능 실습

### 실습 1: Stash 활용

```bash
cd ~/bioproject

# 작업 중인 변경사항 생성
echo "# TODO: implement advanced QC" >> scripts/qc.py
echo "memory_limit = '64GB'" >> config/settings.yaml

# Stash로 임시 저장
git stash push -m "WIP: QC improvements and memory config"
git status  # 깨끗한 상태 확인

# 다른 작업 수행
echo "def emergency_fix(): pass" > scripts/hotfix.py
git add scripts/hotfix.py
git commit -m "hotfix: add emergency repair function"

# 이전 작업 복원
git stash list
git stash pop
git status
```

### 실습 2: Cherry-pick 연습

```bash
# 실험 브랜치 생성
git checkout -b experiment/optimization
echo "# Performance optimization" > scripts/optimize.py
git add scripts/optimize.py
git commit -m "feat: add performance optimization"

echo "def fast_align(): pass" >> scripts/optimize.py
git add scripts/optimize.py
git commit -m "feat: implement fast alignment algorithm"

# 메인으로 돌아가서 첫 번째 커밋만 적용
git checkout main
COMMIT_HASH=$(git log experiment/optimization --oneline | tail -1 | cut -d' ' -f1)
git cherry-pick $COMMIT_HASH

git log --oneline -3
```

### 실습 3: 대화형 Rebase

```bash
# 여러 커밋 생성
git checkout -b feature/cleanup
echo "import sys" > scripts/utils.py
git add scripts/utils.py
git commit -m "add utils module"

echo "import os" >> scripts/utils.py
git add scripts/utils.py
git commit -m "add os import"

echo "def helper(): pass" >> scripts/utils.py
git add scripts/utils.py
git commit -m "add helper function"

# 커밋 정리 (실제로는 편집기가 열림)
echo "Commits created for rebase practice"
git log --oneline -3
```

### 실습 4: Git Hooks 설정

```bash
# 간단한 pre-commit hook 생성
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running pre-commit checks..."

# Python 파일 기본 문법 검사
for file in $(git diff --cached --name-only | grep '\.py$'); do
    if [ -f "$file" ]; then
        python -m py_compile "$file" || {
            echo "Syntax error in $file"
            exit 1
        }
    fi
done

echo "Pre-commit checks passed!"
EOF

chmod +x .git/hooks/pre-commit

# Hook 테스트
echo "invalid python syntax!" > scripts/bad_syntax.py
git add scripts/bad_syntax.py
# git commit -m "test hook" # 이 커밋은 실패해야 함
git reset HEAD scripts/bad_syntax.py
rm scripts/bad_syntax.py
```

### 실습 5: 문제 해결 시뮬레이션

```bash
# 커밋 실수 시뮬레이션
echo "sensitive_data = 'password123'" > scripts/secret.py
git add scripts/secret.py
git commit -m "accidentally commit secret"

# 방금 커밋 수정
git reset --soft HEAD~1
rm scripts/secret.py
echo "secret.py" >> .gitignore
git add .gitignore
git commit -m "fix: add .gitignore for sensitive files"

# reflog로 이력 확인
git reflog | head -5
echo "Problem resolved using git reset"
```

## 핵심 정리

### 고급 Git 명령어

```bash
# Stash 관리
git stash push -m "message"        # 작업 임시 저장
git stash pop                      # 최신 stash 적용 및 삭제
git stash list                     # stash 목록 확인

# 선택적 적용
git cherry-pick <commit>           # 특정 커밋 적용
git rebase -i HEAD~n              # 대화형 리베이스

# 문제 해결
git reflog                         # HEAD 이동 이력
git fsck --full                   # 저장소 무결성 검사
git reset --hard HEAD@{n}         # 특정 시점으로 복구
```

### 생물정보학 프로젝트 최적화

```bash
# 대용량 파일 관리
git lfs track "*.bam"             # LFS로 큰 파일 관리
git gc --aggressive               # 저장소 최적화

# Hooks 활용
.git/hooks/pre-commit             # 커밋 전 검증
.git/hooks/pre-push              # 푸시 전 테스트

# 성능 튜닝
git config core.preloadindex true # 인덱스 미리 로드
git config gc.auto 256           # 자동 GC 조정
```

---

**Chapter 3 완료**: Git을 통한 버전 관리와 협업의 모든 측면을 다뤘습니다. 다음 장에서는 암호학과 보안의 기초를 학습하겠습니다.

**다음**: [Chapter 4: Cryptography and Security Fundamentals](../ch04-crypto/ch04-0-introduction-to-crypto.md)
