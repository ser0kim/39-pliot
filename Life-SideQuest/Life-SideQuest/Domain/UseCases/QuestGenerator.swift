// Created by 김세령.
import Foundation

/// 행동별로 검토한 대상과 조건만 조합한다. 조합 키는 문구와 무관하게 유지한다.
struct QuestGenerator {
    private struct Target {
        let id: String
        let name: String
        let place: QuestPlace
    }
    private struct Condition {
        let id: String
        let title: String
        let instruction: String
        let minutes: Int
    }
    private struct Action {
        let id: String
        let category: QuestCategory
        let title: String
        let verb: String
        let photoPrefix: String
        let targets: [Target]
        let conditions: [Condition]
    }

    /// 매번 문구를 임의로 섞지 않고, 호환 가능한 조합 공간을 만든 후 무작위로 선택한다.
    static func variants() -> [Quest] {
        var result: [Quest] = []
        for action in actions {
            for target in action.targets {
                for condition in action.conditions {
                    let reward = condition.minutes <= 5 ? 10 : condition.minutes <= 10 ? 20 : 30
                    result.append(Quest(
                        id: "mix-v1:\(action.id):\(target.id):\(condition.id)",
                        number: 1001 + result.count,
                        category: action.category,
                        title: "\(target.name) \(action.title) · \(condition.title)",
                        summary: "\(target.name)에서 시작하는 작은 \(action.category.rawValue).",
                        story: "\(target.name)에 잠시 시선을 머물러보세요.\n\(condition.instruction)",
                        place: target.place,
                        minutes: condition.minutes,
                        reward: reward,
                        steps: ["\(target.name)\(objectParticle(target.name)) \(action.verb)", condition.instruction, "모험을 마친 모습을 사진 한 장으로 남겨요."],
                        requirement: "\(action.photoPrefix) \(target.name) 사진 한 장 남기기"
                    ))
                }
            }
        }
        return result
    }

    private static func objectParticle(_ text: String) -> String {
        guard let last = text.unicodeScalars.last, (0xAC00...0xD7A3).contains(last.value) else { return "를" }
        return (last.value - 0xAC00) % 28 == 0 ? "를" : "을"
    }

    private static let actions: [Action] = [
        Action(id: "tidy", category: .conquest, title: "정돈 작전", verb: "정리할 대상으로 골라요.", photoPrefix: "정돈한", targets: [
            Target(id: "desk", name: "책상 한 구역", place: .home),
            Target(id: "drawer", name: "서랍 한 칸", place: .home),
            Target(id: "shelf", name: "책장 한 칸", place: .home),
            Target(id: "bag", name: "가방 속", place: .anywhere),
            Target(id: "shoes", name: "신발장 한 칸", place: .home),
            Target(id: "table", name: "식탁 한 구역", place: .home)
        ], conditions: [
            Condition(id: "one", title: "작은 한 곳", instruction: "작은 한 곳만 골라 물건을 가지런히 놓아요.", minutes: 5),
            Condition(id: "three", title: "물건 세 개", instruction: "물건 세 개를 골라 제자리를 찾아줘요.", minutes: 10),
            Condition(id: "sort", title: "종류별로", instruction: "작은 구역 안의 물건을 종류별로 모아 정리해요.", minutes: 20),
            Condition(id: "space", title: "여백 만들기", instruction: "작은 구역을 정돈하고 빈 공간을 하나 만들어요.", minutes: 30)
        ]),
        Action(id: "walk", category: .exploration, title: "탐사", verb: "안전한 산책 목적지로 골라요.", photoPrefix: "산책 중 발견한", targets: [
            Target(id: "park", name: "가까운 공원", place: .outside),
            Target(id: "trail", name: "동네 산책로", place: .outside),
            Target(id: "alley", name: "익숙한 골목", place: .outside),
            Target(id: "street", name: "집 근처 길", place: .outside),
            Target(id: "square", name: "동네 광장", place: .outside),
            Target(id: "rest", name: "가까운 쉼터", place: .outside)
        ], conditions: [
            Condition(id: "pause", title: "잠깐의 쉼", instruction: "가까운 곳을 잠시 걸으며 쉬고 싶은 풍경을 찾아요.", minutes: 5),
            Condition(id: "new", title: "새로운 시선", instruction: "안전하게 걸으며 평소 지나쳤던 풍경 하나를 발견해요.", minutes: 10),
            Condition(id: "detail", title: "세 가지 발견", instruction: "안전한 길을 걸으며 눈에 들어오는 풍경 세 가지를 찾아요.", minutes: 20),
            Condition(id: "slow", title: "천천히 한 바퀴", instruction: "안전한 구간을 정해 천천히 돌아보고 기억할 풍경을 골라요.", minutes: 30)
        ]),
        Action(id: "observe", category: .discovery, title: "발견 기록", verb: "천천히 관찰할 대상으로 골라요.", photoPrefix: "관찰한", targets: [
            Target(id: "objects", name: "주변 사물", place: .anywhere),
            Target(id: "tools", name: "생활 도구", place: .anywhere),
            Target(id: "props", name: "일상 소품", place: .anywhere),
            Target(id: "home", name: "집 안의 물건", place: .home),
            Target(id: "building", name: "동네 건물", place: .outside),
            Target(id: "scenery", name: "길가 풍경", place: .outside)
        ], conditions: [
            Condition(id: "color", title: "하나의 색", instruction: "마음에 드는 색 하나를 찾아 자세히 바라봐요.", minutes: 5),
            Condition(id: "shape", title: "닮은 모양", instruction: "무언가를 닮은 모양을 하나 찾아봐요.", minutes: 10),
            Condition(id: "pattern", title: "숨은 무늬", instruction: "반복되는 선이나 작은 무늬를 찾아 관찰해요.", minutes: 20),
            Condition(id: "light", title: "빛과 그림자", instruction: "빛이 닿는 부분과 그림자가 생긴 부분을 천천히 살펴봐요.", minutes: 30)
        ]),
        Action(id: "appreciate", category: .taste, title: "취향 수집", verb: "오늘의 취향으로 골라요.", photoPrefix: "취향을 발견한", targets: [
            Target(id: "treasure", name: "아끼는 물건", place: .anywhere),
            Target(id: "prop", name: "마음에 드는 소품", place: .anywhere),
            Target(id: "color", name: "좋아하는 색의 물건", place: .anywhere),
            Target(id: "book", name: "좋아하는 책", place: .anywhere),
            Target(id: "small", name: "오늘의 작은 물건", place: .anywhere),
            Target(id: "daily", name: "손이 자주 가는 물건", place: .anywhere)
        ], conditions: [
            Condition(id: "reason", title: "좋아하는 이유", instruction: "이 물건을 좋아하는 이유 하나를 떠올려요.", minutes: 5),
            Condition(id: "angle", title: "다른 각도", instruction: "평소와 다른 각도에서 바라보고 마음에 드는 모습을 찾아요.", minutes: 10),
            Condition(id: "detail", title: "작은 디테일", instruction: "작은 디테일 세 가지를 천천히 살펴보고 하나를 골라요.", minutes: 20),
            Condition(id: "memory", title: "담긴 추억", instruction: "물건에 담긴 추억을 떠올리며 마음에 드는 장면을 남겨요.", minutes: 30)
        ])
    ]
}
