// Created by 김세령.
import SwiftUI

struct GuildNavigationBar: View {
    let title: String
    var backLabel = "뒤로가기"
    let back: () -> Void
    var saveDraft: (() -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            Button(action: back) {
                GuildIcon(name: "back", size: 24)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(backLabel)
            .accessibilityIdentifier("guild-navigation-back")
            .padding(.leading, -10)
            Text(title)
                .font(GuildTheme.font(17, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
            if let saveDraft {
                Button("임시 저장", action: saveDraft)
                    .font(GuildTheme.font(12, weight: .semibold))
                    .foregroundStyle(GuildTheme.gold)
                    .frame(minHeight: 44)
            }
        }
        .foregroundStyle(GuildTheme.ink)
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(GuildTheme.paper)
    }
}
