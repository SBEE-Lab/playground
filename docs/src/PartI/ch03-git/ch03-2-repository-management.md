# 3.2 Repository Management

## 핵심 개념

Repository는 프로젝트의 모든 파일과 변경 이력이 저장되는 공간입니다. 생물정보학 연구에서는 소스 코드, 설정 파일, 스크립트는 추적하되 대용량 데이터나 임시 결과 파일은 제외하는 전략적 관리가 필요합니다. 효과적인 저장소 관리는 협업 효율성과 프로젝트 유지보수성을 크게 좌우합니다.

### 저장소 생성과 복제

새로운 프로젝트 시작 시 로컬에서 저장소를 초기화하거나, 기존 원격 저장소를 복제하는 두 가지 방법이 있습니다.

```bash
# 로컬 저장소 초기화
mkdir rna-seq-analysis
cd rna-seq-analysis
git init
git branch -M main                    # 기본 브랜치를 main으로 설정

# 초기화 확인
ls -la                               # .git 디렉토리 생성 확인
git status                           # 저장소 상태 확인

# 빈 저장소에 첫 커밋 생성
echo "# RNA-seq Analysis Pipeline" > README.md
git add README.md
git commit -m "feat: Initial project setup"
```

원격 저장소 복제:

```bash
# 기본 복제
git clone https://github.com/user/bioproject.git
git clone git@github.com:user/bioproject.git    # SSH 사용

# 복제 옵션들
git clone --depth 1 https://github.com/user/large-project.git      # 최신 커밋만 (얕은 복제)
git clone --branch develop https://github.com/user/project.git     # 특정 브랜치만
git clone --recursive https://github.com/user/project.git          # 서브모듈 포함

# 복제 후 상태 확인
cd bioproject
git remote -v                        # 원격 저장소 확인
git branch -a                        # 모든 브랜치 확인
git log --oneline -5                 # 최근 5개 커밋 확인
```

저장소 구조 설정:

```bash
# 생물정보학 프로젝트 표준 구조 생성
mkdir -p {data/{raw,processed,results},scripts,docs,config,logs}
touch data/raw/.gitkeep              # 빈 디렉토리 추적용
touch data/processed/.gitkeep
touch logs/.gitkeep

# 구조 확인
tree -a                              # 숨김 파일 포함 트리 구조
```

### .gitignore 파일 관리

.gitignore 파일은 Git이 추적하지 않을 파일과 디렉토리를 지정합니다. 생물정보학 프로젝트에서는 대용량 데이터 파일, 임시 결과, 시스템 파일을 제외하는 것이 중요합니다.

```bash
# 생물정보학용 .gitignore 생성
cat > .gitignore << 'EOF'
# 대용량 데이터 파일
*.fastq
*.fastq.gz
*.fq
*.fq.gz
*.fasta.gz
*.fa.gz
*.bam
*.sam
*.bed.gz

# 압축 파일
*.zip
*.tar.gz
*.tar.bz2
*.7z

# 결과 및 임시 파일
results/
output/
temp/
tmp/
*.tmp
*.temp
*.out
*.log

# Python 관련
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/
.ipynb_checkpoints/

# R 관련
.Rproj.user/
.Rhistory
.RData
.Ruserdata
*.Rproj

# 설정 파일 (민감한 정보 포함)
config/secrets.yaml
config/database.conf
.env
*.key

# IDE 파일
.vscode/
.idea/
*.swp
*.swo
*~

# OS 생성 파일
.DS_Store
Thumbs.db
.directory

# 클러스터 관련
*.o
*.e
slurm-*.out
EOF
```

.gitignore 패턴 문법:

```bash
# 패턴 규칙들
*.log                    # 모든 .log 파일
/logs                    # 루트의 logs 디렉토리만
logs/                    # 모든 logs 디렉토리
temp/                    # temp 디렉토리와 그 내용
!important.log           # 예외 (important.log는 추적)
data/**/*.bam            # data 하위 모든 .bam 파일
results/[0-9]*/          # results/001/, results/002/ 등

# 복잡한 패턴 예시
# 모든 .fastq 파일을 제외하되, 샘플 파일은 포함
*.fastq
!sample*.fastq

# 특정 확장자를 가진 대용량 파일만 제외
*.[0-9][0-9][0-9]MB.*   # 100MB 이상을 나타내는 파일명 패턴
```

기존 추적 파일 제거:

```bash
# 이미 추적 중인 파일을 .gitignore에 추가한 경우
git rm --cached large_data.bam       # 추적에서만 제거 (파일은 보존)
git rm -r --cached results/         # 디렉토리 전체 추적 제거

# .gitignore 적용 확인
git status                           # 더 이상 추적되지 않는지 확인
git commit -m "chore: Remove large data files from tracking"
```

