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
