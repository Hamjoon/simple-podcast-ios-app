import SwiftUI

/// App Store-style search bar with dismiss button
struct SearchBarView: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 17))

                TextField("에피소드 검색...", text: $text)
                    .focused($isFocused)
                    .disableAutocorrection(true)

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 17))
                    }
                }
            }
            .padding(12)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)

            // Dismiss keyboard button (visible when keyboard is active)
            if isFocused {
                Button {
                    isFocused = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(UIColor.systemGray5))
                        .clipShape(Circle())
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

#Preview {
    VStack {
        SearchBarView(text: .constant(""))
        SearchBarView(text: .constant("테스트"))
    }
}
