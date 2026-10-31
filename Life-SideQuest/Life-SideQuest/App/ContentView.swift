// Created by 김세령.
import SwiftUI

private enum Route: Hashable { case quest(String), record(UUID), write(UUID) }

struct ContentView: View {
    @State private var session = AdventureSession(repository: LocalAdventureRepository(), catalog: LocalQuestRepository())
    @State private var selectedTab = 0
    @State private var boardPath: [Route] = []
    @State private var archivePath: [Route] = []
    @State private var completedRecord: AdventureRecord?
    var body: some View {
        Group {
            if !session.loaded {
                VStack(spacing: 20) {
                    Text("기록을 불러오지 못했어요").screenTitle()
                    Text("기존 기록은 보존되어 있어요. 잠시 후 다시 시도해주세요.")
                    GuildButton(title: "다시 불러오기") { session.reload() }
                }.padding(24).guildScreen()
            } else if session.state.adventurer == nil {
                OnboardingView(model: OnboardingViewModel(session: session))
            } else {
                TabView(selection: $selectedTab) {
                    NavigationStack(path: $boardPath) {
                        BoardView(model: BoardViewModel(session: session), openQuest: { boardPath.append(.quest($0.id)) }, writeRecord: { boardPath.append(.write($0.acceptanceID)) })
                            .navigationDestination(for: Route.self) { route in destination(route) }
                            .toolbar(.hidden, for: .navigationBar)
                    }.tabItem { Label { Text("의뢰 게시판") } icon: { Image("guild-compass") } }.tag(0)
                    NavigationStack(path: $archivePath) {
                        ArchiveView(model: ArchiveViewModel(session: session), openRecord: { archivePath.append(.record($0.id)) })
                            .navigationDestination(for: Route.self) { route in destination(route) }
                            .toolbar(.hidden, for: .navigationBar)
                    }.tabItem { Label { Text("모험 도감") } icon: { Image("guild-book") } }.tag(1)
                    NavigationStack {
                        ProfileView(model: ProfileViewModel(session: session)).toolbar(.hidden, for: .navigationBar)
                    }.tabItem { Label { Text("모험가증") } icon: { Image("guild-medal") } }.tag(2)
                }.toolbarBackground(GuildTheme.card, for: .tabBar).toolbarBackground(.visible, for: .tabBar)
            }
        }.tint(GuildTheme.gold).preferredColorScheme(.dark)
            .fullScreenCover(item: $completedRecord) { record in
                CertificateView(record: record, newlyCompleted: true, openArchive: {
                    completedRecord = nil; selectedTab = 1; archivePath = [.record(record.id)]
                }, openBoard: { completedRecord = nil; selectedTab = 0; boardPath = [] })
            }
            .alert("모험 안내", isPresented: Binding(get: { session.error != nil && session.loaded }, set: { if !$0 { session.error = nil } })) { Button("확인", role: .cancel) {} } message: { Text(session.error ?? "") }
    }
    @ViewBuilder private func destination(_ route: Route) -> some View {
        switch route {
        case .quest(let id):
            if let quest = session.quests.first(where: { $0.id == id }) {
                QuestDetailView(quest: quest) {
                    if BoardViewModel(session: session).accept(quest) { boardPath = [] }
                }
            }
        case .write(let id):
            if let active = session.state.activeQuest, active.acceptanceID == id {
                RecordView(model: RecordViewModel(session: session, active: active), quest: active.quest) { record in
                    boardPath = []; completedRecord = record
                }
            }
        case .record(let id):
            if let record = session.state.records.first(where: { $0.id == id }) { CertificateView(record: record) }
        }
    }
}
