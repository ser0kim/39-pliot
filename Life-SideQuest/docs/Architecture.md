# Life SideQuest 개발 구조

기능 기준: [Figma 04 · 화면 설계서](https://www.figma.com/design/DRmxJwkqfFUDIjFuWhI7RE?node-id=15-721).

## 의존 방향

`App → Presentation → Domain ← Data`

- App: 앱 시작, 의존성 조립, 최종 내비게이션 연결.
- Domain: Foundation만 사용하는 엔티티, 저장소 인터페이스, 유스케이스. SwiftUI와 저장 방식에 의존하지 않는다.
- Data: Domain 인터페이스를 구현하는 기기 저장소와 의뢰 카탈로그.
- Presentation: 화면별 View와 ViewModel. View는 렌더링과 사용자 입력, ViewModel은 상태와 유스케이스 실행을 담당한다.
- Presentation/DesignSystem: Figma 흑요석 길드 색상·글꼴·버튼·카드 등 공통 UI.

## 개발 순서

1. 폴더링: 클린 아키텍처와 MVVM 경계, Xcode 프로젝트 등록.
2. 컴포넌트: 디자인 토큰, 버튼, 카드, 필드, 완료증.
3. UI: S01~S08, S02-A 및 O01~O04 화면.
4. 기능: 입력 검증, 의뢰 수락·취소·완료, EXP, 추천, 통계.
5. 데이터: 로컬 영속 저장, 사진, 복원·실패 처리.
6. 네비게이션: 첫 실행 게이트, 탭, 상세, 모달, 완료 후 이동.

각 단계는 별도 브랜치와 PR로 관리한다. 현재 앱은 서버 계정이나 동기화를 제공하지 않는다.
