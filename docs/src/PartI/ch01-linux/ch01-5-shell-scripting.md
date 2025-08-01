# 1.5 Shell Scripting Basics

## 핵심 개념

Shell 스크립트는 명령어들을 파일에 저장하여 반복 작업을 자동화하는 도구입니다. 생물정보학 연구에서는 대량의 서열 파일 처리, 분석 파이프라인 실행, 시스템 모니터링 등에 필수적입니다.

### 스크립트 구조와 실행

스크립트의 첫 줄인 shebang(`#!/bin/bash`)은 어떤 해석기로 실행할지 지정합니다. 이후 변수 설정, 함수 정의, 메인 로직 순으로 구성합니다.

```bash
#!/bin/bash
# 스크립트 설명: FASTA 파일 일괄 처리
# 작성자: 연구자명, 날짜: 2024-01-15

# 전역 변수 설정
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly LOG_FILE="$SCRIPT_DIR/processing.log"
readonly DATA_DIR="${1:-data/raw}"

# 로깅 함수
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 메인 실행 함수
main() {
    log_message "스크립트 시작"
    process_files "$DATA_DIR"
    log_message "스크립트 완료"
}

# 스크립트 실행
main "$@"
```

실행 권한 부여와 실행 방법:

```bash
chmod +x script.sh          # 실행 권한 부여
./script.sh                 # 현재 디렉토리에서 실행
bash script.sh              # bash로 직접 실행
bash -x script.sh           # 디버그 모드 (각 명령어 출력)
bash -n script.sh           # 문법 검사만 수행
```

### 변수와 매개변수 처리

변수는 데이터 저장과 스크립트 설정에 사용됩니다. Bash에서는 타입이 없으므로 모든 값이 문자열로 처리되지만, 산술 연산 시 숫자로 해석됩니다.

```bash
# 변수 정의 (공백 없이)
project_name="bioanalysis"
data_directory="/home/user/bioproject/data"
max_threads=8
readonly CONFIG_FILE="/etc/analysis.conf"  # 변경 불가능한 상수

# 변수 사용 (중괄호로 명확히 구분)
echo "프로젝트: $project_name"
echo "데이터 위치: ${data_directory}/raw"
echo "출력 파일: ${project_name}_results.txt"

# 환경 변수 설정 (하위 프로세스에서도 사용 가능)
export PYTHONPATH="$HOME/scripts:$PYTHONPATH"
export BLAST_DB_PATH="/usr/local/db/blast"
```

매개변수는 스크립트 실행 시 전달되는 인자들로, 스크립트의 유연성을 높입니다:

```bash
# 특수 변수들
echo "스크립트 이름: $0"           # script.sh
echo "첫 번째 인자: $1"            # 사용자가 전달한 첫 번째 값
echo "두 번째 인자: $2"            # 사용자가 전달한 두 번째 값
echo "모든 인자: $*"               # 모든 인자를 하나의 문자열로
echo "모든 인자: $@"               # 각 인자를 개별 문자열로
echo "인자 개수: $#"               # 전달받은 인자의 수
echo "이전 명령 종료 코드: $?"      # 0=성공, 1-255=오류
echo "현재 프로세스 PID: $$"       # 스크립트의 프로세스 ID

# 기본값 설정 (매개변수가 없을 때 사용)
input_file="${1:-sequences.fasta}"     # $1이 없으면 sequences.fasta
output_dir="${2:-./results}"           # $2가 없으면 ./results
threads="${3:-$(nproc)}"               # $3이 없으면 CPU 코어 수
```

배열은 여러 값을 하나의 변수에 저장할 때 사용합니다:

```bash
# 배열 정의
samples=("ctrl_rep1" "ctrl_rep2" "treat_rep1" "treat_rep2")
declare -a organisms=("E.coli" "B.subtilis" "S.aureus")

# 배열 접근
echo "첫 번째 샘플: ${samples[0]}"
echo "모든 샘플: ${samples[@]}"        # 모든 요소
echo "배열 크기: ${#samples[@]}"       # 요소 개수
echo "인덱스 2-3: ${samples[@]:2:2}"   # 부분 배열

# 배열 순회
for sample in "${samples[@]}"; do
    echo "처리 중: $sample"
done
```

### 조건문과 논리 제어

