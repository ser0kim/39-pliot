// Created by 김세령.
import SwiftUI

struct ProfileView: View {
    @State var model: ProfileViewModel
    @State private var showRename = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("모험가증").screenTitle()
                if let person = model.session.state.adventurer {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            GuildIcon(name: "medal", size: 48).padding(8).background(GuildTheme.sage, in: Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(model.title).font(GuildTheme.font(11))
                                Text("\(person.name) 모험가").font(GuildTheme.font(26, weight: .semibold))
                            }
                        }
                        HStack { Text("ADVENTURER ID"); Spacer(); Text(person.handle) }.font(GuildTheme.font(12))
                        HStack { Text("Lv.\(GrowthPolicy().level(person.totalExperience))").font(GuildTheme.font(23, weight: .bold)); Spacer(); Text("\(GrowthPolicy().progress(person.totalExperience)) / 100 EXP").font(GuildTheme.font(12)).foregroundStyle(GuildTheme.experience) }
                        ProgressView(value: Double(GrowthPolicy().progress(person.totalExperience)), total: 100).tint(GuildTheme.muted)
                    }.guildPanel(color: GuildTheme.green, padding: 20)
                }
                VStack(alignment: .leading, spacing: 8) {
                    HStack { Text("완료한 의뢰").font(GuildTheme.font(14, weight: .semibold)); Spacer(); Text("\(model.session.state.records.count)개").font(GuildTheme.font(23, weight: .bold)) }.foregroundStyle(GuildTheme.gold)
                    Rectangle().fill(GuildTheme.line).frame(height: 1)
                    Text(QuestCategory.allCases.map { "\($0.rawValue) \(model.count($0))" }.joined(separator: "    ")).font(GuildTheme.font(11)).foregroundStyle(GuildTheme.muted)
                }.guildPanel()
                Text("수집한 칭호").font(GuildTheme.font(15, weight: .semibold)).padding(.top, 3)
                VStack(alignment: .leading, spacing: 8) {
                    Text("✦ \(model.title)  ·  대표").font(GuildTheme.font(16, weight: .semibold)).foregroundStyle(GuildTheme.gold)
                    Text(model.session.state.records.count >= 5 ? "✦ 꾸준한 모험가" : "꾸준한 모험가 · \(5 - model.session.state.records.count)회 더 완료하면 획득").font(GuildTheme.font(12))
                    Text(model.count(.exploration) >= 5 ? "✦ 동네 탐험가" : "동네 탐험가 · 탐험 \(5 - model.count(.exploration))회 더 완료하면 획득").font(GuildTheme.font(11)).foregroundStyle(GuildTheme.muted)
                }.frame(maxWidth: .infinity, alignment: .leading).guildPanel()
                GuildButton(title: "모험가 이름 변경", secondary: true) { model.name = model.session.state.adventurer?.name ?? ""; showRename = true }
                Text("기록은 이 기기에 보관돼요.\n앱을 삭제하면 기록이 사라질 수 있어요.").helper()
            }.padding(24)
        }.guildScreen().overlay {
            if showRename {
                GuildDialog(dismiss: { showRename = false }) {
                    Text("새 이름으로 모험하기").font(GuildTheme.font(21, weight: .semibold))
                    Text("과거 완료증에는 당시 이름이 남아요.").helper()
                    GuildField(title: "새 이름", hint: "1~10자", text: $model.name)
                    GuildButton(title: "이름 저장", isEnabled: model.validName) { if model.rename() { showRename = false } }
                    GuildButton(title: "취소", secondary: true) { showRename = false }
                }
            }
        }
    }
}
