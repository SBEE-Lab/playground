# 1.1 Unix Philosophy & Command Line

## 핵심 개념

Unix는 "작은 도구들을 연결하여 복잡한 작업을 수행한다"는 철학을 기반으로 설계되었습니다. 각 명령어는 하나의 기능을 잘 수행하며, 파이프(`|`)로 연결하여 강력한 데이터 처리 파이프라인을 구성할 수 있습니다.

### 기본 파일 시스템 탐색

파일 시스템 탐색은 모든 작업의 기초입니다. 현재 위치를 파악하고, 파일과 디렉토리를 확인하며, 원하는 위치로 이동하는 것이 첫 번째 단계입니다.

```bash
# 현재 위치 확인
pwd                     # Print Working Directory

# 파일과 디렉토리 목록 보기
ls                      # 기본 목록
ls -l                   # 상세 정보 (권한, 크기, 날짜)
ls -la                  # 숨김 파일(.으로 시작) 포함
ls -lh                  # 파일 크기를 사람이 읽기 쉽게 (1K, 2M, 3G 등)
ls -lt                  # 수정 시간 순으로 정렬 (최근 파일이 위에)

# 디렉토리 이동
cd /absolute/path       # 절대 경로로 이동
cd relative/path        # 상대 경로로 이동
cd ~                    # 홈 디렉토리로 이동
cd -                    # 이전 디렉토리로 이동 (매우 유용)
cd ..                   # 상위 디렉토리로 이동
cd ../..                # 두 단계 위로 이동
```

### 파일과 디렉토리 조작

파일과 디렉토리 생성, 복사, 이동, 삭제는 연구 데이터 관리의 핵심 작업입니다. 특히 생물정보학에서는 대량의 데이터 파일을 체계적으로 관리해야 합니다.

```bash
# 디렉토리 생성
mkdir new_directory                    # 단일 디렉토리 생성
mkdir -p path/to/nested/directory     # 중간 경로까지 모두 생성

# 파일 생성
touch filename.txt                     # 빈 파일 생성
echo "Hello World" > filename.txt      # 내용과 함께 파일 생성

# 파일 복사
cp source.txt destination.txt          # 파일 복사
cp -r source_dir dest_dir             # 디렉토리 전체 복사 (recursive)
cp *.fasta backup/                    # 패턴 매칭으로 여러 파일 복사

# 파일 이동과 이름 변경
mv old_name.txt new_name.txt          # 파일 이름 변경
mv file.txt /new/location/            # 파일 이동
mv *.log logs/                        # 여러 파일을 특정 디렉토리로 이동

# 파일과 디렉토리 삭제
rm filename.txt                       # 파일 삭제
rm -i filename.txt                    # 삭제 전 확인 (interactive)
rm -r directory                       # 디렉토리와 내용 모두 삭제
rm -rf directory                      # 강제 삭제 (주의 필요!)
```

### 파일 내용 확인

연구 데이터 파일의 내용을 확인하는 것은 분석 전 필수 단계입니다. 파일 크기에 따라 적절한 명령어를 선택해야 합니다.

```bash
# 전체 내용 보기
cat filename.txt                      # 전체 내용을 한 번에 출력
less filename.txt                     # 페이지 단위로 보기 (q로 종료)
more filename.txt                     # 페이지 단위로 보기 (아래로만 스크롤)

# 파일의 일부분만 보기
head filename.txt                     # 처음 10줄
head -n 20 filename.txt              # 처음 20줄
tail filename.txt                     # 마지막 10줄
tail -n 50 filename.txt              # 마지막 50줄
tail -f logfile.txt                   # 실시간으로 추가되는 내용 모니터링

# 줄 번호와 함께 보기
nl filename.txt                       # 줄 번호 추가
cat -n filename.txt                   # 줄 번호와 함께 전체 출력

# 파일 정보 확인
wc filename.txt                       # 줄 수, 단어 수, 문자 수
wc -l *.fasta                        # 여러 파일의 줄 수만
file filename.txt                     # 파일 타입 확인
```

### 패턴 매칭과 와일드카드

생물정보학에서는 동일한 형식의 파일들을 일괄 처리하는 경우가 많습니다. 와일드카드를 효과적으로 사용하면 작업 효율성을 크게 높일 수 있습니다.

