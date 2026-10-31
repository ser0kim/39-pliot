// Created by 김세령.
import SwiftUI
import PhotosUI
import AVFoundation

struct RecordView: View {
    @State var model: RecordViewModel
    let quest: Quest
    let completed: (AdventureRecord) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showSource = false
    @State private var showLibrary = false
    @State private var showCamera = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var message: String?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("오늘의 \(quest.category.rawValue), 어땠나요?").screenTitle()
                Text("\(quest.title)  ·  +\(quest.reward) EXP").font(GuildTheme.font(13)).foregroundStyle(GuildTheme.experience)
                Button { showSource = true } label: {
                    VStack(spacing: 8) {
                        AdventurePhoto(data: model.photo, height: 159)
                        HStack {
                            GuildIcon(name: "camera", size: 18)
                            Text(model.isLoadingPhoto ? "사진을 불러오는 중…" : model.photo == nil ? "인증 사진 한 장 남기기" : "사진 1장 선택됨")
                            Spacer(); Text(model.photo == nil ? "선택" : "교체").padding(7).background(GuildTheme.sage, in: RoundedRectangle(cornerRadius: 8))
                        }.font(GuildTheme.font(12, weight: .semibold))
                    }.guildPanel()
                }.buttonStyle(.plain).disabled(model.isLoadingPhoto)
                Text("모험가의 한마디").font(GuildTheme.font(15, weight: .semibold))
                VStack {
                    TextField("어떤 모험이었나요? (선택)", text: $model.note, axis: .vertical).lineLimit(3...5).font(GuildTheme.font(14))
                    Text("\(model.note.count) / 100").font(GuildTheme.font(11)).foregroundStyle(GuildTheme.muted).frame(maxWidth: .infinity, alignment: .trailing)
                }.guildPanel()
                Text("사진은 모험 도감에 보관돼요.\n한마디는 적지 않아도 괜찮아요.").helper()
            }.padding(24)
        }.safeAreaInset(edge: .bottom) {
            GuildButton(title: "완료증 발급받기", isEnabled: model.valid) { if let record = model.complete() { completed(record) } }.padding(24)
        }.navigationTitle("모험 기록 남기기").navigationBarTitleDisplayMode(.inline).guildScreen()
            .scrollDismissesKeyboard(.interactively)
            .navigationBarBackButtonHidden()
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button { if model.saveDraft() { dismiss() } } label: { GuildIcon(name: "back", size: 24) }.accessibilityLabel("게시판으로 돌아가기") } }
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("임시 저장") { if model.saveDraft() { dismiss() } } } }
            .onChange(of: model.note) { _, value in if value.count > 100 { model.note = String(value.prefix(100)) } }
            .onDisappear { if model.session.state.activeQuest?.acceptanceID == model.acceptanceID { model.saveDraft() } }
            .sheet(isPresented: $showSource, onDismiss: {}) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("모험의 흔적을 남겨주세요").font(GuildTheme.font(21, weight: .semibold))
                    GuildButton(title: "사진 촬영", secondary: true) { showSource = false; Task { await openCamera() } }
                    GuildButton(title: "사진 보관함에서 선택", secondary: true) { showSource = false; showLibrary = true }
                }.padding(24).presentationDetents([.height(250)]).presentationDragIndicator(.visible).presentationBackground(GuildTheme.card).foregroundStyle(GuildTheme.ink)
            }
            .photosPicker(isPresented: $showLibrary, selection: $selectedItem, matching: .images)
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker(selected: { image in setPhoto(image); showCamera = false }, cancel: { showCamera = false }).ignoresSafeArea()
            }
            .task(id: selectedItem) {
                guard let selectedItem else { return }
                model.isLoadingPhoto = true
                defer { model.isLoadingPhoto = false }
                do {
                    guard let data = try await selectedItem.loadTransferable(type: Data.self), let image = UIImage(data: data) else { throw PhotoServices.PhotoError.failed }
                    guard !Task.isCancelled else { return }; setPhoto(image)
                } catch { if !Task.isCancelled { message = "사진을 불러오지 못했어요. 다른 사진을 선택해주세요." } }
            }
            .alert("사진 안내", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) { Button("확인", role: .cancel) {} } message: { Text(message ?? "") }
    }
    private func setPhoto(_ image: UIImage) {
        guard let data = PhotoServices.normalized(image) else { message = "사진을 처리하지 못했어요."; return }
        model.photo = data; model.saveDraft()
    }
    private func openCamera() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { message = "이 기기에서는 카메라를 사용할 수 없어요. 사진 보관함을 이용해주세요."; return }
        let allowed: Bool
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: allowed = true
        case .notDetermined: allowed = await AVCaptureDevice.requestAccess(for: .video)
        default: allowed = false
        }
        if allowed { showCamera = true } else { message = "설정에서 카메라 권한을 허용해주세요." }
    }
}
