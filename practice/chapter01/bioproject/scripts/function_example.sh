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
