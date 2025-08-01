# 1.4 Text Processing Tools

## 핵심 개념

텍스트 처리는 생물정보학의 핵심입니다. FASTA, FASTQ, CSV, GFF 등 대부분의 생물학적 데이터가 텍스트 형태로 저장되며, 이를 효율적으로 처리하고 분석하는 것이 연구의 기본이 됩니다. Unix/Linux의 텍스트 처리 도구들은 강력하고 빠르며, 메모리 효율적입니다.

### grep - 패턴 검색의 핵심 도구

grep은 텍스트에서 특정 패턴을 찾는 가장 기본적이고 강력한 도구입니다. 생물정보학에서는 서열 ID 찾기, 특정 조건의 데이터 필터링, 로그 파일 분석 등에 광범위하게 사용됩니다.

```bash
# 기본 패턴 검색
grep "pattern" filename             # 패턴이 포함된 줄 찾기
grep -i "pattern" filename          # 대소문자 무시 (case-insensitive)
grep -v "pattern" filename          # 패턴이 없는 줄 (inverse match)
grep -n "pattern" filename          # 줄 번호와 함께 출력
grep -c "pattern" filename          # 매치된 줄 수만 출력

# 여러 파일에서 검색
grep "pattern" *.txt                # 모든 .txt 파일에서 검색
grep -r "pattern" directory/        # 디렉토리 내 모든 파일에서 재귀 검색
grep -l "pattern" *.fasta           # 패턴을 포함한 파일명만 출력
grep -H "pattern" *.csv             # 파일명과 함께 출력

# 정규표현식 사용
grep -E "pattern1|pattern2" file    # OR 조건 (egrep와 동일)
grep "^>" file.fasta                # 줄 시작이 >인 것 (FASTA 헤더)
grep "ATCG$" file                   # 줄 끝이 ATCG인 것
grep "[0-9]\{3,\}" file             # 3자리 이상 숫자
grep "^[ATCG]\{50,\}$" file         # 50bp 이상의 DNA 서열

# 문맥과 함께 검색
grep -A 3 "pattern" file            # 매치된 줄 뒤 3줄 포함
grep -B 2 "pattern" file            # 매치된 줄 앞 2줄 포함
grep -C 5 "pattern" file            # 매치된 줄 앞뒤 5줄 포함
```

### sed - 스트림 에디터

sed는 텍스트를 수정, 변환, 삭제하는 스트림 에디터입니다. 대용량 파일을 메모리에 전부 로드하지 않고도 처리할 수 있어 생물정보학 데이터 처리에 매우 유용합니다.

```bash
# 기본 치환 작업
sed 's/old/new/' filename           # 각 줄의 첫 번째 매치만 치환
sed 's/old/new/g' filename          # 모든 매치 치환 (global)
sed 's/old/new/2' filename          # 각 줄의 두 번째 매치만 치환

# 파일 직접 수정
sed -i 's/old/new/g' filename       # 원본 파일을 직접 수정
sed -i.bak 's/old/new/g' filename   # 백업(.bak) 생성 후 수정

# 특정 줄에서만 작업
sed '5s/old/new/' filename          # 5번째 줄에서만 치환
sed '1,10s/old/new/g' filename      # 1-10번째 줄에서만 치환
sed '/pattern/s/old/new/g' filename # 패턴이 있는 줄에서만 치환

# 줄 삭제와 추가
sed '1d' filename                    # 첫 번째 줄 삭제
sed '/pattern/d' filename            # 패턴을 포함한 줄 삭제
sed '1,5d' filename                  # 1-5번째 줄 삭제
sed '5a\새로운 줄' filename          # 5번째 줄 뒤에 줄 추가
sed '/pattern/i\앞에 추가' filename  # 패턴 줄 앞에 추가

# 복잡한 변환
sed -e 's/A/T/g' -e 's/C/G/g' file        # 다중 치환 (DNA 상보서열 일부)
sed 's/\([ATCG]\)\([ATCG]\)/\2\1/g' file  # 백레퍼런스 사용
```

### awk - 패턴 스캐닝과 데이터 추출

awk는 구조화된 텍스트 데이터를 처리하는 강력한 프로그래밍 언어입니다. CSV, TSV 파일이나 고정 폭 데이터를 처리하는 데 특히 유용합니다.

