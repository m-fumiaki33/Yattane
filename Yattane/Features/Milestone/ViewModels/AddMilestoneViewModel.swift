import Photos
import PhotosUI
import SwiftUI

@Observable
class AddMilestoneViewModel {
  var title: String = ""
  var date: Date = Date()
  var note: String = ""
  var selectedPhotoItems: [PhotosPickerItem] = []
  var selectedPhotoDataList: [Data] = []
  var showAlert = false
  var errorMessage = ""

  // Photo permission
  var photoAuthStatus: PHAuthorizationStatus = .notDetermined
  var showPermissionDeniedAlert = false

  private let repository: MilestoneRepositoryProtocol
  private let child: Child

  init(child: Child, repository: MilestoneRepositoryProtocol = MilestoneRepository()) {
    self.child = child
    self.repository = repository
    self.photoAuthStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
  }

  /// 写真ボタンタップ時に呼ぶ。許可済みならtrue、未許可→リクエスト、拒否済みならアラートを出す
  @MainActor
  func requestPhotoAccessIfNeeded() async -> Bool {
    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    switch status {
    case .authorized, .limited:
      photoAuthStatus = status
      return true
    case .notDetermined:
      let granted = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
      photoAuthStatus = granted
      return granted == .authorized || granted == .limited
    case .denied, .restricted:
      photoAuthStatus = status
      showPermissionDeniedAlert = true
      return false
    @unknown default:
      return false
    }
  }

  func save() -> Bool {
    if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      errorMessage = "タイトルを入力してください。"
      showAlert = true
      return false
    }

    do {
      try repository.addMilestone(
        title: title, date: date, photoDataList: selectedPhotoDataList,
        note: note.isEmpty ? nil : note,
        child: child)
      return true
    } catch {
      print("Failed to save milestone: \(error)")
      errorMessage = "保存に失敗しました。"
      showAlert = true
      return false
    }
  }

  @MainActor
  func loadPhotos(from items: [PhotosPickerItem]) async {
    selectedPhotoDataList.removeAll()
    for item in items {
      do {
        if let data = try await item.loadTransferable(type: Data.self) {
          selectedPhotoDataList.append(data)
        }
      } catch {
        print("Failed to load photo: \(error)")
      }
    }
  }
}

