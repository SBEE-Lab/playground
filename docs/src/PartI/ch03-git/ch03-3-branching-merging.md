# 3.3 Branching and Merging

## 핵심 개념

브랜치는 Git의 가장 강력한 기능 중 하나로, 메인 개발 라인에서 분기하여 독립적인 작업을 수행할 수 있게 합니다. 생물정보학 연구에서는 실험적 분석 방법, 매개변수 조정, 새로운 알고리즘 테스트를 위해 브랜치를 활용하여 안정적인 메인 코드를 보호하면서 혁신적인 시도를 할 수 있습니다.

### 브랜치 모델과 동작 원리

Git의 브랜치는 커밋을 가리키는 가벼운 포인터입니다. 새로운 브랜치를 생성해도 저장소 크기가 거의 증가하지 않으며, 브랜치 간 전환도 매우 빠릅니다.

```bash
# 브랜치 구조 시각화
$ git log --oneline --graph --all
* a1b2c3d (HEAD -> feature-qc) feat(qc): Add advanced quality metrics
* e4f5g6h (main) fix(pipeline): Correct alignment parameters
* i7j8k9l feat(data): Add sample metadata processing
* m1n2o3p Initial commit

# 브랜치는 단순히 커밋 해시를 가리키는 파일
$ cat .git/refs/heads/main
e4f5g6h1234567890abcdef1234567890abcdef12

$ cat .git/refs/heads/feature-qc
a1b2c3d1234567890abcdef1234567890abcdef12
```

HEAD 포인터의 역할:

```bash
# HEAD는 현재 작업 중인 브랜치를 가리킴
$ cat .git/HEAD
ref: refs/heads/feature-qc

# 브랜치 전환 시 HEAD가 이동
$ git checkout main
$ cat .git/HEAD
ref: refs/heads/main

# detached HEAD 상태 (특정 커밋으로 이동)
$ git checkout a1b2c3d
$ cat .git/HEAD
a1b2c3d1234567890abcdef1234567890abcdef12
```

### 브랜치 생성과 관리

효과적인 브랜치 관리는 연구 프로젝트의 복잡도와 팀 규모에 따라 달라집니다. 생물정보학 프로젝트에서는 분석 방법별, 데이터셋별, 또는 연구 단계별로 브랜치를 구성할 수 있습니다.

```bash
# 브랜치 생성 방법들
git branch feature-alignment          # 브랜치 생성 (전환하지 않음)
git checkout -b feature-alignment     # 브랜치 생성 후 전환
git switch -c feature-alignment       # Git 2.23+ 새로운 문법

# 특정 시점에서 브랜치 생성
git checkout -b hotfix-bug main       # main에서 분기
git checkout -b experiment-v2 a1b2c3d # 특정 커밋에서 분기

# 브랜치 목록 확인
git branch                            # 로컬 브랜치만
git branch -a                         # 로컬과 원격 브랜치 모두
git branch -v                         # 마지막 커밋 정보와 함께
git branch --merged                   # 병합된 브랜치들
git branch --no-merged                # 병합되지 않은 브랜치들
```

브랜치 명명 규칙:

```bash
# 생물정보학 프로젝트 브랜치 명명 예시
feature/rna-seq-pipeline             # 새 기능 개발
bugfix/alignment-memory-leak         # 버그 수정
experiment/deep-learning-model       # 실험적 기능
analysis/patient-cohort-2024         # 특정 분석
data/gtex-v8-integration            # 데이터 통합
config/cluster-optimization          # 설정 개선

# 개인 작업 브랜치 (팀 작업 시)
john/methylation-analysis
mary/quality-control-update
```

브랜치 전환과 상태 관리:

