# Convention

## Coding Convention

<br>

| 항목 | 규칙 |
| --- | --- |
| 들여쓰기 | 2 spaces 사용 |
| 네이밍 | Type: UpperCamelCase / 변수·함수: lowerCamelCase |
| Bool 네이밍 | `is`, `has`, `can` prefix 사용 |
| 함수명 | 동사로 시작 (`fetch`, `update` 등) |
| 줄 길이 | 100자 이하 |
| import | 알파벳 순 정렬 |
| 클래스 | 상속 없으면 `final` 사용 |
| 데이터 모델 | `struct` 우선 사용 |
| Extension | 기능 단위로 분리 |
| 주석 | 필요한 경우만 작성 |

---

### 네이밍 규칙

```swift
// Type
struct UserProfile { }
final class HomeViewController { }

// Variable / Function
let userName = "soeun"
func fetchUser() { }
```

---

### 함수 네이밍

```swift

// 권장
func fetchUser()
func updateProfile()
```

---

### Bool 네이밍

```swift
let isHidden = true
let hasToken = false
let canEdit = true
```

---

### 배열 네이밍

```swift
let users: [User]
let cards: [Card]
let sections: [Section]
```

---

### Protocol

```swift
protocol UserRepository { }
protocol Cancelable { }
```

---

### Class & Struct

```swift
final class HomeViewController { }

struct User {
  let id: Int
  let name: String
}
```

---

### 함수 분리

```swift
private func configureUI() { }
private func setLayout() { }
private func bind() { }
```

---

### Extension

```swift
extension HomeViewController: UITableViewDelegate { }
```

---

### Comment

```swift
// TODO: API 명세 확정 후 수정
```
## Commit Convention

<br>

| 태그 | 설명 |
| --- | --- |
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `refactor` | 코드 리팩토링 (기능 변화 없음) |
| `design` | UI 디자인 변경 |
| `docs` | 문서 수정 |
| `chore` | 빌드, 설정, 기타 작업 |
| `settings` | 프로젝트 설정 변경 |
| `test` | 테스트 코드 추가 및 수정 |
| `hotfix` | 긴급 버그 수정 |
| `merge` | 브랜치 병합 |

---

### 작성 규칙

- 형식: `[type] subject`
- 영어로 작성
- 현재형 사용 (add, fix, update)
- 첫 글자 소문자
- 마침표 사용 금지

---

### 예시

```bash
[feat] add login API
[fix] resolve crash on home screen
```

# Foldering
