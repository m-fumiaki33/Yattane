import Photos
import PhotosUI
import SwiftUI

struct AddMilestoneView: View {
  @State private var viewModel: AddMilestoneViewModel
  @Environment(\.dismiss) var dismiss
  @State private var showingPhotosPicker = false

  init(child: Child) {
    _viewModel = State(initialValue: AddMilestoneViewModel(child: child))
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("タイトル (例: 初めて笑った)", text: $viewModel.title)
          DatePicker("日付", selection: $viewModel.date, displayedComponents: .date)
        } header: {
          Text("詳細")
        }

        Section {
          Button {
            Task {
              let allowed = await viewModel.requestPhotoAccessIfNeeded()
              if allowed {
                showingPhotosPicker = true
              }
            }
          } label: {
            HStack {
              Image(systemName: "photo.on.rectangle.angled")
              Text("写真を選択")
            }
          }
          .photosPicker(
            isPresented: $showingPhotosPicker,
            selection: $viewModel.selectedPhotoItems,
            matching: .images
          )
          .onChange(of: viewModel.selectedPhotoItems, initial: false) { _, newValue in
            Task {
              await viewModel.loadPhotos(from: newValue)
            }
          }

          if !viewModel.selectedPhotoDataList.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 8) {
                ForEach(viewModel.selectedPhotoDataList, id: \.self) { data in
                  if let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                      .resizable()
                      .scaledToFill()
                      .frame(width: 100, height: 100)
                      .clipShape(RoundedRectangle(cornerRadius: 12))
                  }
                }
              }
            }
            .padding(.vertical, 8)
          }
        } header: {
          Text("写真")
        }

        Section {
          TextEditor(text: $viewModel.note)
            .frame(height: 100)
        } header: {
          Text("メモ")
        }
      }
      .navigationTitle("新しいできたこと")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("キャンセル") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("保存") {
            if viewModel.save() {
              dismiss()
            }
          }
        }
      }
      // 入力エラーアラート
      .alert("入力エラー", isPresented: $viewModel.showAlert) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(viewModel.errorMessage)
      }
      // フォトライブラリ拒否済みアラート
      .alert("フォトライブラリへのアクセスが許可されていません", isPresented: $viewModel.showPermissionDeniedAlert) {
        Button("設定を開く") {
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
          }
        }
        Button("キャンセル", role: .cancel) {}
      } message: {
        Text("写真を追加するには、設定アプリから「やったね！」のフォトライブラリへのアクセスを許可してください。")
      }
    }
  }
}

