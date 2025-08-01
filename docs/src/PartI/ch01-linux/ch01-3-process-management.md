# 1.3 Process Management

> **CAUTION**
>
> MacOS 환경에서는 Linux 와 process 관리가 달라 일부 프로그램이 지원되지 않습니다.
> 향후 학습 환경을 VM 으로 업데이트할 예정이므로, 지원 전까지는 VM 을 별도로 사용하시거나 Docker 사용을 권장합니다.
>
> Windows 에서는 WSL 이 Linux 이므로 동일하게 동작할 것입니다.

## 핵심 개념

프로세스는 실행 중인 프로그램의 인스턴스입니다. 생물정보학 연구에서는 장시간 실행되는 분석 작업이 많기 때문에 프로세스 모니터링, 제어, 백그라운드 실행 관리가 매우 중요합니다.

### 프로세스 기본 개념

모든 프로세스는 고유한 프로세스 ID(PID)를 가지며, 부모-자식 관계를 형성합니다. 프로세스는 여러 상태를 가질 수 있으며, 각 상태에 따라 시스템 자원 사용 패턴이 달라집니다.

```bash
# 프로세스 상태 코드
# R: Running (실행 중)
# S: Sleeping (대기 중)
# Z: Zombie (종료되었지만 정리되지 않음)
# T: Stopped (일시정지)
# D: Uninterruptible Sleep (디스크 I/O 대기)
```

프로세스 정보에는 다음과 같은 중요한 정보들이 포함됩니다:

- **PID**: Process ID (프로세스 고유 번호)
- **PPID**: Parent Process ID (부모 프로세스 번호)
- **%CPU**: CPU 사용률
- **%MEM**: 메모리 사용률
- **VSZ**: Virtual memory Size (가상 메모리 크기)
- **RSS**: Resident Set Size (실제 메모리 사용량)
- **TTY**: 연결된 터미널
- **STAT**: 프로세스 상태
- **START**: 시작 시간
- **TIME**: 누적 CPU 사용 시간
- **COMMAND**: 실행 명령어

### 프로세스 조회와 모니터링

시스템에서 실행 중인 프로세스를 확인하고 모니터링하는 것은 시스템 관리의 기본입니다.

```bash
# 기본 프로세스 조회
ps                              # 현재 터미널의 프로세스만
ps aux                          # 모든 사용자의 모든 프로세스 (BSD 스타일)
ps -ef                          # 모든 프로세스 전체 형식 (System V 스타일)
ps -u username                  # 특정 사용자의 프로세스만

# 프로세스 트리 (계층 구조)
pstree                          # 프로세스 계층 구조를 트리로 표시
pstree -p                       # PID와 함께 표시
pstree username                 # 특정 사용자의 프로세스 트리

# 특정 프로세스 찾기
pgrep python                    # python 관련 프로세스의 PID들
pgrep -f "analysis.py"          # 명령줄에 analysis.py가 포함된 프로세스
pidof python                    # python 프로세스의 모든 PID
ps aux | grep python            # python 관련 프로세스 상세 정보
```

### 실시간 모니터링

장시간 실행되는 분석 작업의 진행 상황과 시스템 부하를 실시간으로 모니터링하는 것이 중요합니다.

```bash
# top - 실시간 프로세스 모니터링
top                             # 기본 top 실행
top -u username                 # 특정 사용자의 프로세스만
top -p 1234,5678               # 특정 PID들만 모니터링

# top 내에서 사용할 수 있는 키
# q: 종료
# k: 프로세스 종료 (PID 입력 후 시그널 선택)
# M: 메모리 사용량순 정렬
# P: CPU 사용량순 정렬
# T: 실행 시간순 정렬
# u: 특정 사용자 필터링

# htop (향상된 top, 설치 필요)
htop                           # 컬러풀하고 대화형 인터페이스

# watch - 명령어 반복 실행
watch -n 5 "ps aux | grep python"      # 5초마다 python 프로세스 확인
watch "df -h"                           # 디스크 사용량 실시간 모니터링
```

### 프로세스 제어

프로세스를 제어하는 것은 시스템 관리와 문제 해결의 핵심입니다. 시그널을 통해 프로세스와 통신할 수 있습니다.

