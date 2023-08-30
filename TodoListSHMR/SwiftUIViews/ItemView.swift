import SwiftUI

struct ItemView: View {

    let item: TodoItem

    var body: some View {
        HStack {
            CircleStatView
            TextStackView
            Spacer()
            Image(uiImage: Icon.Shevron.image!)
        }

    }

    // MARK: CircleStatView
    @ViewBuilder
    private var CircleStatView: some View {
         if item.isCompleted {
            Image(uiImage: Icon.CircleCompleted.image!)
         } else if item.importancy == .important {
            HStack {
                 Image(uiImage: Icon.CircleImportant.image!)
                 Image(uiImage: Icon.Important.image!)
            }
         } else {
             Image(uiImage: Icon.CircleEmpty.image!)
         }
    }

    // MARK: TextStackView
    @ViewBuilder
    private var TextStackView: some View {
        if item.isCompleted {
            Text(item.text).strikethrough().foregroundColor(Color.gray)
        } else if item.deadline != nil {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.text).font(.body)
                CalendarView
            }
        } else {
            Text(item.text)
        }
    }

    // MARK: CalendarView
    private var CalendarView: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        return HStack(alignment: .bottom) {
            Image(systemName: "calendar")
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundColor(.gray)
            Text(dateFormatter.string(from: item.deadline!))
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                ItemView(item: mockData.first!)
                ItemView(item: mockData[2])
                ItemView(item: mockData.last!)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