```bash
# 안전한 브랜치 전환
git status                           # 현재 변경사항 확인
git stash                           # 작업 중인 변경사항 임시 저장
git checkout target-branch          # 브랜치 전환
git stash pop                       # 저장된 변경사항 복원

# 변경사항이 있어도 강제 전환 (주의 필요)
git checkout -f target-branch       # 변경사항 버리고 전환

# 현재 브랜치 확인
git branch --show-current           # Git 2.22+
git rev-parse --abbrev-ref HEAD     # 구버전에서 사용
```

### 머지 전략과 방법

Git은 세 가지 주요 머지 전략을 제공합니다: Fast-forward, Recursive (3-way merge), 그리고 Rebase. 각 전략은 서로 다른 상황과 팀 정책에 적합합니다.

```bash
# Fast-forward 머지 (선형 이력 유지)
# main: A---B
# feature:    C---D
# 결과: A---B---C---D (main, feature)

git checkout main
git merge feature-branch            # Fast-forward 가능 시 자동 적용
git merge --ff-only feature-branch # Fast-forward만 허용

# 3-way 머지 (병합 커밋 생성)
# main: A---B---E
# feature:    C---D
# 결과: A---B---E---F (F는 병합 커밋)
#            \     /
#             C---D

git merge --no-ff feature-branch    # 항상 병합 커밋 생성
git merge -m "Merge feature-qc into main" feature-qc
```

리베이스를 통한 선형 이력 유지:

```bash
# 리베이스 (커밋을 다른 베이스로 이동)
# Before:
# main: A---B---E
# feature:    C---D
# After rebase:
# main: A---B---E
# feature:         C'---D' (C, D가 E 이후로 이동)

git checkout feature-branch
git rebase main                     # feature 브랜치를 main 위로 재배치

# 대화형 리베이스 (커밋 편집)
git rebase -i HEAD~3                # 최근 3개 커밋 편집
git rebase -i main                  # main 이후의 모든 커밋 편집

# 리베이스 중 충돌 해결
git add resolved-file.py
git rebase --continue               # 리베이스 계속
git rebase --abort                  # 리베이스 취소
```

스쿼시 머지 (여러 커밋을 하나로 압축):

```bash
# 방법 1: 머지 시 스쿼시
git checkout main
git merge --squash feature-branch   # 모든 변경사항을 스테이징만
git commit -m "feat: Add quality control pipeline"

# 방법 2: 대화형 리베이스로 스쿼시
git checkout feature-branch
git rebase -i HEAD~4                # 최근 4개 커밋 압축
# 편집기에서 'pick' → 'squash' 또는 's'로 변경
```

### 충돌 해결

머지나 리베이스 과정에서 같은 파일의 같은 부분이 서로 다르게 수정된 경우 충돌이 발생합니다. 충돌 해결은 Git 사용에서 피할 수 없는 과정입니다.

```bash
# 충돌 발생 상황
$ git merge feature-alignment
Auto-merging scripts/pipeline.py
CONFLICT (content): Merge conflict in scripts/pipeline.py
Automatic merge failed; fix conflicts and then commit the result.

# 충돌 상태 확인
$ git status
Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   scripts/pipeline.py
```

충돌 표시 형식:

```python
# scripts/pipeline.py 파일 내용
def run_alignment(reads, reference):
    """RNA-seq read alignment function"""
<<<<<<< HEAD
    # Use STAR aligner with default parameters
    aligner = "STAR"
    params = {"threads": 8, "memory": "32G"}
=======
    # Use HISAT2 aligner for better performance
    aligner = "HISAT2"
    params = {"threads": 16, "memory": "16G"}
>>>>>>> feature-alignment

    return align_reads(reads, reference, aligner, params)
```

충돌 해결 과정:

```bash
# 1. 충돌 파일 편집 (마커 제거 후 최종 버전 작성)
# 편집 후:
def run_alignment(reads, reference):
    """RNA-seq read alignment function"""
    # Use HISAT2 aligner with optimized parameters
    aligner = "HISAT2"
    params = {"threads": 12, "memory": "24G"}

    return align_reads(reads, reference, aligner, params)

# 2. 해결된 파일 스테이징
git add scripts/pipeline.py

# 3. 충돌 해결 완료
git commit                          # 기본 머지 메시지 사용
# 또는
git commit -m "Merge: Integrate HISAT2 alignment with optimized params"
```