### 파일 조작과 스테이징

Git에서 파일을 추가, 수정, 삭제, 이동할 때는 각 작업의 특성을 이해하고 적절한 명령어를 사용해야 합니다.

```bash
# 파일 추가 (다양한 방법)
git add analysis.py                  # 단일 파일
git add scripts/                     # 디렉토리 전체
git add *.py                         # 패턴 매칭
git add .                           # 현재 디렉토리 모든 변경사항
git add -A                          # 저장소 전체 모든 변경사항

# 선택적 스테이징
git add -p analysis.py              # 파일 내 일부분만 선택적으로 스테이징
git add -i                          # 대화형 스테이징

# 파일 제거
git rm obsolete_script.py           # 파일 삭제 및 스테이징
git rm --cached config/secrets.yaml # 추적에서만 제거 (파일은 보존)
git rm -r old_results/              # 디렉토리 삭제

# 파일 이동 및 이름 변경
git mv old_name.py new_name.py      # 파일 이름 변경
git mv scripts/analysis.py bin/    # 파일 이동
```

고급 스테이징 기법:

```bash
# 부분적 스테이징 (hunk 단위)
git add -p script.py
# y: 현재 hunk 스테이징
# n: 현재 hunk 건너뛰기
# s: hunk를 더 작은 단위로 분할
# e: hunk를 수동으로 편집

# 대화형 스테이징
git add -i
# 1: status        - 파일 상태 확인
# 2: update        - 파일 스테이징
# 3: revert        - 스테이징 취소
# 4: add untracked - 새 파일 추가
# 5: patch         - 부분적 스테이징
# 6: diff          - 차이점 확인

# 스테이징 영역 조작
git reset HEAD analysis.py          # 특정 파일 스테이징 취소
git reset HEAD                      # 모든 스테이징 취소
git restore --staged analysis.py    # Git 2.23+ 새로운 문법
```

### 변경사항 되돌리기

실수로 만든 변경사항이나 잘못된 커밋을 되돌리는 것은 개발 과정에서 자주 필요한 작업입니다.

```bash
# 작업 디렉토리 변경사항 되돌리기
git restore analysis.py             # 파일을 최신 커밋 상태로 되돌리기
git restore .                       # 모든 변경사항 되돌리기
git checkout HEAD -- analysis.py   # 구버전 Git에서 사용

# 특정 커밋으로 파일 되돌리기
git restore --source=HEAD~2 analysis.py    # 2개 커밋 전 상태로
git checkout abc1234 -- analysis.py        # 특정 커밋 해시로

# 커밋 수정과 되돌리기
git commit --amend                  # 마지막 커밋 메시지나 내용 수정
git commit --amend --no-edit        # 메시지 변경 없이 파일만 추가

# 커밋 되돌리기 (3가지 방법)
git reset --soft HEAD~1             # 커밋만 취소, 변경사항은 스테이징 상태로 유지
git reset --mixed HEAD~1            # 커밋과 스테이징 취소, 변경사항은 작업 디렉토리에 유지 (기본값)
git reset --hard HEAD~1             # 커밋, 스테이징, 작업 디렉토리 모든 변경사항 취소

# 특정 커밋 되돌리기 (안전한 방법)
git revert abc1234                  # 특정 커밋의 변경사항을 취소하는 새 커밋 생성
git revert HEAD~2..HEAD             # 범위로 여러 커밋 되돌리기
```

위험한 작업 전 백업:

```bash
# 현재 상태 백업
git stash push -m "Backup before dangerous operation"
git branch backup-$(date +%Y%m%d-%H%M%S)

# 또는 태그로 백업
git tag backup-before-reset

# 작업 후 복구가 필요한 경우
git reset --hard backup-before-reset
git stash pop
```

### 원격 저장소 관리

원격 저장소는 협업의 중심이며, 여러 원격 저장소를 관리하는 능력은 복잡한 프로젝트에서 필수적입니다.

```bash
# 원격 저장소 확인
git remote -v                       # 모든 원격 저장소 URL과 함께 표시
git remote show origin              # 특정 원격 저장소 상세 정보

# 원격 저장소 추가
git remote add upstream https://github.com/original/project.git
git remote add backup https://github.com/backup/project.git

# 원격 저장소 수정
git remote set-url origin https://github.com/newuser/project.git
git remote rename origin old-origin
git remote remove backup

# 원격 브랜치 정보 업데이트
git fetch origin                    # origin에서 최신 정보 가져오기
git fetch --all                     # 모든 원격 저장소에서 가져오기
git fetch --prune                   # 삭제된 원격 브랜치 정보도 동기화
```

원격 저장소와 동기화:

```bash
# 첫 푸시 (원격 브랜치 생성)
git push -u origin main             # 업스트림 설정과 함께 푸시

# 일반적인 푸시/풀
git push                            # 현재 브랜치를 추적하는 원격 브랜치로 푸시
git pull                            # 원격에서 변경사항 가져와 자동 병합
git pull --rebase                   # rebase 방식으로 통합

# 강제 푸시 (위험하므로 주의)
git push --force-with-lease         # 안전한 강제 푸시
git push --force                    # 위험한 강제 푸시 (팀 작업에서 금지)

# 특정 브랜치 작업
git push origin feature-branch      # 특정 브랜치 푸시
git push origin --delete old-branch # 원격 브랜치 삭제
```

### 스테이징 영역 고급 활용

스테이징 영역을 효과적으로 활용하면 논리적으로 관련된 변경사항을 그룹화하여 의미 있는 커밋을 만들 수 있습니다.

```bash
# 스테이징 상태 세밀 조정
git diff --name-status              # 변경된 파일과 상태 요약
git diff --cached                   # 스테이징된 변경사항만 확인
git diff HEAD                       # 작업 디렉토리와 HEAD 비교

# 파일별 다른 처리
git add scripts/                    # 스크립트 파일들 스테이징
git add config/pipeline.yaml       # 설정 파일 스테이징
# 데이터 파일들은 스테이징하지 않음

# 스테이징 영역에서 일부만 제거
git reset HEAD config/secrets.yaml # 민감한 파일 스테이징 취소

# 스테이지된 변경사항 임시 저장
git stash --keep-index              # 스테이지되지 않은 변경사항만 stash
git stash --include-untracked       # 추적되지 않는 파일도 포함
```

## Practice Section: 저장소 관리 실습

### 실습 1: 프로젝트 구조 설정

```bash
cd ~/bioproject

# 표준 디렉토리 구조 생성
mkdir -p {data/{raw,processed},scripts,results,config}
touch data/raw/.gitkeep
touch results/.gitkeep

# .gitignore 생성
echo "*.fastq\n*.bam\nresults/*.csv\n__pycache__/" > .gitignore

git add .
git commit -m "feat: Setup project structure with gitignore"
```

### 실습 2: 파일 추가와 관리

```bash
# 스크립트 파일 생성
echo "#!/usr/bin/env python3\nprint('Hello Bio!')" > scripts/hello.py
echo "samples: 24\nthreads: 8" > config/settings.yaml

# 선택적 추가
git add scripts/
git status
git commit -m "feat(scripts): Add hello script"

git add config/settings.yaml
git commit -m "config: Add pipeline settings"
```

### 실습 3: 변경사항 되돌리기

```bash
# 파일 수정
echo "import pandas as pd" >> scripts/hello.py
echo "debug: true" >> config/settings.yaml

# 일부 변경사항만 되돌리기
git restore scripts/hello.py
git status

# 나머지 변경사항 커밋
git add config/settings.yaml
git commit -m "config: Enable debug mode"
```

### 실습 4: 스테이징 조작

```bash
# 여러 파일 수정
echo "# Analysis Results" > results/summary.md
echo "import numpy as np" >> scripts/hello.py
echo "version: 2.0" >> config/settings.yaml

# 선택적 스테이징
git add results/summary.md config/settings.yaml
git status

# 일부만 커밋
git commit -m "docs: Add results summary and update config"
```

### 실습 5: 원격 저장소 설정

```bash
# GitHub 저장소와 연결 (실제 URL 필요)
# git remote add origin https://github.com/username/bioproject.git

# 원격 저장소 확인
git remote -v

# 로컬 작업 푸시 준비
git branch -M main
echo "Repository ready for remote push"
```

## 핵심 정리

### 저장소 관리 필수 명령어

```bash
# 초기 설정
git init                    # 저장소 초기화
git clone <url>            # 원격 저장소 복제

# 파일 관리
git add <file>             # 파일 스테이징
git rm <file>              # 파일 삭제
git mv <old> <new>         # 파일 이동/이름변경

# 변경사항 되돌리기
git restore <file>         # 작업 디렉토리 되돌리기
git reset HEAD <file>      # 스테이징 취소
git commit --amend         # 마지막 커밋 수정
```

### 생물정보학 프로젝트 관리 패턴

```bash
# .gitignore 필수 항목
*.fastq *.bam *.sam        # 대용량 시퀀싱 데이터
results/ output/           # 결과 디렉토리
*.log *.tmp               # 임시 파일
__pycache__/              # Python 캐시

# 디렉토리 구조
data/{raw,processed}/     # 데이터 분리
scripts/                  # 분석 스크립트
config/                   # 설정 파일
results/                  # 결과 (추적 제외)
```

**다음**: [3.3 Branching and Merging](./ch03-3-branching-merging.md)