```bash
# 기본 와일드카드
*                    # 모든 문자 (0개 이상)
?                    # 한 개의 문자
[abc]                # a, b, c 중 하나
[a-z]                # a부터 z까지 중 하나
[0-9]                # 0부터 9까지 중 하나
[!0-9]               # 숫자가 아닌 문자

# 실제 사용 예시
ls *.txt             # 모든 .txt 파일
ls *.fasta           # 모든 FASTA 파일
ls data_*.csv        # data_로 시작하는 모든 .csv 파일
ls file?.txt         # file + 한 글자 + .txt (file1.txt, filea.txt 등)
ls sample_[0-9]*.fastq   # sample_ + 숫자로 시작하는 FASTQ 파일

# 중괄호 확장 (Brace Expansion)
mkdir {data,results,scripts,docs}     # 여러 디렉토리 한 번에 생성
cp file.txt{,.backup}                 # file.txt를 file.txt.backup으로 복사
echo {1..10}                          # 1부터 10까지 숫자 나열
echo sample_{001..100}.fasta          # sample_001.fasta부터 sample_100.fasta까지
```

### 명령어 조합과 파이프라인

Unix의 진정한 힘은 작은 도구들을 조합할 때 나타납니다. 파이프라인을 통해 복잡한 데이터 처리를 단순한 명령어들의 조합으로 해결할 수 있습니다.

```bash
# 기본 파이프라인
command1 | command2                   # command1의 출력을 command2의 입력으로
command1 | command2 | command3        # 여러 명령어 연결

# 실제 사용 예시
ls -la | grep "\.fasta$"             # FASTA 파일만 필터링
cat file.txt | sort | uniq           # 파일 내용 정렬 후 중복 제거
ls -la | wc -l                       # 현재 디렉토리의 파일 개수
find . -name "*.log" | head -5        # 로그 파일 중 처음 5개만

# 복잡한 파이프라인 예시
ls -la | grep "^-" | awk '{print $5, $9}' | sort -n   # 파일 크기별로 정렬
cat sequences.fasta | grep "^>" | wc -l                # FASTA 파일의 서열 개수
```

### 도구 위치와 정보 확인

시스템에 설치된 도구들의 위치와 정보를 확인하는 것은 스크립트 작성이나 문제 해결 시 중요합니다.

```bash
# 명령어 위치 찾기
which python          # python 실행 파일의 경로
whereis python         # python 관련 파일들의 위치 (실행파일, 매뉴얼 등)
type python            # 명령어의 타입 (내장, 함수, 별칭, 실행파일)

# 시스템 정보
whoami                 # 현재 사용자 이름
hostname               # 시스템 이름
uname -a               # 시스템 전체 정보
date                   # 현재 날짜와 시간

# 도움말 보기
man ls                 # ls 명령어의 매뉴얼
ls --help             # 간단한 도움말
info ls                # 상세한 정보 페이지
```

## Practice Section: 연구 프로젝트 구조 생성

