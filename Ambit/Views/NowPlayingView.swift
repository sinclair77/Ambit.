import SwiftUI

struct NowPlayingView: View {
    var title: String = "Now Playing"
    var subtitle: String = "Artist – Album"
    var progress: Double = 0.35
    var onPlayPause: (() -> Void)? = nil
    var onNext: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(LinearGradient(colors: [.accentColor, .accentColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 36, height: 36)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.3), lineWidth: 0.5))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.footnote, design: .monospaced, weight: .semibold))
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.primary.opacity(0.08))
                        Capsule().fill(Color.accentColor.opacity(0.5))
                            .frame(width: max(2, geo.size.width * progress))
                    }
                }
                .frame(height: 4)
                .clipShape(Capsule())
            }

            Spacer(minLength: 8)

            HStack(spacing: 10) {
                Button {
                    onPlayPause?()
                } label: {
                    Image(systemName: "playpause.fill")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)

                Button {
                    onNext?()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassContainer(cornerRadius: 18, tint: .accentColor, intensity: 0.16, strokeOpacity: 0.18)
        .padding(.horizontal, 12)
    }
}
