import SwiftUI

struct ChoiceButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
            action()
        }) {
            HStack {
                Text(text)
                    .font(.body)
                    .foregroundColor(isSelected ? .cosmosBackground : .starWhite)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.cosmosBackground)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.softLavender : Color.cosmosPurple)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.softLavender.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 1.03 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

struct MultiChoiceButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .softLavender : .starWhite.opacity(0.6))
                Text(text)
                    .font(.body)
                    .foregroundColor(.starWhite)
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.softLavender.opacity(0.2) : Color.cosmosPurple)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.softLavender : Color.softLavender.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
