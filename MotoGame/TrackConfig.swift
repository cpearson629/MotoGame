import CoreGraphics

struct TrackConfig {
    let name: String
    let outerWidth: CGFloat
    let outerHeight: CGFloat
    let roadWidth: CGFloat
    let cornerRadius: CGFloat

    var startPosition: CGPoint {
        CGPoint(x: 0, y: -outerHeight / 2 + roadWidth / 2)
    }

    static let all: [TrackConfig] = [.classic, .speedway, .stadium]

    // Balanced oval — wide sweeping corners, good all-around feel
    static let classic = TrackConfig(
        name: "Classic",
        outerWidth: 1400, outerHeight: 900,
        roadWidth: 240, cornerRadius: 280
    )

    // Very long straights + wide semicircular ends — pure speed
    static let speedway = TrackConfig(
        name: "Speedway",
        outerWidth: 2600, outerHeight: 750,
        roadWidth: 240, cornerRadius: 250
    )

    // Tall narrow shape — long sweeping hairpins at each end
    static let stadium = TrackConfig(
        name: "Stadium",
        outerWidth: 900, outerHeight: 2200,
        roadWidth: 240, cornerRadius: 330
    )
}
