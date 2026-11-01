// Created by 김세령.
import SwiftUI

struct CertificateView: View {
    @Environment(\.dismiss) private var dismiss
    let record: AdventureRecord
    var newlyCompleted = false
    var openArchive: (() -> Void)?
    var openBoard: (() -> Void)?
    @State private var message: String?
    @State private var saving = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if newlyCompleted { Text("작은 모험, 해냈어요!").screenTitle() }
                CertificateCard(record: record)
                if newlyCompleted && record.achievedLevel > record.previousLevel {
                    Text("✦ Lv.\(record.achievedLevel) 달성! 다음 모험도 기대돼요.").font(GuildTheme.font(12, weight: .semibold)).foregroundStyle(GuildTheme.gold).frame(maxWidth: .infinity, alignment: .leading).guildPanel(color: GuildTheme.sage, padding: 10)
                }
                HStack(spacing: 3) { GuildIcon(name: "record", size: 15); Text("\(record.adventurerName) 모험가의 \(record.number)번째 작은 모험").font(GuildTheme.font(10)).foregroundStyle(GuildTheme.gold) }
            }.padding(24)
        }.safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                GuildButton(title: saving ? "저장하는 중…" : "완료증 이미지 저장", isEnabled: !saving) {
                    saving = true
                    Task { defer { saving = false }; do { try await PhotoServices.saveCertificate(record); message = "사진 보관함에 완료증을 저장했어요." } catch { message = error.localizedDescription } }
                }
                if newlyCompleted {
                    HStack {
                        GuildButton(title: "모험 도감 보기", secondary: true) { openArchive?() }
                        GuildButton(title: "게시판으로 돌아가기", secondary: true) { openBoard?() }
                    }
                }
            }.padding(24)
        }.guildScreen()
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                if !newlyCompleted {
                    GuildNavigationBar(title: "모험 기록 #\(String(format: "%04d", record.number))", backLabel: "모험 도감으로 돌아가기", back: { dismiss() })
                }
            }
            .alert("완료증 저장", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) { Button("확인", role: .cancel) {} } message: { Text(message ?? "") }
    }
}