조건문은 파일 존재, 데이터 유효성, 에러 처리 등에 핵심적입니다. Bash의 `[[ ]]`는 `[ ]`보다 강력하고 안전한 조건 검사를 제공합니다.

```bash
# 파일과 디렉토리 검사
if [[ -f "$input_file" ]]; then
    echo "파일 존재: $input_file"
elif [[ -d "$input_file" ]]; then
    echo "디렉토리 존재: $input_file"
else
    echo "파일/디렉토리 없음: $input_file"
    exit 1
fi

# 파일 속성 검사
[[ -f file ]]        # 일반 파일 존재
[[ -d dir ]]         # 디렉토리 존재
[[ -r file ]]        # 읽기 가능
[[ -w file ]]        # 쓰기 가능
[[ -x file ]]        # 실행 가능
[[ -s file ]]        # 비어있지 않음 (크기 > 0)
[[ -e file ]]        # 존재 (파일이든 디렉토리든)

# 문자열 비교
[[ "$var" == "value" ]]     # 정확히 같음
[[ "$var" != "value" ]]     # 다름
[[ "$var" =~ ^[0-9]+$ ]]    # 정규표현식 매치 (숫자만)
[[ -z "$var" ]]             # 빈 문자열 또는 미정의
[[ -n "$var" ]]             # 비어있지 않은 문자열

# 숫자 비교
[[ $num -eq 10 ]]          # 같음 (equal)
[[ $num -ne 10 ]]          # 다름 (not equal)
[[ $num -gt 5 ]]           # 초과 (greater than)
[[ $num -lt 20 ]]          # 미만 (less than)
[[ $num -ge 5 ]]           # 이상 (greater equal)
[[ $num -le 20 ]]          # 이하 (less equal)

# 논리 연산자
[[ -f "$file" && -r "$file" ]]     # AND: 파일이 존재하고 읽기 가능
[[ "$ext" == "fasta" || "$ext" == "fa" ]]  # OR: fasta 또는 fa 확장자
[[ ! -f "$file" ]]                 # NOT: 파일이 존재하지 않음
```

case문은 여러 조건을 깔끔하게 처리할 때 유용합니다:

```bash
# 파일 확장자별 처리
file_extension="${filename##*.}"
case "$file_extension" in
    "fasta"|"fa"|"fas")
        echo "FASTA 서열 파일 처리"
        process_sequences "$filename"
        ;;
    "fastq"|"fq")
        echo "FASTQ 품질 파일 처리"
        process_reads "$filename"
        ;;
    "csv"|"tsv")
        echo "표 형식 데이터 처리"
        process_table_data "$filename"
        ;;
    "log")
        echo "로그 파일 분석"
        analyze_log "$filename"
        ;;
    *)
        echo "지원하지 않는 파일 형식: $file_extension"
        return 1
        ;;
esac
```

### 반복문과 데이터 처리

반복문은 대량의 파일 처리나 반복 작업 자동화에 필수적입니다.

```bash
# for 루프 - 파일 글롭 패턴
for file in *.fasta; do
    # 파일이 실제로 존재하는지 확인 (glob이 매치되지 않을 때 대비)
    [[ -f "$file" ]] || continue
    echo "서열 분석 중: $file"
    analyze_sequences "$file"
done

# for 루프 - 숫자 범위
for sample_id in {001..100}; do
    input_file="sample_${sample_id}.fastq"
    if [[ -f "$input_file" ]]; then
        echo "샘플 $sample_id 품질 검사 중"
        quality_check "$input_file"
    fi
done

# for 루프 - 배열 순회
organisms=("E.coli" "B.subtilis" "S.aureus")
for organism in "${organisms[@]}"; do
    echo "유기체 분석: $organism"
    run_blast_search "$organism"
done

# C 스타일 for 루프 (수치 계산)
total_files=100
for ((i=1; i<=total_files; i++)); do
    progress=$((i * 100 / total_files))
    echo "진행률: $progress% ($i/$total_files)"
done
```

while 루프는 조건이 만족되는 동안 계속 실행되며, 파일 읽기나 대기 작업에 유용합니다:

```bash
# 파일 라인별 읽기 (가장 안전한 방법)
while IFS= read -r line; do
    echo "처리 중인 라인: $line"
    # IFS=는 앞뒤 공백 보존, -r은 백슬래시 이스케이프 방지
done < "$input_file"

# CSV 파일 처리 (필드 분리)
while IFS=',' read -r sample_id organism condition expression; do
    echo "샘플: $sample_id, 유기체: $organism, 발현량: $expression"
done < data.csv

# 조건부 대기 (프로세스 완료 대기)
job_pid=$!  # 백그라운드 작업의 PID
while kill -0 "$job_pid" 2>/dev/null; do
    echo "분석 작업 진행 중... (PID: $job_pid)"
    sleep 30
done
echo "분석 작업 완료"

# 무한 루프 (시스템 모니터링)
while true; do
    disk_usage=$(df -h /data | awk 'NR==2 {print $5}')
    echo "[$(date)] 디스크 사용률: $disk_usage"
    [[ "${disk_usage%?}" -gt 90 ]] && echo "경고: 디스크 공간 부족!"
    sleep 300  # 5분마다 확인
done
```

### 함수와 모듈화

함수는 코드 재사용과 가독성 향상을 위해 중요합니다. 복잡한 스크립트에서는 기능별로 함수를 분리하여 유지보수를 용이하게 합니다.

```bash
# 기본 함수 구조
validate_fasta_file() {
    local input_file="$1"          # local로 함수 내 변수 선언
    local min_sequences="$2"

    # 입력 검증
    if [[ ! -f "$input_file" ]]; then
        echo "에러: 파일 존재하지 않음: $input_file" >&2
        return 1
    fi

    # FASTA 형식 검증
    if ! grep -q "^>" "$input_file"; then
        echo "에러: FASTA 형식이 아님: $input_file" >&2
        return 2
    fi

    # 서열 수 확인
    local seq_count=$(grep -c "^>" "$input_file")
    if [[ $seq_count -lt $min_sequences ]]; then
        echo "경고: 서열 수 부족: $seq_count < $min_sequences" >&2
        return 3
    fi

    echo "검증 완료: $seq_count개 서열 발견"
    return 0  # 성공
}

# 함수 호출과 결과 처리
if validate_fasta_file "sequences.fasta" 10; then
    echo "FASTA 파일 검증 성공"
    process_sequences "sequences.fasta"
else
    exit_code=$?
    echo "검증 실패 (코드: $exit_code)"
    exit $exit_code
fi
```

고급 함수 활용 패턴:

```bash
# 옵션 처리 함수
parse_command_line() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--input)
                readonly INPUT_FILE="$2"
                shift 2
                ;;
            -o|--output)
                readonly OUTPUT_DIR="$2"
                shift 2
                ;;
            -t|--threads)
                readonly THREADS="$2"
                shift 2
                ;;
            --dry-run)
                readonly DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                readonly VERBOSE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                echo "에러: 알 수 없는 옵션 $1" >&2
                show_usage
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

    # 필수 매개변수 검증
    if [[ -z "$INPUT_FILE" ]]; then
        echo "에러: 입력 파일 필수 (-i 옵션)" >&2
        exit 1
    fi
}

# 도움말 함수
show_usage() {
    cat << EOF
사용법: $0 [옵션]

필수 옵션:
    -i, --input FILE     입력 FASTA 파일

선택 옵션:
    -o, --output DIR     출력 디렉토리 (기본값: ./results)
    -t, --threads NUM    병렬 처리 스레드 수 (기본값: $(nproc))
    --dry-run           실제 실행 없이 명령어만 출력
    -v, --verbose       상세 진행 상황 출력
    -h, --help          이 도움말 표시

예시:
    $0 -i sequences.fasta -o analysis_results -t 8 -v
    $0 --input data.fa --output results --threads 4 --dry-run
EOF
}

# 에러 처리 함수
handle_error() {
    local exit_code=$1
    local line_number=$2
    local command="$3"

    echo "에러 발생!" >&2
    echo "  파일: $0" >&2
    echo "  라인: $line_number" >&2
    echo "  명령어: $command" >&2
    echo "  종료 코드: $exit_code" >&2

    # 정리 작업
    cleanup_temp_files
    exit $exit_code
}

# 에러 트랩 설정
trap 'handle_error $? $LINENO "$BASH_COMMAND"' ERR
```

### 입출력 제어와 로깅

입출력 리다이렉션은 스크립트의 결과를 파일로 저장하거나 다른 프로그램과 연결할 때 사용됩니다.

