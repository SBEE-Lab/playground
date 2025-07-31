#!/usr/bin/env python3
import signal
import sys
import time


def signal_handler(sig, frame):
    print("정상 종료 시그널 받음")
    sys.exit(0)


signal.signal(signal.SIGTERM, signal_handler)

print("무한 루프 시작 (Ctrl+C 또는 kill로 종료)")
counter = 0
while True:
    counter += 1
    print(f"카운터: {counter}")
    time.sleep(2)