충돌 해결 도구 활용:

```bash
# 3-way 머지 도구 사용
git mergetool                       # 설정된 도구로 충돌 해결
git mergetool --tool=vimdiff        # 특정 도구 지정

# Git 내장 도구로 충돌 확인
git diff                            # 충돌 상태의 diff 표시
git log --merge                     # 충돌 관련 커밋만 표시
git show :1:filename                # 공통 조상 버전
git show :2:filename                # HEAD (현재 브랜치) 버전
git show :3:filename                # 머지하려는 브랜치 버전

# 충돌 해결 취소
git merge --abort                   # 머지 취소하고 이전 상태로
git reset --hard HEAD               # 모든 변경사항 취소
```

### 브랜치 워크플로우 패턴

팀의 규모와 프로젝트 특성에 따라 다양한 브랜치 워크플로우를 채택할 수 있습니다. 생물정보학 연구에서는 분석의 안정성과 재현성이 중요하므로 적절한 워크플로우 선택이 필수적입니다.

**GitHub Flow (단순한 브랜치 모델)**:

```bash
# 1. 메인 브랜치에서 기능 브랜치 생성
git checkout main
git pull origin main
git checkout -b analysis/deseq2-update

# 2. 작업 후 푸시
git add -A
git commit -m "feat(analysis): Update DESeq2 analysis pipeline"
git push origin analysis/deseq2-update

# 3. Pull Request 생성 및 검토
# (GitHub 웹 인터페이스에서)

# 4. 검토 완료 후 메인으로 머지
git checkout main
git pull origin main              # 최신 상태로 업데이트
git branch -d analysis/deseq2-update  # 로컬 브랜치 삭제
```

**Git Flow (복잡한 프로젝트용)**:

```bash
# 브랜치 구조:
# main: 프로덕션 릴리스
# develop: 개발 통합 브랜치
# feature/*: 기능 개발
# release/*: 릴리스 준비
# hotfix/*: 긴급 수정

# 새 기능 개발
git checkout develop
git checkout -b feature/rna-seq-v2
# ... 개발 작업 ...
git checkout develop
git merge --no-ff feature/rna-seq-v2
git branch -d feature/rna-seq-v2

# 릴리스 준비
git checkout develop
git checkout -b release/v2.1.0
# ... 버그 수정, 문서 업데이트 ...
git checkout main
git merge --no-ff release/v2.1.0
git tag v2.1.0
git checkout develop
git merge --no-ff release/v2.1.0
```

**연구 프로젝트용 워크플로우**:

```bash
# 브랜치 구조:
# main: 검증된 안정 버전
# develop: 개발 통합
# experiment/*: 실험적 분석
# data/*: 새로운 데이터셋 처리
# paper/*: 논문별 분석

# 실험적 분석 브랜치
git checkout develop
git checkout -b experiment/machine-learning-classifier

# 논문용 분석 브랜치 (특정 시점에서 분기)
git checkout -b paper/nature-genetics-2024 v2.1.0
# ... 논문에 사용된 정확한 분석 보존 ...

# 데이터셋별 브랜치
git checkout -b data/tcga-integration develop
```

### 원격 브랜치 관리

팀 협업에서는 로컬 브랜치와 원격 브랜치 간의 동기화가 중요합니다.

