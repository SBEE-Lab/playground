# 1.2 File System & Permissions

## 핵심 개념

Linux 파일 시스템은 계층적 구조로 조직화되어 있으며, 모든 파일과 디렉토리에는 소유권과 권한이 설정되어 있습니다. 권한 시스템은 데이터 보안과 시스템 안정성을 보장하는 핵심 메커니즘입니다.

### Linux 파일 시스템 구조 (FHS)

Linux 파일 시스템은 Filesystem Hierarchy Standard(FHS)를 따라 구성됩니다. 각 디렉토리는 특정한 용도를 가지며, 이를 이해하면 시스템을 더 효과적으로 활용할 수 있습니다.

```bash
/                    # 루트 디렉토리 (모든 것의 시작점)
├── bin/             # 필수 실행 파일 (ls, cp, mv 등)
├── etc/             # 시스템 설정 파일
├── home/            # 사용자 홈 디렉토리
│   └── username/    # 개별 사용자 디렉토리
├── tmp/             # 임시 파일 (재부팅 시 삭제될 수 있음)
├── usr/             # 사용자 프로그램
│   ├── bin/         # 일반 사용자 실행 파일
│   ├── lib/         # 공유 라이브러리
│   └── local/       # 로컬 설치 프로그램
└── var/             # 변경되는 데이터
    ├── log/         # 시스템 로그 파일
    └── tmp/         # 영구적인 임시 파일
```

### 경로 표현 방식

파일과 디렉토리의 위치를 나타내는 방법에는 절대 경로와 상대 경로가 있습니다. 각각의 특성을 이해하고 상황에 맞게 사용해야 합니다.

```bash
# 절대 경로: 루트(/)부터 시작하는 전체 경로
/home/user/bioproject/data/sequences.fasta
/usr/bin/python
/etc/passwd

# 상대 경로: 현재 위치부터 시작하는 경로
./data/sequences.fasta          # 현재 디렉토리의 data 하위
../scripts/analysis.py          # 상위 디렉토리의 scripts 하위
../../backup/                   # 두 단계 위의 backup

# 특수 경로 표현
~                               # 현재 사용자의 홈 디렉토리
~/bioproject/                   # 홈 디렉토리의 bioproject
~username/shared/               # 다른 사용자의 shared 디렉토리
```

### 파일 권한 시스템

Linux의 권한 시스템은 각 파일과 디렉토리에 대해 소유자(user), 그룹(group), 기타(others)의 세 가지 주체에 대한 읽기(read), 쓰기(write), 실행(execute) 권한을 관리합니다.

```bash
# ls -l 출력 해석
$ ls -l filename.txt
-rw-r--r-- 1 user group 1024 Jan 15 10:30 filename.txt
 |||||||||| | |    |     |    |           |
 |||||||++-- 기타 사용자 권한 (r--)
 ||||+++---- 그룹 권한 (r--)
 |+++------- 소유자 권한 (rw-)
 +---------- 파일 타입 (- = 일반파일, d = 디렉토리, l = 링크)
             | |    |     |    |           |
             | |    |     |    |           +-- 파일명
             | |    |     |    +-- 수정 날짜/시간
             | |    |     +-- 파일 크기 (바이트)
             | |    +-- 그룹명
             | +-- 소유자명
             +-- 링크 수
```

권한의 의미는 파일과 디렉토리에서 다르게 해석됩니다:

| 권한        | 파일에서의 의미     | 디렉토리에서의 의미     |
| ----------- | ------------------- | ----------------------- |
| r (read)    | 파일 내용 읽기      | 디렉토리 목록 보기 (ls) |
| w (write)   | 파일 내용 수정/삭제 | 파일 생성/삭제 가능     |
| x (execute) | 파일 실행           | 디렉토리 진입 가능 (cd) |

### 권한 변경 명령어

권한을 변경하는 방법에는 숫자 표기법과 기호 표기법이 있습니다. 각각의 장단점을 이해하고 상황에 맞게 사용해야 합니다.

