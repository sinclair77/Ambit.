import SwiftUI

struct TickSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...1
    var neutral: Double? = nil
    var numberOfTicks: Int = 0
    var thumbless: Bool = false

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack {
                Capsule().fill(Color.primary.opacity(0.08)).frame(height: 6)

                if numberOfTicks > 1 {
                    let step = (range.upperBound - range.lowerBound) / Double(numberOfTicks - 1)
                    ForEach(0..<numberOfTicks, id: \.self) { i in
                        let tickValue = range.lowerBound + Double(i) * step
                        let x = CGFloat((tickValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * width
                        Rectangle()
                            .fill(Color.primary.opacity(0.25))
                            .frame(width: 1, height: 10)
                            .position(x: x, y: 6)
                    }
                }

                if let neutral {
                    let x = CGFloat((neutral - range.lowerBound) / (range.upperBound - range.lowerBound)) * width
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.6))
                        .frame(width: 2, height: 14)
                        .position(x: x, y: 6)
                }

                let knobX = CGFloat((min(max(value, range.lowerBound), range.upperBound) - range.lowerBound) / (range.upperBound - range.lowerBound)) * width

                if !thumbless {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 18, height: 18)
                        .shadow(radius: 2, y: 1)
                        .position(x: knobX, y: 6)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0).onChanged { g in
                    let x = min(max(0, g.location.x), width)
                    let ratio = x / width
                    value = Double(ratio) * (range.upperBound - range.lowerBound) + range.lowerBound
                }
            )
        }
        .frame(height: 24)
    }
}
