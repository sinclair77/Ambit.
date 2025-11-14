import SwiftUI

// This file only needs the FeatureCard struct and preview for the correct OnboardingView

struct FeatureCard: View {
    let title: String
    let description: String
    let systemImage: String
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                NoHyphenationLabel(
                    text: description,
                    font: UIFont.systemFont(ofSize: 14, weight: .regular),
                    color: UIColor.secondaryLabel
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}
