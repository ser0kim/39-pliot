// Created by 김세령.
import Foundation

@MainActor
protocol AdventureRepository {
    func load() throws -> AdventureState
    func save(_ state: AdventureState) throws
}

@MainActor
protocol QuestRepository {
    func quests() throws -> [Quest]
}