실습 전, 개발환경에 먼저 입장합니다.
[실습 환경 구성](../../introduction/3-requirements.md#-실습-환경-구성)을 참고하세요.

```bash
# 실습 디렉토리로 진입 (playground/practice/chapter01)
cd ./practice/chapter01

# 실습 환경 진입
nix develop .#chapter01
```

이번 실습을 통해 생성되어야 할 최종 outputs 은 다음과 같습니다.

```bash
chapter01
└── bioproject
    ├── data
    │   ├── backup
    │   │   ├── metadata.csv
    │   │   └── sequences.fasta
    │   ├── processed
    │   │   └── sequences_working.fasta
    │   └── raw
    │       ├── metadata.csv
    │       └── sequences.fasta
    └── results
        └── report.txt

6 directories, 6 files
```

### 실습 1: 프로젝트 구조 생성

```bash
# 현재 디렉토리 위치 확인하기
pwd

# 생물정보학 연구 프로젝트 디렉토리 생성
mkdir -p bioproject/{data/{raw,processed,backup},results}

# 현재 구조 확인
cd ./bioproject

ls -la

# tree 로 전체 구조 확인
tree

## find all directories
find . -type d | sort
```

### 실습 2: 샘플 데이터 파일 생성

```bash
cd ./data/raw

# 간단한 FASTA 파일 생성
cat > sequences.fasta << 'EOF'
>seq1_Ecoli
ATGAAACGCATTAGCACCACCATTACCACCACCATCACCATTACCACAGGTAACGGTGCG
GGCTGACGCGTACAGGAAACACAGAAAAAAGCCCGCACCTGACAGTGCGGGCTTTTTTT
>seq2_Bsubtilis
ATGAGCGAACAAGCCATTGCGAATGTTCTGAAAGATGCCGAAAACATCGCCCGTGAAATC
GTTGAAGAAGCGAACACCATGCCGGATAAAGTCGATATCGACAAACTGAAAGCGCTGCTG
>seq3_Saureus
ATGAAAAAATTAGTTTTAGCAGGTGCAGGTGCAGGTGCAGGTGCAGGTGCAGGTGCAGGT
GCGGGTATCGATAAAGCGCAAATCGATCTGGAAATGCTGGTTAAAGATGAAAAGAACTAT
EOF

# 메타데이터 파일 생성
cat > metadata.csv << 'EOF'
sample_id,organism,condition,replicate
seq1,E.coli,control,1
seq2,B.subtilis,treatment,1
seq3,S.aureus,control,2
EOF

# 잘 생성되었는지 확인
ls -la
cat sequences.fasta
cat metadata.csv
```

### 실습 3: 기본 파일 분석 보고서 작성

```bash
# FASTA 파일 기본 분석
# 1. 서열 개수 ('>' 의 개수와 동일함)
echo "The number of sequences: $(grep -c '^>' sequences.fasta)" > ../../result/report.txt

# 2. 총 라인 수
echo "The number of total lines: $(wc -l < sequences.fasta)" >> ../../result/report.txt

# 3. 서열 이름 확인
grep '^>' sequences.fasta

# 메타데이터 분석
# 1. 총 샘플 수
echo "The number of total samples: $(tail -n +2 metadata.csv | wc -l)" >> ../../result/report.txt

# 2. 유기체별 분포
tail -n +2 metadata.csv | cut -d',' -f2 | sort | uniq -c
```

### 실습 4: 파일 조작과 백업

```bash
# 백업 디렉토리로 파일 복사
cp *.fasta ../backup/
cp metadata.csv ../backup/metadata.csv

# 또는 날짜를 추가할 수도 있음
cp metadata.csv ../backup/metadata_$(date +%Y%m%d).csv

# 파일 패턴 매칭 연습
ls *.{fasta,csv}

# 파일 정리
cp sequences.fasta ../processed/sequences_working.fasta

# 파일 삭제
rm ../backup/metadata_$(date +%Y%m%d).csv
```

### 실습 5: 명령어 조합 연습

```bash
# 파이프라인을 이용한 데이터 분석

# 가장 긴 서열 라인 찾기
echo "The most long sequence: $(grep -v '^>' sequences.fasta | awk '{print length, $0}' | sort -nr | head -1)" >> ../../result/report.txt

# 파일 크기별 정렬
ls -la | grep -v '^d' | sort -k5 -nr

# 디렉토리 구조 요약
cd ../../..
find ./bioproject -type f | wc -l | xargs echo "총 파일 수:"
find ./bioproject -type d | wc -l | xargs echo "총 디렉토리 수:"
```

---

## 핵심 정리

### 자주 사용하는 명령어 조합

```bash
# 파일 탐색과 정보
ls -la | grep -E "(fasta|csv)"         # 특정 파일 타입만 보기
find . -name "*.txt" | head -10        # 텍스트 파일 처음 10개
du -sh */ | sort -hr                   # 디렉토리 크기별 정렬

# 데이터 확인
head -5 file.txt && tail -5 file.txt   # 파일 앞뒤 확인
wc -l *.fasta                          # 여러 파일의 라인 수
```

### 효율적인 작업 패턴

1. **탐색 → 확인 → 작업**: `ls` → `head/cat` → `cp/mv`
2. **패턴 활용**: 와일드카드로 여러 파일 동시 처리
3. **파이프라인**: 작은 명령어들을 연결하여 복잡한 작업 수행
4. **백업 습관**: 중요한 작업 전 항상 백업

### One-step more

최근에는 메모리 안정성과 속도 면에서 각광받고 있는 Rust 로 쓰여진 프로그램 `ripgrep` `sd` `fd` 등이 각광받고 있습니다.
사용자 경험 면에서도 명령어 작성이 편리하여, 활용을 고려해보세요

---

**다음**: [1.2 File System & Permissions](./ch01-2-filesystem-permissions.md)
