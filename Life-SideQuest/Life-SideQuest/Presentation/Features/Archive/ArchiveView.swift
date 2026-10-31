// Created by 김세령.
import SwiftUI

struct ArchiveView: View {
    @State var model: ArchiveViewModel
    let openRecord: (AdventureRecord) -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("나의 모험 도감").screenTitle()
                Text("평범하지 않았던 순간, \(model.session.state.records.count)개").font(GuildTheme.font(14)).foregroundStyle(GuildTheme.muted)
                HStack(spacing: 6) {
                    categoryButton(nil)
                    ForEach(QuestCategory.allCases) { category in categoryButton(category) }
                }
                if model.records.isEmpty { GuildEmptyState(title: "아직 기록이 없어요", message: "작은 의뢰를 완료하고 첫 모험을 모아보세요.") }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(model.records) { record in
                        Button { openRecord(record) } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                AdventurePhoto(data: record.photo, height: 116)
                                Text(record.quest.title).font(GuildTheme.font(12, weight: .semibold)).fixedSize(horizontal: false, vertical: true)
                                Text("\(record.quest.category.certificateTitle) · \(record.completedAt.formatted(.dateTime.month(.twoDigits).day(.twoDigits)))")
                                    .font(GuildTheme.font(10)).foregroundStyle(GuildTheme.muted)
                            }.frame(maxWidth: .infinity, alignment: .leading).guildPanel(padding: 10)
                        }.buttonStyle(.plain)
                    }
                }
            }.padding(24)
        }.guildScreen()
    }
    private func categoryButton(_ category: QuestCategory?) -> some View {
        Button { model.category = category } label: { Text(category?.rawValue ?? "전체").font(GuildTheme.font(12, weight: .semibold)).frame(maxWidth: .infinity).padding(.vertical, 10).background(model.category == category ? GuildTheme.green : GuildTheme.card, in: Capsule()) }.buttonStyle(.plain)
    }
}
