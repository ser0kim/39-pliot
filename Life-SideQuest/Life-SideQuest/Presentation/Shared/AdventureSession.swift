// Created by 김세령.
import Foundation
import Observation

@MainActor @Observable
final class AdventureSession {
    private(set) var state = AdventureState()
    private(set) var quests: [Quest] = []
    private(set) var loaded = false
    var error: String?
    private let repository: any AdventureRepository
    private let catalog: any QuestRepository
    init(repository: any AdventureRepository, catalog: any QuestRepository) {
        self.repository = repository; self.catalog = catalog
        reload()
    }
    func reload() {
        do { let restored = try repository.load(); let quests = try catalog.quests()
            self.state = restored; self.quests = quests; loaded = true; error = nil
        } catch { loaded = false; self.error = "기록을 불러오지 못했어요. 데이터를 보존하고 있으니 다시 시도해주세요." }
    }
    @discardableResult
    func update(_ change: (inout AdventureState) throws -> Void) -> Bool {
        guard loaded else { return false }
        do { var next = state; try change(&next); try repository.save(next); state = next; return true }
        catch { self.error = (error as? AdventureError)?.errorDescription ?? "저장하지 못했어요. 입력한 내용을 유지했으니 다시 시도해주세요."; return false }
    }
}
