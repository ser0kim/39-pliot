// Created by 김세령.
import Foundation
import Observation

@MainActor @Observable
final class OnboardingViewModel {
    var name = ""
    var handle = ""
    let session: AdventureSession
    init(session: AdventureSession) { self.session = session }
    var valid: Bool { (try? AdventureRules.name(name)) != nil && (try? AdventureRules.handle(handle)) != nil }
    func register() {
        session.update { $0.adventurer = try Adventurer(name: AdventureRules.name(name), handle: AdventureRules.handle(handle)) }
    }
}

@MainActor @Observable
final class BoardViewModel {
    let session: AdventureSession
    init(session: AdventureSession) { self.session = session }
    var recommendations: [Quest] { AdventureRules.recommendations(session.quests, state: session.state) }
    var remaining: Int { AdventureRules.rerollsRemaining(session.state, now: Date()) }
    func reroll() { session.update { try AdventureRules.reroll(&$0, quests: session.quests, now: Date()) } }
    func apply(_ filter: QuestFilter) -> Bool { session.update { $0.filter = filter; $0.recommendedIDs = [] } }
    func cancel() -> Bool { session.update { $0.activeQuest = nil } }
    func accept(_ quest: Quest) -> Bool { session.update { try AdventureRules.accept(quest, state: &$0, now: Date()) } }
}

@MainActor @Observable
final class RecordViewModel {
    let session: AdventureSession
    let acceptanceID: UUID
    var note: String
    var photo: Data?
    var isLoadingPhoto = false
    init(session: AdventureSession, active: ActiveQuest) {
        self.session = session; acceptanceID = active.acceptanceID; note = active.note; photo = active.photo
    }
    var valid: Bool { photo != nil && note.count <= 100 && !isLoadingPhoto }
    @discardableResult func saveDraft() -> Bool {
        session.update { state in
            guard state.activeQuest?.acceptanceID == acceptanceID else { throw AdventureError.noActiveQuest }
            state.activeQuest?.note = note; state.activeQuest?.photo = photo
        }
    }
    func complete() -> AdventureRecord? {
        var record: AdventureRecord?
        let saved = session.update { state in
            guard state.activeQuest?.acceptanceID == acceptanceID else { throw AdventureError.noActiveQuest }
            state.activeQuest?.note = note; state.activeQuest?.photo = photo
            record = try AdventureRules.complete(&state, acceptanceID: acceptanceID, now: Date())
        }
        return saved ? record : nil
    }
}

@MainActor @Observable
final class ArchiveViewModel {
    let session: AdventureSession
    var category: QuestCategory?
    init(session: AdventureSession) { self.session = session }
    var records: [AdventureRecord] { session.state.records.filter { category == nil || $0.quest.category == category } }
}

@MainActor @Observable
final class ProfileViewModel {
    let session: AdventureSession
    var name = ""
    init(session: AdventureSession) { self.session = session }
    func count(_ category: QuestCategory) -> Int { session.state.records.filter { $0.quest.category == category }.count }
    var validName: Bool { (try? AdventureRules.name(name)) != nil }
    func rename() -> Bool { session.update { $0.adventurer?.name = try AdventureRules.name(name) } }
    var title: String { session.state.records.isEmpty ? "모험을 기다리는 자" : "첫발을 뗀 자" }
}
