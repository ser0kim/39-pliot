// Created by 김세령.
import SwiftUI

struct BoardView: View {
    @State var model: BoardViewModel
    let openQuest: (Quest) -> Void
    let writeRecord: (ActiveQuest) -> Void
    @State private var showFilter = false
    @State private var showCancel = false
    @State private var filter = QuestFilter()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("의뢰 게시판").screenTitle()
                if let person = model.session.state.adventurer {
                    ExperienceBar(name: person.name, level: GrowthPolicy().level(person.totalExperience), experience: GrowthPolicy().progress(person.totalExperience), required: 100)
                }
                if let active = model.session.state.activeQuest {
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("진행 중인 의뢰").font(GuildTheme.font(10, weight: .semibold))
                            Text(active.quest.title).font(GuildTheme.font(18, weight: .semibold))
                        }
                        GuildButton(title: "완료 기록하기", secondary: true) { writeRecord(active) }
                        Button("의뢰 취소") { showCancel = true }.font(GuildTheme.font(11)).frame(maxWidth: .infinity, minHeight: 32)
                    }.guildPanel(color: GuildTheme.green)
                }
                HStack(spacing: 8) {
                    GuildChip(title: model.session.state.filter.place == .anywhere ? "장소 무관" : model.session.state.filter.place.rawValue)
                    GuildChip(title: model.session.state.filter.maximumMinutes.map { "\($0)분 이내" } ?? "시간 무관")
                    Button { filter = model.session.state.filter; showFilter = true } label: { GuildChip(title: "조건 설정", selected: true) }.buttonStyle(.plain)
                }
                Text(model.session.state.activeQuest == nil ? "길드에서 도착한 오늘의 의뢰" : "오늘, 어떤 모험을 해볼까요?").font(GuildTheme.font(14, weight: .semibold)).padding(.top, 3)
                LazyVStack(spacing: 18) {
                    ForEach(model.recommendations) { quest in
                        Button { openQuest(quest) } label: { QuestCard(quest: quest) }.buttonStyle(.plain)
                    }
                }
                if model.recommendations.isEmpty { GuildEmptyState(title: "새로운 의뢰를 기다리는 중", message: "조건을 바꾸거나 다른 모험을 찾아보세요.") }
                GuildButton(title: "다른 의뢰 보기", secondary: true) { model.reroll() }
            }.padding(24)
        }.guildScreen()
            .overlay { if showFilter { filterDialog } }
            .overlay { if showCancel { cancelDialog } }
    }
    private var filterDialog: some View {
        GuildDialog(dismiss: { showFilter = false }) {
            HStack { Text("모험 조건 설정").font(GuildTheme.font(21, weight: .semibold)); Spacer(); Button { showFilter = false } label: { GuildIcon(name: "close") }.accessibilityLabel("닫기") }
            Text("지금 할 수 있는 의뢰를 찾아볼게요.").font(GuildTheme.font(12)).foregroundStyle(GuildTheme.muted)
            Text("어디에서 모험할까요?").font(GuildTheme.font(13, weight: .semibold))
            Picker("장소", selection: $filter.place) {
                Text("장소 무관").tag(QuestPlace.anywhere); Text("집").tag(QuestPlace.home); Text("밖").tag(QuestPlace.outside)
            }.pickerStyle(.segmented)
            Text("얼마나 여유가 있나요?").font(GuildTheme.font(13, weight: .semibold))
            Picker("시간", selection: $filter.maximumMinutes) {
                Text("시간 무관").tag(nil as Int?); Text("10분 이내").tag(10 as Int?); Text("30분 이내").tag(30 as Int?)
            }.pickerStyle(.segmented)
            HStack {
                GuildButton(title: "초기화", secondary: true) { filter = QuestFilter() }
                GuildButton(title: "의뢰 찾아보기") { if model.apply(filter) { showFilter = false } }
            }
        }
    }
    private var cancelDialog: some View {
        GuildDialog(dismiss: { showCancel = false }) {
            GuildIcon(name: "cancel", size: 28)
            Text("의뢰를 내려놓을까요?").font(GuildTheme.font(21, weight: .semibold))
            Text("취소해도 경험치는 줄지 않아요.\n작성 중인 사진과 한마디는 사라져요.").font(GuildTheme.font(13)).foregroundStyle(GuildTheme.muted)
            GuildButton(title: "의뢰 취소하기") { if model.cancel() { showCancel = false } }
            GuildButton(title: "계속 도전하기", secondary: true) { showCancel = false }
        }
    }
}

struct GuildDialog<Content: View>: View {
    let dismiss: () -> Void
    @ViewBuilder let content: () -> Content
    var body: some View {
        ZStack {
            Color.black.opacity(0.66).ignoresSafeArea().onTapGesture(perform: dismiss).accessibilityLabel("팝업 닫기").accessibilityAddTraits(.isButton)
            VStack(alignment: .leading, spacing: 16, content: content).guildPanel(radius: 16, padding: 20).padding(24)
                .accessibilityAddTraits(.isModal)
        }
    }
}
