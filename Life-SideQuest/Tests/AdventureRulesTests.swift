// Created by 김세령.
import Foundation

@main struct AdventureRulesTests {
    @MainActor static func main() throws {
        var checks = 0
        func check(_ condition: @autoclosure () -> Bool, _ label: String) {
            precondition(condition(), label); checks += 1
        }
        func rejects(_ label: String, _ operation: () throws -> Void) {
            do { try operation(); preconditionFailure(label) } catch { checks += 1 }
        }
        let quests = try LocalQuestRepository().quests()
        let now = Date(timeIntervalSince1970: 1_793_473_300)
        check(tryName("  세령  ") == "세령", "name trimming")
        rejects("blank name") { _ = try AdventureRules.name("   ") }
        rejects("long name") { _ = try AdventureRules.name(String(repeating: "가", count: 11)) }
        rejects("non-ascii handle") { _ = try AdventureRules.handle("한글") }
        check((try? AdventureRules.name("👨‍👩‍👧‍👦")) != nil, "grapheme count")
        var state = AdventureState()
        state.adventurer = Adventurer(name: "세령", handle: "test_1", totalExperience: 180)
        state.filter = QuestFilter(place: .home, maximumMinutes: 10)
        let filtered = AdventureRules.candidates(quests, state: state)
        check(filtered.contains(where: { $0.id == "desk" }), "inclusive 10 min")
        check(filtered.contains(where: { $0.place == .anywhere }), "anywhere matching home")
        check(!filtered.contains(where: { $0.place == .outside || $0.minutes > 10 }), "combined filter")
        state.filter = QuestFilter()
        state.rerollDate = now; state.rerollsUsed = 3
        for _ in 0..<20 { try AdventureRules.reroll(&state, quests: quests, now: now) }
        check(state.boardQuests?.count == 3, "unlimited rerolls including legacy exhausted quota")
        try AdventureRules.accept(quests[0], state: &state, now: now)
        let acceptance = state.activeQuest!.acceptanceID
        rejects("one active") { try AdventureRules.accept(quests[1], state: &state, now: now) }
        rejects("photo required") { _ = try AdventureRules.complete(&state, acceptanceID: acceptance, now: now) }
        state.activeQuest?.photo = Data([1, 2, 3]); state.activeQuest?.note = String(repeating: "가", count: 101)
        rejects("note limit") { _ = try AdventureRules.complete(&state, acceptanceID: acceptance, now: now) }
        state.activeQuest?.note = "개운해졌다"
        let record = try AdventureRules.complete(&state, acceptanceID: acceptance, now: now)
        check(record.previousLevel == 2 && record.achievedLevel == 3, "level boundary")
        check(state.activeQuest == nil && state.adventurer?.totalExperience == 200, "completion state")
        let duplicate = try AdventureRules.complete(&state, acceptanceID: acceptance, now: now)
        check(record == duplicate && state.records.count == 1 && state.adventurer?.totalExperience == 200, "idempotent reward")
        state.adventurer?.name = "새이름"
        check(state.records[0].adventurerName == "세령", "historical name snapshot")
        check(GrowthPolicy().level(315) == 4 && GrowthPolicy().progress(315) == 15, "overflow exp")
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let repository = LocalAdventureRepository(directory: directory)
        AdventureRules.prepareRecommendations(&state, quests: quests)
        try repository.save(state)
        check(tryEqual(repository, state), "persistent roundtrip")
        let session = AdventureSession(repository: repository, catalog: LocalQuestRepository())
        check(session.loaded && session.state == state, "session restores")
        let failing = FailingRepository(state: state)
        let failed = AdventureSession(repository: failing, catalog: LocalQuestRepository())
        check(!failed.update { $0.adventurer?.name = "실패" } && failed.state == state, "failed write preserves state")
        let path = directory.appendingPathComponent("adventures-v1.json")
        try Data("corrupt".utf8).write(to: path)
        rejects("corrupt file") { _ = try repository.load() }
        check(!AdventureSession(repository: repository, catalog: LocalQuestRepository()).loaded, "corruption blocks overwrite")
        checks += try QuestGenerationTests.run()
        print("PASS: \(checks) domain and persistence checks")
    }
    static func tryName(_ value: String) -> String? { try? AdventureRules.name(value) }
    @MainActor static func tryEqual(_ repository: LocalAdventureRepository, _ state: AdventureState) -> Bool { (try? repository.load()) == state }
}
@MainActor final class FailingRepository: AdventureRepository {
    let state: AdventureState
    init(state: AdventureState) { self.state = state }
    func load() throws -> AdventureState { state }
    func save(_ state: AdventureState) throws { throw CocoaError(.fileWriteUnknown) }
}