```bash
# 기본 구조: awk 'pattern {action}' filename
awk '{print $1}' filename           # 첫 번째 필드(컬럼) 출력
awk '{print $NF}' filename          # 마지막 필드 출력
awk '{print NR, $0}' filename       # 줄 번호와 함께 전체 줄 출력

# 필드 구분자 지정
awk -F',' '{print $1, $3}' file.csv # CSV 파일의 1, 3번째 컬럼
awk -F'\t' '{print $2}' file.tsv    # TSV 파일의 2번째 컬럼
awk -F'|' '{print $2}' fasta.txt    # | 구분자 사용

# 조건문과 패턴 매칭
awk '$3 > 100 {print $1, $3}' file  # 3번째 필드가 100 초과인 줄
awk 'NR > 1 {print}' file           # 첫 번째 줄(헤더) 제외
awk '/^>/ {print}' file.fasta       # FASTA 헤더만 출력
awk 'length($0) > 50' file          # 50자 이상인 줄만

# 수치 계산
awk '{sum += $1} END {print sum}' file          # 첫 번째 컬럼 합계
awk '{print $1, $2 * $3}' file                  # 2, 3번째 컬럼 곱셈
awk 'NR > 1 {count++} END {print count}' file   # 데이터 줄 수 (헤더 제외)
awk '{print length($0)}' file                   # 각 줄의 길이

# 변수와 조건부 처리
awk 'BEGIN {count=0} /^>/ {count++} END {print "Sequences:", count}' file.fasta
awk '{count[$1]++} END {for(i in count) print i, count[i]}' file  # 첫 번째 필드 빈도수
```

### sort와 uniq - 데이터 정렬과 중복 처리

대용량 생물학적 데이터에서 정렬과 중복 제거는 매우 중요한 작업입니다. 이 도구들은 메모리 효율적으로 대용량 파일을 처리할 수 있습니다.

```bash
# 기본 정렬
sort filename                      # 사전순 정렬
sort -r filename                   # 역순 정렬
sort -n filename                   # 숫자 순 정렬
sort -nr filename                  # 숫자 역순 정렬

# 필드 기준 정렬
sort -k2 filename                  # 2번째 필드 기준 정렬
sort -k2,2 -k3,3n filename         # 2번째 필드 문자순, 3번째 필드 숫자순
sort -t',' -k3nr file.csv          # CSV에서 3번째 컬럼 숫자 역순

# 고급 정렬 옵션
sort -u filename                   # 정렬 후 중복 제거
sort -S 1G filename                # 메모리 사용량 지정 (대용량 파일용)
sort --parallel=4 filename         # 병렬 처리

# uniq - 중복 처리 (정렬된 파일에서만 작동)
sort filename | uniq               # 중복 제거
sort filename | uniq -c            # 중복 횟수와 함께
sort filename | uniq -d            # 중복된 것만 출력
sort filename | uniq -u            # 유일한 것만 출력
```

### cut, paste, join - 컬럼 조작 도구

구조화된 데이터에서 특정 컬럼을 추출하거나 결합하는 작업은 데이터 분석의 기본입니다.

```bash
# cut - 컬럼 추출
cut -d',' -f1,3 file.csv           # CSV 1, 3번째 컬럼
cut -d'\t' -f2- file.tsv           # TSV 2번째 컬럼부터 끝까지
cut -c1-10 filename                # 1-10번째 문자
cut -c5- filename                  # 5번째 문자부터 끝까지
cut -d' ' -f1 --complement file    # 첫 번째 필드를 제외한 모든 필드

# paste - 파일 가로 병합
paste file1.txt file2.txt          # 탭으로 구분하여 병합
paste -d',' file1.txt file2.txt    # 콤마로 구분하여 병합
paste -s file.txt                  # 세로를 가로로 변환

# join - 공통 키로 결합 (정렬된 파일 필요)
join file1.txt file2.txt           # 첫 번째 필드가 키
join -1 2 -2 1 file1.txt file2.txt # file1의 2번째, file2의 1번째 필드가 키
join -t',' file1.csv file2.csv     # CSV 파일 결합
```

### tr - 문자 변환과 삭제

문자 단위의 변환과 정리 작업에 매우 유용한 도구입니다.

```bash
# 문자 변환
tr 'a-z' 'A-Z' < file              # 소문자를 대문자로
tr 'ATCG' 'TAGC' < dna.txt         # DNA 상보 서열 변환
tr ' ' '_' < file                  # 공백을 언더스코어로
tr '[:lower:]' '[:upper:]' < file  # 소문자를 대문자로 (POSIX 방식)

# 문자 삭제
tr -d ' ' < file                   # 모든 공백 제거
tr -d '\r' < file                  # 캐리지 리턴 제거 (Windows → Unix)
tr -d '\n' < file                  # 줄바꿈 제거
tr -d '[:digit:]' < file           # 모든 숫자 제거

# 문자 압축
tr -s ' ' < file                   # 연속된 공백을 하나로 압축
tr -s '\n' < file                  # 연속된 빈 줄을 하나로
```

