// Created by 김세령.
import Foundation

@MainActor
final class LocalAdventureRepository: AdventureRepository {
    private let fileURL: URL
    init(directory: URL? = nil) {
        let directory = directory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("LifeSideQuest", isDirectory: true)
        fileURL = directory.appendingPathComponent("adventures-v1.json")
    }
    func load() throws -> AdventureState {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return AdventureState() }
        let state = try JSONDecoder().decode(AdventureState.self, from: Data(contentsOf: fileURL))
        guard state.schemaVersion == 1 else { throw CocoaError(.fileReadCorruptFile) }
        return state
    }
    func save(_ state: AdventureState) throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(state)
        try data.write(to: fileURL, options: [.atomic, .completeFileProtectionUnlessOpen])
    }
}

@MainActor
struct LocalQuestRepository: QuestRepository {
    func quests() throws -> [Quest] {
        [
            Quest(id: "desk", number: 1, category: .conquest, title: "봉인된 책상 해방전", summary: "혼돈에 점령당한 책상 한 구역을 되찾아주세요.", story: "물건에 점령당한 책상을 되찾아주세요.\n작은 한 구역이면 충분해요.", place: .home, minutes: 10, reward: 20, steps: ["정리할 책상 한 구역을 골라요.", "필요 없는 물건을 치우고 제자리를 찾아줘요."], requirement: "정리한 공간 사진 한 장 남기기"),
            Quest(id: "alley", number: 2, category: .exploration, title: "지도 밖의 골목으로", summary: "익숙한 길을 벗어나 새로운 풍경을 발견하세요.", story: "늘 걷던 길에서 한 걸음 벗어나봐요.\n동네에도 아직 만나지 못한 풍경이 있어요.", place: .outside, minutes: 10, reward: 20, steps: ["익숙한 길 옆의 새로운 골목을 골라요.", "안전한 길을 걸으며 눈에 들어온 풍경을 찾아요."], requirement: "새로 만난 골목의 사진 한 장 남기기"),
            Quest(id: "faces", number: 3, category: .discovery, title: "도시에 숨은 얼굴들", summary: "사물 속에 숨어 있는 얼굴 하나를 찾아주세요.", story: "창문, 콘센트, 가방에도 얼굴이 숨어 있어요.\n오늘은 세상을 조금 다르게 바라봐요.", place: .anywhere, minutes: 5, reward: 10, steps: ["주변 사물을 천천히 살펴봐요.", "얼굴처럼 보이는 사물을 하나 찾아요."], requirement: "얼굴을 닮은 사물 사진 한 장 남기기"),
            Quest(id: "song", number: 4, category: .taste, title: "낯선 선율의 수집가", summary: "처음 듣는 노래에 오늘의 풍경을 담아주세요.", story: "평소 듣지 않던 음악을 만나봐요.\n어떤 장면이 떠오르나요?", place: .anywhere, minutes: 5, reward: 10, steps: ["처음 듣는 노래 한 곡을 골라요.", "노래와 어울리는 주변 풍경을 찾아요."], requirement: "노래와 어울리는 풍경 사진 남기기"),
            Quest(id: "sky", number: 5, category: .discovery, title: "하늘의 조각 수집", summary: "고개를 들어 오늘만의 하늘을 발견하세요.", story: "오늘의 구름과 빛은 한 번뿐이에요.", place: .outside, minutes: 5, reward: 10, steps: ["안전한 곳에 멈춰 하늘을 바라봐요.", "마음에 드는 하늘 한 조각을 담아요."], requirement: "오늘의 하늘 사진 한 장 남기기"),
            Quest(id: "shelf", number: 6, category: .conquest, title: "잠든 책장의 재발견", summary: "책장 속 잊힌 책 한 권을 깨워주세요.", story: "오랫동안 펼치지 않은 책을 만나봐요.", place: .home, minutes: 30, reward: 30, steps: ["책장에서 오래된 책 한 권을 골라요.", "마음에 드는 한 쪽을 읽고 주변을 정돈해요."], requirement: "다시 만난 책 사진 한 장 남기기"),
            Quest(id: "color", number: 7, category: .taste, title: "오늘의 색을 찾아서", summary: "지금 마음에 드는 색을 하나 모아보세요.", story: "오늘의 기분을 색으로 표현해봐요.", place: .anywhere, minutes: 10, reward: 20, steps: ["마음에 드는 색을 하나 골라요.", "그 색을 가진 물건이나 풍경을 찾아요."], requirement: "선택한 색이 담긴 사진 남기기"),
            Quest(id: "park", number: 8, category: .exploration, title: "초록빛 쉼터 탐사", summary: "가까운 공원에서 작은 쉼표를 찾아보세요.", story: "가까운 초록빛 공간에서 잠시 쉬어가요.", place: .outside, minutes: 30, reward: 30, steps: ["가까운 공원이나 산책로를 찾아요.", "안전하게 걸으며 쉬고 싶은 자리를 발견해요."], requirement: "발견한 쉼터 사진 한 장 남기기")
        ] + QuestGenerator.variants()
    }
}
