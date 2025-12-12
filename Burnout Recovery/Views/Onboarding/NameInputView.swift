import SwiftUI

struct NameInputView: View {
    @Binding var name: String
    let onContinue: () -> Void

    @FocusState private var isNameFocused: Bool

    var body: some View {
        ZStack {
            Color.cosmosBackground
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    Text("What should we call you?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.starWhite)
                        .multilineTextAlignment(.center)

                    Text("Just a first name is perfect")
                        .font(.body)
                        .foregroundColor(.starWhite.opacity(0.7))
                }

                TextField("", text: $name, prompt: Text("Your name").foregroundColor(.starWhite.opacity(0.4)))
                    .font(.title2)
                    .foregroundColor(.starWhite)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.cosmosPurple)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.softLavender.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 40)
                    .focused($isNameFocused)
                    .onSubmit {
                        if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                            onContinue()
                        }
                    }

                Spacer()

                PrimaryButton(title: "Continue", action: onContinue)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            isNameFocused = true
        }
    }
}
