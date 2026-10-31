// Created by 김세령.
import Foundation

enum QuestCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case exploration = "탐험", discovery = "발견", taste = "취향", conquest = "토벌"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .exploration: "compass"
        case .discovery: "star"
        case .taste: "leaf"
        case .conquest: "sword"
        }
    }
    var certificateTitle: String {
        switch self {
        case .exploration: "탐사 보고서"
        case .discovery: "발견 기록서"
        case .taste: "취향 수집서"
        case .conquest: "토벌 확인서"
        }
    }
}

enum QuestPlace: String, Codable, CaseIterable, Identifiable, Sendable {
    case anywhere = "어디서나", home = "집", outside = "밖"
    var id: String { rawValue }
}

struct Quest: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let number: Int
    let category: QuestCategory
    let title: String
    let summary: String
    let story: String
    let place: QuestPlace
    let minutes: Int
    let reward: Int
    let steps: [String]
    let requirement: String
}

struct Adventurer: Codable, Equatable, Sendable {
    var name: String
    let handle: String
    var totalExperience: Int = 0
}

struct ActiveQuest: Codable, Equatable, Sendable {
    let acceptanceID: UUID
    let quest: Quest
    let acceptedAt: Date
    var note: String = ""
    var photo: Data?
}

struct AdventureRecord: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let number: Int
    let quest: Quest
    let adventurerName: String
    let completedAt: Date
    let note: String
    let photo: Data
    let previousLevel: Int
    let achievedLevel: Int
}

struct QuestFilter: Codable, Equatable, Sendable {
    var place: QuestPlace = .anywhere
    var maximumMinutes: Int?
}

struct AdventureState: Codable, Equatable, Sendable {
    var schemaVersion = 1
    var adventurer: Adventurer?
    var activeQuest: ActiveQuest?
    var records: [AdventureRecord] = []
    var filter = QuestFilter()
    var recommendedIDs: [String] = []
    var rerollDate: Date?
    var rerollsUsed = 0
}
