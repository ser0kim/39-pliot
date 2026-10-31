import SwiftUI

struct GuildButton: View {
    let title: String
    var secondary = false
    var isEnabled = true
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(GuildTheme.font(14, weight: .semibold))
                .foregroundStyle(GuildTheme.white).frame(maxWidth: .infinity, minHeight: 54)
                .background(secondary ? GuildTheme.card : GuildTheme.green, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(secondary ? GuildTheme.line : .clear))
                .opacity(isEnabled ? 1 : 0.45)
                .contentShape(Rectangle())
        }.buttonStyle(.plain).disabled(!isEnabled)
    }
}

struct GuildIcon: View {
    let name: String
    var size: CGFloat = 22
    var body: some View {
        Image("guild-\(name)").resizable().scaledToFit().frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

struct GuildChip: View {
    let title: String
    var selected = false
    var reward = false
    var body: some View {
        Text(title).font(GuildTheme.font(12, weight: .semibold))
            .foregroundStyle(reward ? GuildTheme.experience : selected ? GuildTheme.white : GuildTheme.muted)
            .padding(.horizontal, 15).padding(.vertical, 9).frame(maxWidth: .infinity)
            .background(selected ? GuildTheme.green : GuildTheme.card, in: Capsule())
            .overlay(Capsule().strokeBorder(reward ? GuildTheme.experience : .clear))
    }
}

struct GuildField: View {
    let title: String
    let hint: String
    @Binding var text: String
    var identifier = false
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(GuildTheme.font(13, weight: .semibold))
            TextField(hint, text: $text).font(GuildTheme.font(identifier ? 15 : 17, weight: identifier ? .regular : .semibold))
                .textInputAutocapitalization(identifier ? .never : .words).autocorrectionDisabled(identifier)
                .padding(14).frame(minHeight: 54).background(GuildTheme.card, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(GuildTheme.line))
                .accessibilityLabel(title)
        }
    }
}

struct ExperienceBar: View {
    let name: String
    let level: Int
    let experience: Int
    let required: Int
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Lv.\(level)  \(name) 모험가").foregroundStyle(GuildTheme.muted)
                Spacer(minLength: 4)
                Text("\(experience) / \(required) EXP").foregroundStyle(GuildTheme.experience)
            }.font(GuildTheme.font(12))
            ProgressView(value: Double(experience), total: Double(max(required, 1))).tint(GuildTheme.green)
                .accessibilityLabel("경험치").accessibilityValue("\(experience) / \(required)")
        }.guildPanel(color: GuildTheme.sage, padding: 10)
    }
}

struct QuestCard: View {
    let quest: Quest
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(String(format: "%02d  /  %@ 의뢰", quest.number, quest.category.rawValue))
                    .font(GuildTheme.font(10, weight: .bold)).foregroundStyle(GuildTheme.gold)
                Spacer()
                GuildIcon(name: quest.category.icon, size: 18)
            }
            Text(quest.title).font(GuildTheme.font(17, weight: .bold)).padding(.vertical, 1)
            Text(quest.summary).font(GuildTheme.font(11)).foregroundStyle(GuildTheme.muted).fixedSize(horizontal: false, vertical: true)
            HStack {
                Text("\(quest.place.rawValue)  ·  \(quest.minutes)분").foregroundStyle(GuildTheme.muted)
                Spacer()
                Text("+\(quest.reward) EXP").fontWeight(.bold).foregroundStyle(GuildTheme.experience)
            }.font(GuildTheme.font(11)).padding(.top, 1)
        }.frame(maxWidth: .infinity, alignment: .leading).guildPanel(radius: 10, padding: 14)
    }
}

struct AdventurePhoto: View {
    let data: Data?
    var height: CGFloat = 164
    var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                VStack(spacing: 12) {
                    GuildIcon(name: "camera", size: 32)
                    Text("모험의 흔적을 남겨주세요").font(GuildTheme.font(12))
                }.frame(maxWidth: .infinity).background(GuildTheme.sage)
            }
        }.frame(height: height).frame(maxWidth: .infinity).clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8)).accessibilityLabel("모험 인증 사진")
    }
}

struct CertificateCard: View {
    let record: AdventureRecord
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 6) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.quest.category.certificateTitle).font(.system(size: 23, weight: .bold, design: .serif))
                    Text("NO.\(String(format: "%04d", record.number))   ·   \(record.completedAt.formatted(.dateTime.year().month(.twoDigits).day(.twoDigits)))")
                        .font(GuildTheme.font(10)).foregroundStyle(GuildTheme.muted)
                }
                Spacer(minLength: 0)
                Text("\(record.quest.category.rawValue) 완료").font(.system(size: 14, weight: .bold, design: .serif))
                    .tracking(1).foregroundStyle(GuildTheme.stamp).frame(width: 94, height: 35)
                    .background { Image("certificate-stamp").resizable().scaledToFit() }
            }.padding(.bottom, 6)
            AdventurePhoto(data: record.photo)
            Text(record.quest.title).font(GuildTheme.font(17, weight: .bold))
            if !record.note.isEmpty { Text(record.note).font(GuildTheme.font(12)).foregroundStyle(GuildTheme.muted) }
            Rectangle().fill(GuildTheme.line).frame(height: 1)
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("모험가 \(record.adventurerName)").font(GuildTheme.font(12, weight: .bold))
                    Text(record.quest.requirement).font(GuildTheme.font(10)).foregroundStyle(GuildTheme.muted)
                }
                Spacer(minLength: 4)
                Text("+\(record.quest.reward) EXP").font(GuildTheme.font(23, weight: .bold)).foregroundStyle(GuildTheme.experience)
            }
        }.guildPanel(radius: 10, padding: 18)
    }
}

struct GuildEmptyState: View {
    let title: String
    let message: String
    var body: some View {
        VStack(spacing: 12) {
            GuildIcon(name: "book", size: 36)
            Text(title).font(GuildTheme.font(17, weight: .semibold))
            Text(message).font(GuildTheme.font(13)).foregroundStyle(GuildTheme.muted).multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).padding(.vertical, 36).guildPanel()
    }
}
