lengths = [245, 189, 567, 123, 445]
total = 0
count = 0

# 각 단계를 정의
for idx, length in enumerate(lengths):
    total = total + length  # 상태 변경
    count = count + 1  # 상태 변경
    print(f"step {idx}: total={total}, count: {count}")

average = total / count
print(f"result: average={average}")
