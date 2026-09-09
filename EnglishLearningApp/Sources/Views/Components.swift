import SwiftUI

// MARK: - Card container

struct Card: View {
    var accent: Color
    private let content: AnyView

    init<C: View>(accent: Color = Theme.primary, @ViewBuilder content: () -> C) {
        self.accent = accent
        self.content = AnyView(content())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accent.opacity(0.35), lineWidth: 1.5)
        )
    }
}

// MARK: - Section header

struct SectionHeader: View {
    let title: String
    var icon: String = "book.fill"

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Theme.primary)
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

// MARK: - Multiple-choice question card (shared by Exercise & Reading)

struct MCQCard: View {
    let question: MCQuestion
    let accent: Color
    var onResult: ((Bool) -> Void)? = nil

    @State private var selectedIndex: Int?
    @State private var didCheck = false

    private var isCorrect: Bool { selectedIndex == question.correctIndex }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(question.prompt)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(question.options.indices, id: \.self) { index in
                optionRow(index: index)
            }

            if didCheck {
                resultView
            } else {
                Button(action: check) {
                    Text("Check answer")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.primary)
                        .cornerRadius(12)
                }
                .disabled(selectedIndex == nil)
                .opacity(selectedIndex == nil ? 0.5 : 1)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accent.opacity(0.35), lineWidth: 1.5)
        )
    }

    private func optionRow(index: Int) -> some View {
        let letter = String(UnicodeScalar(65 + index)!) // A, B, C, D
        let isSelected = selectedIndex == index
        let isCorrectOption = index == question.correctIndex

        var background = Theme.cardBackground
        var border = Color.gray.opacity(0.35)
        var letterColor = Color.secondary

        if didCheck {
            if isCorrectOption {
                background = Theme.success.opacity(0.15)
                border = Theme.success
                letterColor = Theme.success
            } else if isSelected {
                background = Theme.danger.opacity(0.15)
                border = Theme.danger
                letterColor = Theme.danger
            }
        } else if isSelected {
            background = Theme.primary.opacity(0.15)
            border = Theme.primary
            letterColor = Theme.primary
        }

        return Button(action: { select(index) }) {
            HStack(spacing: 12) {
                Text(letter)
                    .font(.headline)
                    .foregroundColor(letterColor)
                    .frame(width: 28, height: 28)
                    .background(letterColor.opacity(0.15))
                    .cornerRadius(14)

                Text(question.options[index])
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                if didCheck && isCorrectOption {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.success)
                } else if didCheck && isSelected {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.danger)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(border, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var resultView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                Text(isCorrect ? "Correct!" : "Not quite")
                    .fontWeight(.bold)
            }
            .foregroundColor(isCorrect ? Theme.success : Theme.danger)

            Text(question.explanation)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: reset) {
                Text("Try again")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.primary)
            }
        }
    }

    private func select(_ index: Int) {
        guard !didCheck else { return }
        selectedIndex = index
    }

    private func check() {
        guard selectedIndex != nil else { return }
        didCheck = true
        onResult?(isCorrect)
    }

    private func reset() {
        selectedIndex = nil
        didCheck = false
    }
}