```bash
# 기본 리다이렉션
command > output.txt           # 표준 출력을 파일로 (덮어쓰기)
command >> output.txt          # 표준 출력을 파일에 추가
command 2> error.txt           # 표준 에러를 파일로
command > output.txt 2>&1      # 출력과 에러를 같은 파일로
command &> all_output.txt      # 위와 동일 (bash 4.0+)
command > /dev/null 2>&1       # 모든 출력 숨기기

# Here Document (설정 파일 생성 등)
cat << EOF > blast_config.txt
# BLAST 검색 설정
database: nr
evalue: 1e-5
max_targets: 100
output_format: 6
EOF

# Here String (간단한 입력)
grep "pattern" <<< "$variable_content"
```

파이프라인과 고급 처리:

```bash
# 복잡한 데이터 처리 파이프라인
grep "^>" sequences.fasta | \
    sed 's/^>//' | \
    cut -d'|' -f2 | \
    sort | \
    uniq -c | \
    sort -nr > organism_counts.txt

# 조건부 파이프라인
if [[ $verbose == true ]]; then
    analysis_command | tee analysis.log
else
    analysis_command > analysis.log 2>&1
fi

# 명명된 파이프 (FIFO) 활용
mkfifo analysis_pipe
analysis_producer > analysis_pipe &
analysis_consumer < analysis_pipe
rm analysis_pipe
```

로깅 시스템 구현:

```bash
# 로깅 함수들
setup_logging() {
    readonly LOG_DIR="logs"
    readonly LOG_FILE="$LOG_DIR/analysis_$(date +%Y%m%d_%H%M%S).log"

    mkdir -p "$LOG_DIR"
    exec 3>&1 4>&2  # 원본 stdout, stderr 백업
    exec 1> >(tee -a "$LOG_FILE")
    exec 2> >(tee -a "$LOG_FILE" >&2)
}

log_info() {
    echo "[INFO $(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log_warn() {
    echo "[WARN $(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

log_error() {
    echo "[ERROR $(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

# 사용 예시
setup_logging
log_info "분석 시작"
log_warn "임시 파일 사용량 높음"
log_error "BLAST 데이터베이스 연결 실패"
```

## Practice Section: 생물정보학 연구 자동화

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
    ├── [drwxr-xr-x]  results
    │   ├── [-rw-r--r--]  lengths.report
    │   └── [-rw-r--r--]  report.txt
    └── [drwxr-xr-x]  scripts
        ├── [-rwxr-xr-x]  analyze_fasta.sh
        ├── [-rwxr-xr-x]  batch_process.sh
        ├── [-rwxr-xr-x]  conditional_process.sh
        ├── [-rwxr-xr-x]  function_example.sh
        ├── [drwxr-xr-x]  results
        │   └── [-rw-r--r--]  sequences_analysis.txt
        └── [-rwxr-xr-x]  simple_monitor.sh

9 directories, 18 files
```

### 실습 1: 기본 FASTA 분석 스크립트

```bash
cd ./bioproject/

mkdir scripts

cat > analyze_fasta.sh << 'EOF'
#!/bin/bash
# FASTA 파일 기본 분석

input_file="$1"

# 입력 검증
if [[ ! -f "$input_file" ]]; then
    echo "사용법: $0 <fasta_file>"
    exit 1
fi

echo "=== FASTA 분석: $(basename "$input_file") ==="

# 서열 개수
seq_count=$(grep -c "^>" "$input_file")
echo "서열 개수: $seq_count"

# 서열 길이 계산
awk '
/^>/ { if(seq) print length(seq); seq="" }
!/^>/ { seq = seq $0 }
END { if(seq) print length(seq) }
' "$input_file" > lengths.txt

# 통계 출력
echo "최소 길이: $(sort -n lengths.txt | head -1)bp"
echo "최대 길이: $(sort -n lengths.txt | tail -1)bp"
echo "평균 길이: $(awk '{sum+=$1} END {print int(sum/NR)}' lengths.txt)bp"

rm lengths.txt
EOF

chmod +x analyze_fasta.sh
./analyze_fasta.sh ../data/raw/sequences.fasta

