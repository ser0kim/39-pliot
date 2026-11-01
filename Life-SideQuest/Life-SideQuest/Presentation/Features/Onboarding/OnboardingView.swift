// Created by 김세령.
import SwiftUI

struct OnboardingView: View {
    @State var model: OnboardingViewModel
    var onRegistered: () -> Void = {}
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 5) {
                    Text("LIFE SIDEQUEST"); Rectangle().frame(width: 24, height: 0.5); Text("ADVENTURER’S GUILD")
                }.font(GuildTheme.font(10, weight: .semibold)).tracking(1).foregroundStyle(GuildTheme.gold)
                Text("평범한 하루에도\n모험은 있다.").font(GuildTheme.font(32, weight: .semibold)).lineSpacing(6)
                Text("작은 의뢰를 수행하고\n나만의 모험 기록을 모아보세요.").font(GuildTheme.font(16)).lineSpacing(6).foregroundStyle(GuildTheme.muted)
                Image("adventure-map").resizable().scaledToFit().accessibilityHidden(true)
                GuildField(title: "길드에 등록할 이름을 알려주세요", hint: "모험가 이름", text: $model.name)
                Text("모험가 이름 · 1~10자 · 나중에 바꿀 수 있어요").helper()
                GuildField(title: "모험가 아이디", hint: "adventurer_01", text: $model.handle, identifier: true)
                Text("영문·숫자·밑줄로 나만의 아이디를 만들어요.").helper()
            }.padding(24)
        }.safeAreaInset(edge: .bottom) {
            GuildButton(title: "모험 시작하기", isEnabled: model.valid) { if model.register() { onRegistered() } }.padding(24)
        }.guildScreen().scrollDismissesKeyboard(.interactively)
    }
}

extension Text {
    func helper() -> some View { self.font(GuildTheme.font(11)).foregroundStyle(GuildTheme.helper).padding(.horizontal, 5) }
    func screenTitle() -> some View { self.font(GuildTheme.font(26, weight: .semibold)).tracking(-0.5).frame(maxWidth: .infinity, alignment: .leading) }
}
