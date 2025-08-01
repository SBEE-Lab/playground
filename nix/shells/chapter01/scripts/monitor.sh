#!/bin/bash
# 간단한 시스템 모니터링

echo "=== 시스템 모니터링 ($(date)) ==="

# 메모리 사용률
echo "메모리 사용률:"
free | grep Mem | awk '{printf "사용: %.1f%%\n", $3/$2 * 100.0}'

# CPU 로드
echo "CPU 로드 평균:"
uptime | awk -F'load average:' '{print $2}'

# 분석 관련 프로세스
echo "Python 프로세스:"
pgrep python | wc -l | xargs echo "실행 중:"

# 디스크 사용량
echo "데이터 디렉토리 사용량:"
du -sh ~/bioproject/data 2>/dev/null || echo "계산 불가"

echo "---"
