// Created by 김세령.
import SwiftUI

enum MainTab: String, CaseIterable, Identifiable {
    case board, archive, profile
    var id: Self { self }
    var title: String {
        switch self {
        case .board: "의뢰 게시판"
        case .archive: "모험 도감"
        case .profile: "모험가증"
        }
    }
    var icon: String {
        switch self {
        case .board: "guild-compass"
        case .archive: "guild-book"
        case .profile: "guild-medal"
        }
    }
}

struct MainTabView<Board: View, Archive: View, Profile: View>: View {
    @Binding var selection: MainTab
    @ViewBuilder var board: () -> Board
    @ViewBuilder var archive: () -> Archive
    @ViewBuilder var profile: () -> Profile

    var body: some View {
        TabView(selection: $selection) {
            board().tag(MainTab.board).toolbar(.hidden, for: .tabBar)
            archive().tag(MainTab.archive).toolbar(.hidden, for: .tabBar)
            profile().tag(MainTab.profile).toolbar(.hidden, for: .tabBar)
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CustomTabBar(selection: $selection)
        }
    }
}

private struct CustomTabBar: View {
    @Binding var selection: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases) { tab in
                Button { selection = tab } label: {
                    VStack(spacing: 5) {
                        Image(tab.icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .accessibilityHidden(true)
                        Text(tab.title).font(GuildTheme.font(11, weight: .semibold))
                    }
                    .foregroundStyle(selection == tab ? GuildTheme.gold : GuildTheme.muted)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == tab ? [.isSelected] : [])
                .accessibilityIdentifier("tab-\(tab.rawValue)")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(GuildTheme.card.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) { Rectangle().fill(GuildTheme.line).frame(height: 1) }
    }
}
