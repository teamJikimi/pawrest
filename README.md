# Convention

## issue & Branch & PR Convention
<br>

## Issue Convention

<br>

### 이슈 제목 규칙

- 형식: `[type] subject`
- Commit / PR Convention과 동일하게 작성
---

### 브랜치 네이밍 규칙

- 형식: `type/short-description`
- 소문자 + 하이픈(-) 사용

---

### PR 제목 규칙

- 형식: `[type] subject`
- Commit Convention과 동일하게 작성

---

#### 규칙

- 브랜치와 PR 타입은 반드시 일치시킨다
  - 예: `feat/login-api` → `[feat] add login API`
- 하나의 브랜치는 하나의 기능만 담당한다
- PR은 가능한 작게 나누어 생성한다

## Coding Convention

<br>

| 항목 | 규칙 |
| --- | --- |
| 네이밍 | Type: UpperCamelCase / 변수·함수: lowerCamelCase |
| Bool 네이밍 | `is`, `has`, `can` prefix 사용 |
| 함수명 | 동사로 시작 (`fetch`, `update` 등) |
| 줄 길이 | 100자 이하 |
| import | Apple Framework → Third Party → Internal Module 순으로 작성하고, 각 그룹 내에서는 알파벳 순으로 정렬 |
| 클래스 | class 사용 시 상속이 필요하지 않으면 `final` 사용 |
| 데이터 모델 | `struct` 우선 사용 |
| Extension | 기능 단위로 분리 |
| 주석 | 필요한 경우만 작성 (MARK: - 주석을 제외하고는 최소화 할 것) |

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
struct UserProfileView: View {
    var body: some View {
        Text("UserProfile")
    }
}
```

---

### 함수 분리

```swift
private func reduce(into state: inout State, action: Action) -> Effect<Action> { }
private func makeSectionItems() -> [SectionItem] { }
private func validateNickname(_ nickname: String) -> Bool { }
... 
private func headerView() -> some View { }
private func profileSection() -> some View { }
private func actionButton() -> some View { }
```

---

### Extension

- TCA + SwiftUI에서는 UIKit delegate extension을 사용하지 않는다
- extension은 아래와 같은 경우에만 사용한다

---

#### 1. View 확장 (UI 분리)

```swift
extension HomeView {
    func headerView() -> some View {
        Text("Header")
    }
}
```

---

#### 2. Reducer 내부 Helper

```swift
extension HomeFeature {
    func fetchData() -> Effect<Action> {
        // side effect 처리
    }
}
```

---

#### 3. Entity / DTO 변환

```swift
extension UserResponseDTO {
    var entity: User {
        .init(
            id: id,
            name: name
        )
    }
}
```

---

#### 4. 공통 로직 확장

```swift
extension Date {
    var formatted: String {
        // formatting logic
    }
}
```
---

### MARK 주석 순서
MARK 주석은 파일 성격에 맞게 필요한 항목만 사용

```swift
// MARK: - State

// MARK: - Action

// MARK: - Reducer

// MARK: - Dependency

// MARK: - View

// MARK: - Binding

// MARK: - Effect

// MARK: - Helper
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

# Folder Structure