# 실행 권한은 다음과 같이 삭제할 수 있음
# chmod -x analyze_fasta.sh
```

### 실습 2: 다중 파일 처리

```bash
cat > batch_process.sh << 'EOF'
#!/bin/bash
# 여러 FASTA 파일 일괄 처리

input_dir="${1:-../data/raw}"
output_dir="${2:-results}"

mkdir -p "$output_dir"

echo "일괄 처리 시작: $(date)"
count=0

for file in "$input_dir"/*.fasta; do
    [[ -f "$file" ]] || continue

    filename=$(basename "$file" .fasta)
    echo "처리 중: $filename"

    ./analyze_fasta.sh "$file" > "$output_dir/${filename}_analysis.txt"
    ((count++))
done

echo "처리 완료: $count 개 파일"
EOF

chmod +x batch_process.sh
./batch_process.sh
```

### 실습 3: 조건부 처리

```bash
cat > conditional_process.sh << 'EOF'
#!/bin/bash
# 파일 크기에 따른 조건부 처리

for file in ../data/raw/*.fasta; do
    [[ -f "$file" ]] || continue

    size=$(wc -c < "$file")
    filename=$(basename "$file")

    if [[ $size -gt 1000 ]]; then
        echo "대용량 파일: $filename ($size bytes)"
        # 특별한 처리 로직
    else
        echo "소용량 파일: $filename ($size bytes)"
        # 빠른 처리 로직
    fi
done
EOF

chmod +x conditional_process.sh
./conditional_process.sh
```

### 실습 4: 간단한 모니터링

CAUTION: macOS 는 `free` 명령어 없음

```bash
cat > simple_monitor.sh << 'EOF'
#!/bin/bash
# 시스템 리소스 간단 모니터링

monitor_system() {
  echo "=== 시스템 상태 $(date '+%H:%M:%S') ==="

  # CPU 사용률
  cpu=$(top -l 1 | grep "Cpu(s)" | awk '{print $2}')
  echo "CPU: $cpu"

  # 메모리 사용률
  memory=$(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}')
  echo "메모리: $memory"

  # 실행 중인 분석 프로세스
  python_count=$(pgrep python | wc -l)
  echo "Python 프로세스: $python_count 개"

  echo "---"
}

# 5번 모니터링 (실제로는 while true 사용)
for _ in {1..5}; do
  monitor_system
  sleep 2
done
EOF

chmod +x simple_monitor.sh
./simple_monitor.sh
```

### 실습 5: 함수와 매개변수

```bash
cat > function_example.sh << 'EOF'
#!/bin/bash
# 함수 활용 예제

# FASTA 파일 검증 함수
validate_fasta() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "에러: 파일 없음 $file"
    return 1
  fi

  if ! grep -q "^>" "$file"; then
    echo "에러: FASTA 형식 아님 $file"
    return 1
  fi

  echo "검증 성공: $file"
  return 0
}

# 서열 개수 세기 함수
count_sequences() {
  local file="$1"
  local count
  count=$(grep -c "^>" "$file")
  echo "$file: $count 개 서열"
}

# 메인 실행
for file in ../data/raw/*.fasta; do
  if validate_fasta "$file"; then
    count_sequences "$file"
  fi
done
EOF

chmod +x function_example.sh
./function_example.sh
```

---

## 핵심 정리

### 기본 스크립트 패턴

```bash
#!/bin/bash
# 안전한 스크립트 작성
set -euo pipefail                    # 에러 시 종료, 미정의 변수 금지

# 입력 검증
input_file="${1:?사용법: $0 <file>}"
[[ -f "$input_file" ]] || { echo "파일 없음"; exit 1; }

# 함수 활용
process_file() {
    local file="$1"
    echo "처리 중: $(basename "$file")"
    # 작업 수행
}

# 반복 처리
for file in *.fasta; do
    [[ -f "$file" ]] || continue
    process_file "$file"
done
```

### 생물정보학 스크립트 요약

```bash
# FASTA 검증
[[ $(head -1 "$file") =~ ^> ]] || { echo "FASTA 아님"; exit 1; }

# 서열 개수
seq_count=$(grep -c "^>" "$file")

# 로그와 함께 실행
command 2>&1 | tee logfile.log

# 진행률 표시
echo "진행률: $((current * 100 / total))%"
```

---

**다음**: [Chapter 2: Development Environment with Nix](../ch02-nix/ch02-0-introduction-to-nix.md)
