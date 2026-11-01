// Created by 김세령.
import Foundation

struct SeededQuestRandom: RandomNumberGenerator {
    var value: UInt64
    mutating func next() -> UInt64 {
        value &+= 0x9E3779B97F4A7C15
        var result = value
        result = (result ^ (result >> 30)) &* 0xBF58476D1CE4E5B9
        result = (result ^ (result >> 27)) &* 0x94D049BB133111EB
        return result ^ (result >> 31)
    }
}

@MainActor enum QuestGenerationTests {
    static func run() throws -> Int {
        var checks = 0
        func check(_ condition: @autoclosure () -> Bool, _ label: String) {
            precondition(condition(), label); checks += 1
        }
        let variants = QuestGenerator.variants()
        let catalog = try LocalQuestRepository().quests()
        let now = Date(timeIntervalSince1970: 1_793_473_300)
        check(variants.count == 96 && Set(variants.map(\.id)).count == 96, "96 unique semantic combinations")
        check(Set(variants.map(\.number)).count == variants.count && Set(variants.map(\.title)).count == variants.count, "unique labels")
        check(Set(variants.map(\.category)).count == 4, "all categories")
        for quest in variants {
            let parts = quest.id.split(separator: ":")
            check(parts.count == 4 && parts[0] == "mix-v1", "stable versioned action-target-condition ID")
            check(!quest.title.isEmpty && !quest.summary.isEmpty && !quest.story.isEmpty && quest.steps.count == 3 && quest.requirement.contains("사진 한 장"), "complete generated quest")
            check(!quest.steps.joined().contains("(를)"), "no unresolved Korean particles")
            check([5, 10, 20, 30].contains(quest.minutes) && quest.reward == (quest.minutes <= 5 ? 10 : quest.minutes <= 10 ? 20 : 30), "time and reward agree")
            if quest.category == .exploration { check(quest.place == .outside, "walks never at home") }
            if quest.category == .conquest { check(quest.place != .outside, "tidying compatible targets") }
        }
        var rng = SeededQuestRandom(value: 42)
        var state = AdventureState()
        state.adventurer = Adventurer(name: "세령", handle: "test")
        AdventureRules.prepareRecommendations(&state, quests: catalog, using: &rng)
        check(state.boardQuests?.count == 3 && Set(state.recommendedIDs).count == 3, "initial board")
        let initial = state
        AdventureRules.prepareRecommendations(&state, quests: catalog, using: &rng)
        check(state == initial, "render and reload do not shuffle stable board")
        for _ in 0..<30 {
            let previous = Set(state.recommendedIDs)
            let recent = Set(state.recentQuestIDs ?? [])
            try AdventureRules.reroll(&state, quests: catalog, now: now, using: &rng)
            check(state.recommendedIDs.count == 3 && Set(state.recommendedIDs).isDisjoint(with: previous), "all three replaced")
            check(Set(state.recommendedIDs).isDisjoint(with: recent), "recent exposure avoided when possible")
        }
        check(state.recentQuestIDs?.count == 24 && Set(state.recentQuestIDs ?? []).count == 24, "bounded persisted recent history")
        for place in QuestPlace.allCases {
            for minutes in [5, 10, 30] {
                var filtered = AdventureState()
                filtered.filter = QuestFilter(place: place, maximumMinutes: minutes)
                AdventureRules.prepareRecommendations(&filtered, quests: catalog, using: &rng)
                check(filtered.boardQuests?.count == 3, "enough compatible variants")
                check(filtered.boardQuests!.allSatisfy { $0.minutes <= minutes && (place == .anywhere || $0.place == .anywhere || $0.place == place) }, "place and time filters respected")
            }
        }
        var generatedState = AdventureState()
        generatedState.adventurer = Adventurer(name: "세령", handle: "test", totalExperience: 90)
        let quest = variants[0]
        try AdventureRules.accept(quest, state: &generatedState, now: now)
        generatedState.activeQuest?.photo = Data([1, 2, 3])
        let acceptance = generatedState.activeQuest!.acceptanceID
        let record = try AdventureRules.complete(&generatedState, acceptanceID: acceptance, now: now)
        check(record.quest == quest && record.achievedLevel == 2, "generated quest completed with original reward")
        AdventureRules.prepareRecommendations(&generatedState, quests: catalog, using: &rng)
        check(!generatedState.recommendedIDs.contains(quest.id), "completed semantic combination excluded")
        let activeQuest = variants[5]
        try AdventureRules.accept(activeQuest, state: &generatedState, now: now)
        try AdventureRules.reroll(&generatedState, quests: catalog, now: now, using: &rng)
        check(!generatedState.recommendedIDs.contains(activeQuest.id) && generatedState.activeQuest?.quest == activeQuest, "reroll preserves and excludes active quest")
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let repository = LocalAdventureRepository(directory: directory)
        try repository.save(generatedState)
        let restored = try repository.load()
        check(restored == generatedState, "full board history active and completed snapshot roundtrip")
        let restoredSession = AdventureSession(repository: repository, catalog: LocalQuestRepository())
        check(restoredSession.state == generatedState && restoredSession.quest(id: generatedState.recommendedIDs[0]) == generatedState.boardQuests?[0], "detail uses restored board snapshot")
        var snapshot = initial
        AdventureRules.prepareRecommendations(&snapshot, quests: [], using: &rng)
        check(snapshot.boardQuests == initial.boardQuests, "old snapshot survives catalog retirement")
        var legacy = AdventureState()
        legacy.recommendedIDs = ["desk", "alley", "faces"]
        let encoded = try JSONEncoder().encode(legacy)
        var legacyJSON = try JSONSerialization.jsonObject(with: encoded) as! [String: Any]
        legacyJSON.removeValue(forKey: "boardQuests"); legacyJSON.removeValue(forKey: "recentQuestIDs")
        let oldData = try JSONSerialization.data(withJSONObject: legacyJSON)
        var migrated = try JSONDecoder().decode(AdventureState.self, from: oldData)
        AdventureRules.prepareRecommendations(&migrated, quests: catalog, using: &rng)
        check(migrated.recommendedIDs == legacy.recommendedIDs && migrated.boardQuests?.count == 3, "old JSON decodes and pins old recommendations")
        var tiny = AdventureState()
        AdventureRules.prepareRecommendations(&tiny, quests: Array(variants.prefix(4)), using: &rng)
        let unchanged = tiny
        do { try AdventureRules.reroll(&tiny, quests: Array(variants.prefix(4)), now: now, using: &rng); preconditionFailure("not enough new candidates") } catch { check(tiny == unchanged, "insufficient candidates do not charge or partially replace") }
        var crowded = AdventureState()
        crowded.recentQuestIDs = variants.prefix(6).map(\.id)
        AdventureRules.prepareRecommendations(&crowded, quests: Array(variants.prefix(6)), using: &rng)
        check(Set(crowded.recommendedIDs) == Set(variants.prefix(3).map(\.id)), "only oldest recent candidates relaxed when necessary")
        let failing = FailingRepository(state: initial)
        let failedSession = AdventureSession(repository: failing, catalog: LocalQuestRepository())
        check(failedSession.loaded && !failedSession.update { try AdventureRules.reroll(&$0, quests: catalog, now: now) } && failedSession.state == initial, "failed reroll save preserves board and history")
        var deterministicA = AdventureState(), deterministicB = AdventureState()
        var seedA = SeededQuestRandom(value: 7), seedB = SeededQuestRandom(value: 7)
        AdventureRules.prepareRecommendations(&deterministicA, quests: variants, using: &seedA)
        AdventureRules.prepareRecommendations(&deterministicB, quests: variants, using: &seedB)
        check(deterministicA == deterministicB, "injected RNG makes regression reproducible")
        var observed = Set<String>()
        for seed in 0..<16 {
            var sample = AdventureState(), random = SeededQuestRandom(value: UInt64(seed))
            AdventureRules.prepareRecommendations(&sample, quests: variants, using: &random)
            observed.formUnion(sample.recommendedIDs)
        }
        check(observed.count > 12, "different seeds select across composition space")
        return checks
    }
}