```bash
# 숫자 표기법 (8진수)
# r=4, w=2, x=1로 계산하여 합산
chmod 755 script.sh             # rwxr-xr-x (소유자: 모든 권한, 그룹/기타: 읽기+실행)
chmod 644 data.txt              # rw-r--r-- (소유자: 읽기+쓰기, 그룹/기타: 읽기만)
chmod 600 private.key           # rw------- (소유자만 읽기+쓰기)
chmod 777 shared_dir            # rwxrwxrwx (모든 사용자 모든 권한 - 보안상 위험)

# 기호 표기법
chmod u+x script.sh             # 소유자(user)에게 실행 권한 추가
chmod g-w file.txt              # 그룹(group)에서 쓰기 권한 제거
chmod o-r private.txt           # 기타(others)에서 읽기 권한 제거
chmod a+r public.txt            # 모든 사용자(all)에게 읽기 권한 추가

# 복합 권한 설정
chmod u=rw,g=r,o= secret.txt    # 소유자:읽기+쓰기, 그룹:읽기만, 기타:권한없음
chmod -R 755 directory/         # 디렉토리와 모든 하위 파일에 재귀적으로 적용
```

### 소유권 관리

파일과 디렉토리의 소유자와 그룹을 변경하는 것도 권한 관리의 중요한 부분입니다.

```bash
# 소유자 변경
chown newuser file.txt                  # 소유자만 변경
chown newuser:newgroup file.txt         # 소유자와 그룹 모두 변경
chown :newgroup file.txt                # 그룹만 변경
chown -R user:group directory/          # 재귀적으로 변경

# 그룹만 변경 (chgrp 사용)
chgrp newgroup file.txt
chgrp -R research_team data/

# 현재 사용자와 그룹 확인
id                                      # 현재 사용자의 UID, GID, 소속 그룹 정보
groups                                  # 현재 사용자가 속한 그룹들
whoami                                  # 현재 사용자명
```

### 고급 파일 조작

파일의 성격과 연결 관계를 이해하고 활용하는 것은 효율적인 파일 관리에 중요합니다.

```bash
# 파일 타입과 정보 확인
file filename                   # 파일 타입 확인 (텍스트, 바이너리, 실행파일 등)
file *.fasta                   # 여러 파일의 타입 확인
stat filename                  # 상세한 파일 정보 (크기, 권한, 타임스탬프, inode 등)

# 심볼릭 링크 생성과 활용
ln -s /path/to/original.txt symlink.txt              # 심볼릭 링크 생성
ln -s ../data/sequences.fasta current_sequences      # 상대 경로로 링크
readlink symlink.txt                                 # 링크가 가리키는 원본 파일 확인
ls -la | grep "^l"                                  # 심볼릭 링크만 찾기

# 하드 링크 (같은 inode를 공유)
ln original.txt hardlink.txt             # 하드 링크 생성
ls -li                                   # inode 번호와 함께 출력 (같은 파일은 같은 inode)
```

### 파일 검색

대용량 연구 데이터에서 원하는 파일을 찾는 것은 자주 발생하는 작업입니다. find 명령어는 매우 강력한 검색 도구입니다.

```bash
# 이름으로 검색
find /path -name "pattern"              # 정확한 패턴 매칭
find . -name "*.fasta"                  # 현재 디렉토리에서 FASTA 파일 찾기
find . -iname "*.FASTA"                 # 대소문자 무시하고 검색

# 타입으로 검색
find . -type f -name "*.txt"            # 일반 파일 중에서 .txt 파일
find . -type d -name "*data*"           # 디렉토리 중에서 data가 포함된 것
find . -type l                          # 심볼릭 링크만 찾기

# 크기로 검색
find . -size +1M                        # 1MB보다 큰 파일
find . -size -100k                      # 100KB보다 작은 파일
find . -empty                           # 빈 파일 찾기

# 시간으로 검색
find . -mtime -7                        # 7일 이내에 수정된 파일
find . -atime +30                       # 30일 이상 접근하지 않은 파일
find . -newer reference_file             # 참조 파일보다 최근에 수정된 파일

# 권한으로 검색
find . -perm 644                        # 정확히 644 권한인 파일
find . -perm -644                       # 최소 644 권한 이상인 파일
find . -perm /u+w                       # 소유자 쓰기 권한이 있는 파일

# 소유자로 검색
find . -user username                   # 특정 사용자가 소유한 파일
find . -group groupname                 # 특정 그룹이 소유한 파일

# 검색 결과로 작업 수행
find . -name "*.tmp" -delete            # 임시 파일 모두 삭제
find . -name "*.fasta" -exec ls -l {} \;  # FASTA 파일의 상세 정보 출력
find . -type f -exec chmod 644 {} \;    # 모든 파일을 644 권한으로 변경
```

