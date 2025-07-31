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
