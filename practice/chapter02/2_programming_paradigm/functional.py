def functional_1():
    lengths = [245, 189, 567, 123, 445]
    # 중간 상태 변경 없이 직접 계산
    average = sum(lengths) / len(lengths)
    print(f"average={average}")


def functional_2():
    lengths = [245, 189, 567, 123, 445]

    # 또는 함수 조합으로
    from statistics import mean

    average = mean(lengths)
    print(f"average={average}")


if __name__ == "__main__":
    print("functional_1:")
    functional_1()

    print("functional_2:")
    functional_2()