## Practice Section: 연구 데이터 권한 관리

### 실습 1: 프로젝트 권한 구조 설정

```bash
cd ./bioproject

# 현재 권한 상태 확인
ls -la
ls -la data/

# 디렉토리별 적절한 권한 설정
chmod 755 .                     # 프로젝트 루트: 일반적인 디렉토리 권한
chmod 750 data/                 # 데이터: 그룹만 접근 가능
chmod 700 data/raw/             # 원시 데이터: 소유자만 접근
chmod 755 scripts/              # 스크립트: 모든 사용자 실행 가능
chmod 755 results/ docs/        # 결과와 문서: 공유 가능

# 권한 설정 확인
ls -la
```

### 실습 2: 파일별 보안 등급 적용

```bash
cd ./bioproject/data/raw

# 민감한 데이터 보호
chmod 600 metadata.csv          # 메타데이터: 소유자만 읽기/쓰기

# 서열 데이터 공유 설정
chmod 644 sequences.fasta       # FASTA: 모든 사용자 읽기 가능

# 백업 파일 보호
chmod 600 ../backup/* 2>/dev/null || echo "백업 파일 없음"

# 권한 확인
echo "=== 파일 권한 현황 ==="
ls -la | awk '{print $1, $9}'
```

### 실습 3: 심볼릭 링크 활용

```bash
cd ./bioproject

# 자주 사용하는 파일에 대한 바로가기 생성
ln -s data/raw/sequences.fasta current_data
ln -s data/raw/metadata.csv current_metadata

# 최신 결과 링크 (분석 결과 업데이트 시 유용)
mkdir -p results/$(date +%Y%m%d)
echo "분석 결과 예시" > results/$(date +%Y%m%d)/analysis_v1.txt
ln -s results/$(date +%Y%m%d)/analysis_v1.txt latest_results

# 링크 확인
ls -la | grep "^l"
readlink current_data
```

### 실습 4: 파일 검색 연습

```bash
# 프로젝트 내 파일 검색

# 1. 모든 데이터 파일 찾기
find . -name "*.fasta" -o -name "*.csv"

# 2. 실행 가능 파일
find . -type f -perm /u+x

# 3. 읽기 전용 파일
find . -type f -perm 444
```

## 핵심 정리

### 권한 설정 모범 사례

```bash
# 일반적인 권한 패턴
chmod 755 directories/        # 디렉토리: rwxr-xr-x
chmod 644 data_files          # 데이터 파일: rw-r--r--
chmod 755 executable_scripts  # 실행 스크립트: rwxr-xr-x
chmod 600 private_files       # 개인 파일: rw-------

# 보안 검사
find . -perm -002 -type f      # 모든 사용자 쓰기 가능한 파일 찾기
find . -perm 777               # 모든 권한이 열린 파일/디렉토리
```

### 자주 사용하는 검색 패턴

```bash
# 연구 데이터 관리용 검색
find . -name "*.fasta" -exec ls -lh {} \;     # FASTA 파일 크기 확인
find . -type f -size +100M                    # 대용량 파일 찾기
find . -mtime +30 -name "*.log"               # 오래된 로그 파일
find . -empty -type f -delete                 # 빈 파일 정리
```

---

**다음**: [1.3 Process Management](./ch01-3-process-management.md)
