# 문제가 있는 접근: 원본 데이터 변경
data = [1, 2, 3]
print(f"original:{data}")

data.append(4)  # 원본이 변경됨
print(f"varaible can be changed: {data}")  # [1, 2, 3, 4] - 원본 손실

# 불변성 접근: 새로운 데이터 생성
original_data = [1, 2, 3]

# QUESTION: Answer on your report
new_data = original_data + [4]  # 새로운 리스트 생성
print(f"original_data: {original_data}")  # [1, 2, 3] - 원본 보존
print(f"new_data:{new_data}")  # [1, 2, 3, 4] - 새 데이터
