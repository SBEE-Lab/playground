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