```bash
# 시그널을 통한 프로세스 제어
kill PID                        # TERM 시그널 (정상 종료 요청)
kill -9 PID                     # KILL 시그널 (강제 종료)
kill -15 PID                    # TERM 시그널 (명시적)
kill -STOP PID                  # 프로세스 일시정지
kill -CONT PID                  # 일시정지된 프로세스 재시작
kill -HUP PID                   # 설정 파일 재로드 (많은 서비스에서 사용)

# 프로세스 이름으로 제어
killall python                 # 모든 python 프로세스 종료
killall -9 firefox             # 모든 firefox 프로세스 강제 종료
killall -STOP analysis_script   # 분석 스크립트 일시정지

# 패턴으로 프로세스 제어
pkill -f "analysis.py"         # analysis.py를 실행하는 프로세스 종료
pkill -u username              # 특정 사용자의 모든 프로세스 종료
pkill -9 -f "long_running"     # long_running이 포함된 프로세스 강제 종료
```

주요 시그널들:

| 시그널 | 번호 | 의미           | 기본 동작                    |
| ------ | ---- | -------------- | ---------------------------- |
| TERM   | 15   | 정상 종료 요청 | 프로세스가 정리 작업 후 종료 |
| KILL   | 9    | 강제 종료      | 즉시 종료 (정리 작업 없음)   |
| STOP   | 19   | 일시정지       | 프로세스 중단                |
| CONT   | 18   | 재시작         | 중단된 프로세스 재개         |
| HUP    | 1    | 재시작/재로드  | 설정 파일 재로드             |

### 백그라운드 작업 관리

생물정보학 분석은 종종 몇 시간에서 며칠이 걸리므로 백그라운드 실행과 관리가 필수적입니다.

```bash
# 백그라운드 실행
command &                       # 명령어를 백그라운드에서 실행
python analysis.py &            # Python 스크립트 백그라운드 실행
nohup python analysis.py &      # 터미널 종료 후에도 계속 실행

# 작업 제어 (Job Control)
jobs                           # 현재 쉘의 백그라운드 작업 목록
jobs -l                        # 작업 목록을 PID와 함께 표시

fg %1                          # 작업 1을 포그라운드로 가져오기
bg %2                          # 작업 2를 백그라운드에서 재시작
kill %1                        # 작업 1 종료

# 키보드 단축키
# Ctrl+C: 현재 프로세스에 SIGINT 전송 (중단)
# Ctrl+Z: 현재 프로세스에 SIGTSTP 전송 (일시정지)
# Ctrl+\: 현재 프로세스에 SIGQUIT 전송 (강제 종료)
```

### nohup과 장시간 실행

연구 분석 작업은 SSH 연결이 끊어져도 계속 실행되어야 하는 경우가 많습니다.

```bash
# nohup 사용법
nohup python analysis.py &                      # 기본 사용법
nohup python analysis.py > output.log 2>&1 &   # 출력을 로그 파일로 저장
nohup python analysis.py < input.txt > output.log 2>&1 &  # 입력과 출력 모두 리다이렉션

# 실행 상태 확인
ps aux | grep analysis.py                       # 프로세스 확인
cat nohup.out                                   # 기본 출력 파일 확인
tail -f output.log                              # 실시간 로그 모니터링
```

### screen과 tmux

터미널 세션을 유지하여 장시간 작업을 안전하게 관리할 수 있는 도구들입니다.

```bash
# screen 기본 사용법
screen                                  # 새 screen 세션 시작
screen -S analysis                      # 이름을 지정한 세션 시작
screen -ls                             # 활성 세션 목록 확인
screen -r analysis                     # 세션에 재연결

# screen 내부 명령어 (Ctrl+A가 명령 프리픽스)
# Ctrl+A, d: 세션에서 분리 (detach)
# Ctrl+A, c: 새 창 생성
# Ctrl+A, n: 다음 창으로 이동
# Ctrl+A, p: 이전 창으로 이동
# Ctrl+A, ": 창 목록 보기

# tmux 기본 사용법 (더 현대적)
tmux                                   # 새 tmux 세션 시작
tmux new -s analysis                   # 이름을 지정한 세션
tmux ls                               # 세션 목록
tmux attach -t analysis               # 세션에 재연결
tmux kill-session -t analysis         # 세션 종료

# tmux 내부 명령어 (Ctrl+B가 기본 프리픽스)
# Ctrl+B, d: 세션에서 분리
# Ctrl+B, c: 새 창 생성
# Ctrl+B, %: 세로 분할
# Ctrl+B, ": 가로 분할
```