### 고급 텍스트 처리 패턴

실제 생물정보학 연구에서 자주 사용되는 복합적인 텍스트 처리 패턴들입니다.

```bash
# FASTA 파일 처리 패턴
grep -c "^>" sequences.fasta                    # 서열 개수 세기
grep "^>" sequences.fasta | cut -d'|' -f2       # 서열 ID 추출
awk '/^>/ {print $0} !/^>/ {seq=seq$0} END {print length(seq)}' file.fasta  # 총 서열 길이

# CSV 데이터 분석 패턴
awk -F',' 'NR>1 {sum+=$3; count++} END {print sum/count}' data.csv  # 3번째 컬럼 평균
sort -t',' -k2,2 -k3,3nr data.csv              # 2번째 컬럼별, 3번째 컬럼 내림차순
cut -d',' -f1,3 data.csv | grep -v "^$"        # 1,3번째 컬럼, 빈 줄 제외

# 로그 파일 분석 패턴
grep "ERROR" logfile.txt | wc -l                # 에러 개수
awk '{print $1}' access.log | sort | uniq -c | sort -nr  # IP별 접속 빈도
sed -n '100,200p' large_file.txt               # 100-200번째 줄만 출력
```

## Practice Section: 생물정보학 데이터 처리

```bash
# 실습 환경 진입
nix develop .#chapter01
```

이번 실습을 통해 생성되어야 할 최종 outputs 은 다음과 같습니다.

```bash
[drwxr-xr-x]  .
└── [drwxr-xr-x]  bioproject
    ├── [-rw-r--r--]  analysis.log
    ├── [lrwxr-xr-x]  current_data -> data/raw/sequences.fasta
    ├── [lrwxr-xr-x]  current_metadata -> data/raw/metadata.csv
    ├── [drwxr-x---]  data
    │   ├── [drwxr-xr-x]  backup
    │   │   ├── [-rw-------]  metadata.csv
    │   │   └── [-rw-------]  sequences.fasta
    │   ├── [drwxr-xr-x]  processed
    │   │   └── [-rw-r--r--]  sequences_working.fasta
    │   └── [drwx------]  raw
    │       ├── [-rw-r--r--]  lengths.txt
    │       ├── [-rw-r--r--]  metadata.csv
    │       └── [-rw-r--r--]  sequences.fasta
    ├── [-rw-r--r--]  mixed_ids.txt
    └── [drwxr-xr-x]  results
        ├── [-rw-r--r--]  lengths.report
        └── [-rw-r--r--]  report.txt

7 directories, 12 files
```

### 실습 1: FASTA 파일 기본 분석

```bash
# ./playground/practice/chapter01/bioproject/data/raw
cd ./bioproject/data/raw

# FASTA 파일 기본 정보 추출
echo "서열 개수: $(grep -c '^>' sequences.fasta)"
echo "총 라인 수: $(wc -l < sequences.fasta)"

# 서열 ID와 길이 분석 임시 파일 생성
awk '/^>/ {if(seq) print header, length(seq); header=$0; seq=""}
     !/^>/ {seq=seq$0}
     END {print header, length(seq)}' sequences.fasta > lengths.txt

echo "최단 서열: $(awk '{print $2, $1}' lengths.txt | sort -n | head -1 | awk '{print $2, $1}')bp" > ../../results/lengths.report
echo "최장 서열: $(awk '{print $2, $1}' lengths.txt | sort -n | tail -1 | awk '{print $2, $1}')bp" >> ../../results/lengths.report
echo "평균 길이: $(awk '{sum+=$2} END {print int(sum/NR)}' lengths.txt)bp" >> ../../results/lengths.report

# 보고서 확인
cd ../../results
cat lengths.report
```

### 실습 2: CSV 데이터 처리

```bash
cd ../data/raw/

# 메타데이터 분석
echo "총 샘플 수: $(tail -n +2 metadata.csv | wc -l)"

# 유기체별 분포
tail -n +2 metadata.csv | cut -d',' -f2 | sort | uniq -c

# 조건별 분석
tail -n +2 metadata.csv | cut -d',' -f3 | sort | uniq -c

# 특정 조건 필터링
awk -F',' '$3=="control" {print $1, $2}' metadata.csv
```

### 실습 3: 로그 파일 생성 및 분석

