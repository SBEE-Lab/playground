#!/usr/bin/env python3
import sys
import time


def simulate_analysis(duration=60):
    print(f"분석 시작: {duration}초 동안 실행")
    for i in range(duration):
        time.sleep(1)
        if i % 10 == 0:
            print(f"진행률: {i}/{duration}")
    print("분석 완료!")


if __name__ == "__main__":
    duration = int(sys.argv[1]) if len(sys.argv) > 1 else 30
    simulate_analysis(duration)