### 시스템 리소스 모니터링

분석 작업이 시스템에 미치는 영향을 모니터링하고 최적화하는 것이 중요합니다.

```bash
# 메모리 사용량
free -h                               # 메모리 사용량 (사람이 읽기 쉬운 형태)
free -m                               # MB 단위로 표시
cat /proc/meminfo                     # 상세한 메모리 정보

# CPU 정보
cat /proc/cpuinfo                     # CPU 상세 정보
nproc                                 # CPU 코어 수
lscpu                                 # CPU 아키텍처 정보

# 시스템 부하
uptime                                # 시스템 가동 시간과 로드 평균
w                                     # 로그인한 사용자와 그들의 작업
vmstat 5                              # 5초 간격으로 시스템 통계
iostat 5                              # I/O 통계 (sysstat 패키지 필요)

# 프로세스별 리소스 사용량
ps aux --sort=-%cpu | head -10        # CPU 사용률 상위 10개 프로세스
ps aux --sort=-%mem | head -10        # 메모리 사용률 상위 10개 프로세스
```

## Practice Section: 생물정보학 분석 작업 관리

```bash
# 실습 환경 진입
nix develop .#chapter01
```

이번 실습을 통해 생성되어야 할 최종 outputs 은 없습니다.

### 실습 1: 기본 프로세스 모니터링

```bash
# 현재 시스템 상태 확인
uptime
free -h | grep Mem

# Python 프로세스 확인
pgrep python | wc -l | xargs echo "Python 프로세스 수:"
ps aux | grep python | grep -v grep

# 시스템 부하 확인 (CPU 사용률 상위 5개)
ps aux --sort=-%cpu | head -6
```

### 실습 2: 백그라운드 작업 시뮬레이션

```bash
# 백그라운드에서 실행
long-task 30 > task_output.log 2>&1 &
task_pid=$!

# 작업 pid 확인
echo $task_pid

# 작업 상태 확인
ps aux | grep long_task | grep -v grep

rm task_output.log
```

### 실습 3: nohup을 이용한 안전한 실행

```bash
# 연결이 끊어져도 계속 실행되는 작업
nohup long-task 45 > nohup_output.log 2>&1 &
nohup_pid=$!

# PID 저장
echo $nohup_pid > analysis.pid
echo "분석 PID 저장: $(cat analysis.pid)"

# 상태 모니터링
sleep 5
echo "=== 작업 상태 ==="
if kill -0 $nohup_pid 2>/dev/null; then
    echo "작업 실행 중..."
    tail -n 5 nohup_output.log
else
    echo "작업 완료됨"
fi

rm nohup_output.log analysis.pid
```

### 실습 4: 프로세스 제어 연습

```bash
# 테스트용 무한 루프 백그라운드 실행
# 카운터가 무한히 실행되어 화면에 출력되지만 계속 진행하면 됩니다
infinite-task
test_pid=$!
echo "테스트 프로세스 PID: $test_pid"

# 잠시 실행 후 정상 종료
sleep 10
echo "정상 종료 시그널 전송..."
kill $test_pid

# 정리 확인
sleep 2
if kill -0 $test_pid 2>/dev/null; then
    echo "강제 종료 필요"
    kill -9 $test_pid
else
    echo "정상 종료됨"
fi
```

### 실습 5: 시스템 모니터링 스크립트

```bash
# 모니터링 스크립트
# 5회 모니터링 실행
for i in {1..5}; do
    monitor
    sleep 3
done
```

---

## 핵심 정리

### 프로세스 관리 필수 명령어

```bash
# 프로세스 확인
ps aux | grep process_name              # 특정 프로세스 찾기
pgrep -f pattern                        # 패턴으로 PID 찾기
top -u username                         # 사용자별 프로세스 모니터링

# 프로세스 제어
kill PID                                # 정상 종료
kill -9 PID                            # 강제 종료
killall process_name                    # 이름으로 종료

# 백그라운드 실행
nohup command > logfile 2>&1 &         # 안전한 백그라운드 실행
```

### 장시간 작업 관리 패턴

```bash
# 작업 시작
nohup python analysis.py > analysis.log 2>&1 &
echo $! > analysis.pid

# 상태 확인
tail -f analysis.log
ps aux | grep analysis.py

# 안전한 종료
kill $(cat analysis.pid)
```

---

**다음**: [1.4 Text Processing Tools](./ch01-4-text-processing.md)