```bash
# bioproject 로 이동
cd ../..

# 샘플 로그 파일 생성
cat > analysis.log << 'EOF'
2024-01-15 09:00:00 [INFO] Analysis started
2024-01-15 09:05:12 [INFO] Loading sequences: 150 files
2024-01-15 09:15:30 [WARN] Low quality detected in sample_023
2024-01-15 09:25:45 [ERROR] Failed to process sample_087
2024-01-15 09:30:00 [INFO] Quality control completed
2024-01-15 09:45:22 [INFO] BLAST search started
2024-01-15 10:15:33 [WARN] Timeout in sample_045
2024-01-15 10:30:00 [INFO] Analysis completed
EOF

# 로그 분석
echo "=== 로그 파일 분석 ==="
echo "총 로그 라인: $(wc -l < analysis.log)"
echo "에러 발생: $(grep -c ERROR analysis.log)건"
echo "경고 발생: $(grep -c WARN analysis.log)건"

# 시간대별 로그 개수
echo -e "\n시간대별 로그:"
awk '{print substr($2, 1, 5)}' analysis.log | sort | uniq -c

# 에러와 경고 상세 내용
echo -e "\n문제 상황:"
grep -E "(ERROR|WARN)" analysis.log | cut -d']' -f2-
```

### 실습 4: 텍스트 변환과 정리

```bash
# 다양한 형식의 서열 ID 정리
cat > mixed_ids.txt << 'EOF'
>gi|123456|sp|P12345|GENE1_ECOLI
>ref|NM_000001.1|
>gb|ABC12345.1|gene_description
>seq_001_sample_A
>SEQ_002_SAMPLE_B
EOF

echo "=== ID 정리 작업 ==="
echo "원본 ID들:"
cat mixed_ids.txt

# ID 정리 (파이프 구분자 제거, 대소문자 통일)
echo -e "\n정리된 ID들:"
grep '^>' mixed_ids.txt | \
    sed 's/^>//' | \
    tr '|' '_' | \
    tr '[:upper:]' '[:lower:]'

# 서열 데이터 정리 (N 제거, 대문자 변환)
echo -e "\nATCGNNATCG" | tr -d 'N' | tr '[:lower:]' '[:upper:]'
```

### 실습 5: 복합 데이터 처리 파이프라인

```bash
cd ./data/raw
# 복잡한 데이터 처리 예제
echo "=== 복합 데이터 처리 ==="

# FASTA 헤더에서 종 정보 추출 및 통계
grep '^>' sequences.fasta | \
    cut -d'_' -f2 | \
    sort | uniq -c | \
    sort -nr | \
    awk '{printf "%-15s: %d개\n", $2, $1}'

# 메타데이터와 결합하여 분석
echo -e "\n조건별 유기체 분포:"
tail -n +2 metadata.csv | \
    awk -F',' '{print $2, $3}' | \
    sort | uniq -c | \
    awk '{printf "%-10s %-10s: %d개\n", $2, $3, $1}'

# 파일 크기별 정리
echo -e "\n파일 크기 분석:"
ls -la *.{fasta,csv} 2>/dev/null | \
    grep -v '^d' | \
    awk '{print $5, $9}' | \
    sort -nr | \
    awk '{
        size = $1
        if(size > 1000) printf "%-20s: %.1fKB\n", $2, size/1000
        else printf "%-20s: %dB\n", $2, size
    }'
```

---

## 핵심 정리

### 생물정보학 텍스트 처리 필수 패턴

```bash
# FASTA 파일 처리
awk '/^>/ {if(seq) print length(seq); seq=""} !/^>/ {seq=seq$0} END{print length(seq)}' file.fasta
grep -c "^>" file.fasta                     # 서열 개수
grep "^>" file.fasta | cut -d'|' -f2        # ID 추출

# CSV 데이터 분석
awk -F',' 'NR==1 || $3>threshold' data.csv  # 헤더 + 조건 필터
tail -n +2 data.csv | cut -d',' -f2 | sort | uniq -c  # 빈도 분석

# 로그 분석
grep -E "(ERROR|WARN)" logfile | cut -d' ' -f3-  # 에러/경고 메시지만
awk '{print $1}' logfile | sort | uniq -c        # 날짜별 집계
```

### 효율적인 대용량 파일 처리

```bash
# 메모리 효율적 처리
head -1000 large_file.txt | grep pattern    # 샘플링 후 테스트
sort -S 2G large_file.txt                   # 메모리 할당량 조정
split -l 10000 large_file.txt chunk_        # 파일 분할 후 처리

# 파이프라인 최적화
grep pattern file | head -100               # 조기 종료로 속도 향상
sort file | uniq -c | sort -nr | head -10   # Top 10 빈도 항목
```

---

**다음**: [1.5 Shell Scripting Basics](./ch01-5-shell-scripting.md)
