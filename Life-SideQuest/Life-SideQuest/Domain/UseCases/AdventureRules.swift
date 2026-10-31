// Created by 김세령.
import Foundation

struct GrowthPolicy {
    let requiredExperience = 100
    func level(_ total: Int) -> Int { max(0, total) / requiredExperience + 1 }
    func progress(_ total: Int) -> Int { max(0, total) % requiredExperience }
}

enum AdventureError: LocalizedError {
    case invalidName, invalidHandle, activeQuestExists, noActiveQuest, photoRequired, noteTooLong, noAlternative, rerollLimit, notRegistered
    var errorDescription: String? {
        switch self {
        case .invalidName: "모험가 이름을 1~10자로 입력해주세요."
        case .invalidHandle: "아이디는 영문·숫자·밑줄 1~30자로 입력해주세요."
        case .activeQuestExists: "진행 중인 의뢰를 완료하거나 취소해주세요."
        case .noActiveQuest: "진행 중인 의뢰가 없어요."
        case .photoRequired: "완료 사진을 한 장 남겨주세요."
        case .noteTooLong: "한마디는 100자까지 입력할 수 있어요."
        case .noAlternative: "조건에 맞는 다른 의뢰가 없어요. 조건을 바꿔보세요."
        case .rerollLimit: "오늘의 재추첨을 모두 사용했어요. 내일 다시 만나요."
        case .notRegistered: "모험가 등록을 먼저 완료해주세요."
        }
    }
}

struct AdventureRules {
    static func name(_ value: String) throws -> String {
        let name = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...10).contains(name.count) else { throw AdventureError.invalidName }
        return name
    }
    static func handle(_ value: String) throws -> String {
        let handle = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard handle.range(of: "^[A-Za-z0-9_]{1,30}$", options: .regularExpression) != nil else { throw AdventureError.invalidHandle }
        return handle
    }
    static func candidates(_ quests: [Quest], state: AdventureState) -> [Quest] {
        let completed = Set(state.records.map { $0.quest.id })
        return quests.filter { quest in
            !completed.contains(quest.id) && quest.id != state.activeQuest?.quest.id &&
            (state.filter.place == .anywhere || quest.place == .anywhere || quest.place == state.filter.place) &&
            (state.filter.maximumMinutes.map { quest.minutes <= $0 } ?? true)
        }
    }
    static func recommendations(_ quests: [Quest], state: AdventureState) -> [Quest] {
        let pool = candidates(quests, state: state)
        let saved = state.recommendedIDs.compactMap { id in pool.first { $0.id == id } }
        return Array((saved + pool.filter { !state.recommendedIDs.contains($0.id) }).prefix(3))
    }
    static func rerollsRemaining(_ state: AdventureState, now: Date, calendar: Calendar = .current) -> Int {
        guard let day = state.rerollDate, calendar.isDate(day, inSameDayAs: now) else { return 3 }
        return max(0, 3 - state.rerollsUsed)
    }
    static func reroll(_ state: inout AdventureState, quests: [Quest], now: Date) throws {
        guard rerollsRemaining(state, now: now) > 0 else { throw AdventureError.rerollLimit }
        let current = recommendations(quests, state: state).map(\.id)
        let pool = candidates(quests, state: state)
        guard let alternative = pool.first(where: { !current.contains($0.id) }) else { throw AdventureError.noAlternative }
        state.recommendedIDs = [alternative.id] + Array(current.prefix(2))
        if state.rerollDate.map({ !Calendar.current.isDate($0, inSameDayAs: now) }) ?? true { state.rerollsUsed = 0 }
        state.rerollDate = now
        state.rerollsUsed += 1
    }
    static func accept(_ quest: Quest, state: inout AdventureState, now: Date) throws {
        guard state.adventurer != nil else { throw AdventureError.notRegistered }
        guard state.activeQuest == nil else { throw AdventureError.activeQuestExists }
        state.activeQuest = ActiveQuest(acceptanceID: UUID(), quest: quest, acceptedAt: now)
    }
    static func complete(_ state: inout AdventureState, acceptanceID: UUID, now: Date) throws -> AdventureRecord {
        if let existing = state.records.first(where: { $0.id == acceptanceID }) { return existing }
        guard let active = state.activeQuest, active.acceptanceID == acceptanceID else { throw AdventureError.noActiveQuest }
        guard var adventurer = state.adventurer else { throw AdventureError.notRegistered }
        guard let photo = active.photo, !photo.isEmpty else { throw AdventureError.photoRequired }
        guard active.note.count <= 100 else { throw AdventureError.noteTooLong }
        let growth = GrowthPolicy()
        let previous = growth.level(adventurer.totalExperience)
        adventurer.totalExperience += active.quest.reward
        let record = AdventureRecord(id: acceptanceID, number: (state.records.map(\.number).max() ?? 0) + 1,
            quest: active.quest, adventurerName: adventurer.name, completedAt: now, note: active.note,
            photo: photo, previousLevel: previous, achievedLevel: growth.level(adventurer.totalExperience))
        state.adventurer = adventurer
        state.records.insert(record, at: 0)
        state.activeQuest = nil
        return record
    }
}