```bash
# 원격 브랜치 확인
git branch -r                       # 원격 브랜치만
git branch -a                       # 로컬과 원격 모두
git remote show origin              # 원격 저장소 상세 정보

# 원격 브랜치 추적
git checkout -b local-branch origin/remote-branch    # 원격 브랜치 추적
git checkout --track origin/remote-branch           # 동일한 이름으로 추적
git branch -u origin/remote-branch local-branch     # 기존 브랜치에 추적 설정

# 원격 브랜치 동기화
git fetch origin                    # 원격 정보 업데이트
git fetch --prune                   # 삭제된 원격 브랜치 정보 정리
git pull origin main                # 특정 브랜치 가져와 머지
git push origin feature-branch      # 로컬 브랜치를 원격으로 푸시

# 원격 브랜치 삭제
git push origin --delete old-feature    # 원격 브랜치 삭제
git branch -d old-feature               # 로컬 브랜치 삭제
```

## Practice Section: 브랜치와 머지 실습

### 실습 1: 기본 브랜치 생성과 전환

```bash
cd ~/bioproject

# 새 기능 브랜치 생성
git checkout -b feature-quality-control
git branch --show-current

# 간단한 작업
echo "def quality_check(): pass" > scripts/qc.py
git add scripts/qc.py
git commit -m "feat(qc): Add quality control module"

# 메인 브랜치로 돌아가기
git checkout main
git branch -v
```

### 실습 2: Fast-forward 머지

```bash
# 메인에서 기능 브랜치 머지
git merge feature-quality-control
git log --oneline -3

# 브랜치 정리
git branch -d feature-quality-control
git branch
```

### 실습 3: 3-way 머지 시나리오

```bash
# 메인에서 추가 작업
echo "version = '1.1'" > scripts/version.py
git add scripts/version.py
git commit -m "feat: Add version information"

# 새 브랜치에서 다른 작업
git checkout -b feature-config
echo "config = {'debug': True}" > scripts/config.py
git add scripts/config.py
git commit -m "feat: Add configuration module"

# 메인으로 돌아가서 머지
git checkout main
git merge --no-ff feature-config -m "Merge config feature"
git log --oneline --graph -5
```

### 실습 4: 충돌 해결 연습

```bash
# 두 브랜치에서 같은 파일 수정
git checkout -b branch-a
echo "method = 'fastqc'" > scripts/qc.py
git add scripts/qc.py
git commit -m "Use FastQC method"

git checkout main
echo "method = 'multiqc'" > scripts/qc.py
git add scripts/qc.py
git commit -m "Use MultiQC method"

# 충돌 머지 시도
git merge branch-a
# 충돌 해결 후:
echo "method = 'fastqc_and_multiqc'" > scripts/qc.py
git add scripts/qc.py
git commit -m "Merge: Use both QC methods"
```

### 실습 5: 브랜치 정리

```bash
# 브랜치 현황 확인
git branch -v
git branch --merged

# 불필요한 브랜치 삭제
git branch -d branch-a
git branch -d feature-config

# 최종 상태 확인
git log --oneline --graph
git branch
```

## 핵심 정리

### 브랜치 관리 필수 명령어

```bash
# 브랜치 생성/전환
git checkout -b new-branch     # 생성 후 전환
git switch -c new-branch       # Git 2.23+ 새 문법
git branch new-branch          # 생성만

# 머지
git merge branch-name          # 브랜치 머지
git merge --no-ff branch       # 항상 머지 커밋 생성
git merge --squash branch      # 스쿼시 머지

# 브랜치 정리
git branch -d branch-name      # 브랜치 삭제
git branch --merged            # 머지된 브랜치 확인
```

### 생물정보학 브랜치 전략

```bash
# 브랜치 명명 규칙
feature/pipeline-optimization  # 기능 개발
experiment/deep-learning       # 실험적 분석
data/gtex-integration         # 데이터 통합
paper/nature-2024             # 논문별 분석
bugfix/memory-leak            # 버그 수정

# 안전한 머지 패턴
git checkout main && git pull  # 최신 상태 확인
git merge --no-ff feature     # 머지 이력 보존
git branch -d feature         # 정리
```

**다음**: [3.4 Remote Collaboration](./ch03-4-remote-collaboration.md)
