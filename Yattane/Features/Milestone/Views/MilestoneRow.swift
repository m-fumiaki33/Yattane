import SwiftUI

struct MilestoneRow: View {
  let milestone: Milestone

  var body: some View {
    HStack(spacing: 16) {
      if let data = milestone.photoData, let uiImage = UIImage(data: data) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
          .frame(width: 60, height: 60)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
      } else {
        ZStack {
          RoundedRectangle(cornerRadius: 16)
            .fill(Color.softTheme.babyBlue.opacity(0.3))
            .frame(width: 60, height: 60)

          Image(systemName: "photo")
            .foregroundColor(Color.softTheme.babyBlue)
            .font(.title2)
        }
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(milestone.title ?? "タイトルなし")
          .font(.softHeadline)
          .foregroundColor(Color.softTheme.textPrimary)

        if let date = milestone.date {
          VStack(alignment: .leading, spacing: 2) {
            Text(date, format: .dateTime.year().month().day().locale(Locale(identifier: "ja_JP")))
              .font(.softCaption)
              .foregroundColor(Color.softTheme.textSecondary)

            if let age = ageString {
              Text(age)
                .font(.softCaption)
                .foregroundColor(Color.softTheme.primaryAction)
                .padding(.top, 2)
            }
          }
        }
      }

      Spacer()
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 4)
  }

  private var ageString: String? {
    // ... existing logic ...
    guard let date = milestone.date,
      let birthday = milestone.child?.birthday
    else { return nil }

    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: birthday, to: date)

    if let year = components.year, let month = components.month {
      if year > 0 {
        return "\(year)歳\(month)ヶ月"
      } else {
        return "\(month)ヶ月"
      }
    }
    return nil
  }
}
