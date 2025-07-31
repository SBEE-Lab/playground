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
