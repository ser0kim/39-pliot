// Created by 김세령.
import SwiftUI
import Photos
import AVFoundation

@MainActor
struct CameraPicker: UIViewControllerRepresentable {
    let selected: (UIImage) -> Void
    let cancel: () -> Void
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .camera; controller.delegate = context.coordinator
        return controller
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(parent: CameraPicker) { self.parent = parent }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.cancel() }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage { parent.selected(image) } else { parent.cancel() }
        }
    }
}

@MainActor
enum PhotoServices {
    static func normalized(_ image: UIImage) -> Data? {
        let ratio = min(1, 1600 / max(image.size.width, image.size.height))
        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        let format = UIGraphicsImageRendererFormat(); format.scale = 1
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in image.draw(in: CGRect(origin: .zero, size: size)) }
        return resized.jpegData(compressionQuality: 0.85)
    }
    static func saveCertificate(_ record: AdventureRecord) async throws {
        let permission = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard permission == .authorized || permission == .limited else { throw PhotoError.denied }
        let renderer = ImageRenderer(content: CertificateCard(record: record).frame(width: 345).padding(24).background(GuildTheme.paper).foregroundStyle(GuildTheme.ink).environment(\.colorScheme, .dark))
        renderer.scale = 3
        guard let image = renderer.uiImage else { throw PhotoError.failed }
        try await PHPhotoLibrary.shared().performChanges { PHAssetChangeRequest.creationRequestForAsset(from: image) }
    }
    enum PhotoError: LocalizedError {
        case denied, failed
        var errorDescription: String? { self == .denied ? "설정에서 사진 추가 권한을 허용해주세요." : "이미지를 저장하지 못했어요. 다시 시도해주세요." }
    }
}
