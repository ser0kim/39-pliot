// Created by 김세령.
import SwiftUI

struct QuestDetailView: View {
    let quest: Quest
    let accept: () -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(spacing: 4) {
                    GuildIcon(name: quest.category.icon, size: 58)
                    Text("WANTED · 일상의 작은 \(quest.category.rawValue)").font(GuildTheme.font(10, weight: .semibold)).foregroundStyle(GuildTheme.gold)
                }.frame(maxWidth: .infinity).guildPanel(color: GuildTheme.sage, padding: 16)
                Text(String(format: "SUB QUEST  /  %03d  /  %@", quest.number, quest.category.rawValue)).font(GuildTheme.font(10, weight: .semibold)).tracking(1.3).foregroundStyle(GuildTheme.gold)
                Text(quest.title).screenTitle()
                Text(quest.story).font(GuildTheme.font(14)).lineSpacing(5).foregroundStyle(GuildTheme.muted)
                HStack { GuildChip(title: quest.place.rawValue); GuildChip(title: "\(quest.minutes)분"); GuildChip(title: "+\(quest.reward) EXP", reward: true) }
                Rectangle().fill(GuildTheme.line).frame(height: 1)
                HStack { Text("이렇게 해보세요").font(GuildTheme.font(15, weight: .semibold)); Text("Tip!").font(GuildTheme.font(10)).padding(3).background(GuildTheme.gold, in: RoundedRectangle(cornerRadius: 4)).foregroundStyle(GuildTheme.paper) }
                ForEach(Array(quest.steps.enumerated()), id: \.offset) { index, step in Text("\(index + 1). \(step)").font(GuildTheme.font(13)) }
                VStack(alignment: .leading, spacing: 3) {
                    Text("완료 조건").font(GuildTheme.font(12, weight: .semibold)).foregroundStyle(GuildTheme.gold)
                    Text(quest.requirement).font(GuildTheme.font(13))
                }.frame(maxWidth: .infinity, alignment: .leading).guildPanel(padding: 12)
            }.padding(24)
        }.safeAreaInset(edge: .bottom) { GuildButton(title: "의뢰 수락하기", action: accept).padding(24) }
            .navigationTitle("의뢰 상세").navigationBarTitleDisplayMode(.inline).guildScreen()
    }
}
