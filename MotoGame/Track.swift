import SpriteKit

final class Track: SKNode {

    // Track dimensions
    static let outerWidth: CGFloat  = 900
    static let outerHeight: CGFloat = 700
    static let roadWidth: CGFloat   = 80

    override init() {
        super.init()
        buildTrack()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    private func buildTrack() {
        // Background fill (grass) — large enough to fill any viewport
        let background = SKShapeNode(rect: CGRect(
            x: -5000,
            y: -5000,
            width: 10000,
            height: 10000
        ))
        background.fillColor = UIColor(red: 0.13, green: 0.37, blue: 0.13, alpha: 1)
        background.strokeColor = .clear
        addChild(background)

        // Road surface: outer rectangle filled gray
        let hw = Track.outerWidth / 2
        let hh = Track.outerHeight / 2
        let rw = Track.roadWidth
        let r: CGFloat = 60

        let outerRoad = SKShapeNode(path: CGPath(
            roundedRect: CGRect(x: -hw, y: -hh, width: Track.outerWidth, height: Track.outerHeight),
            cornerWidth: r + rw / 2, cornerHeight: r + rw / 2, transform: nil
        ))
        outerRoad.fillColor = UIColor(white: 0.22, alpha: 1)
        outerRoad.strokeColor = .clear
        addChild(outerRoad)

        // Inner grass patch on top to create road ring
        let innerGrass = SKShapeNode(path: CGPath(
            roundedRect: CGRect(x: -hw + rw, y: -hh + rw, width: Track.outerWidth - rw * 2, height: Track.outerHeight - rw * 2),
            cornerWidth: r - rw / 2, cornerHeight: r - rw / 2, transform: nil
        ))
        innerGrass.fillColor = UIColor(red: 0.13, green: 0.37, blue: 0.13, alpha: 1)
        innerGrass.strokeColor = .clear
        addChild(innerGrass)

        // Center-line dashes
        addCenterLineDashes()

        // Start/finish line
        let startLine = SKShapeNode(rect: CGRect(
            x: -Track.roadWidth / 2,
            y: -Track.outerHeight / 2 - Track.roadWidth / 2,
            width: Track.roadWidth,
            height: 8
        ))
        startLine.fillColor = .white
        startLine.strokeColor = .clear
        addChild(startLine)
    }

    private func addCenterLineDashes() {
        let hw = Track.outerWidth / 2 - Track.roadWidth / 2
        let hh = Track.outerHeight / 2 - Track.roadWidth / 2
        let dashLen: CGFloat = 30
        let gap: CGFloat = 30

        // Top straight
        var x = -hw + dashLen
        while x < hw - dashLen {
            addDash(from: CGPoint(x: x, y: hh), to: CGPoint(x: x + dashLen, y: hh))
            x += dashLen + gap
        }
        // Bottom straight
        x = -hw + dashLen
        while x < hw - dashLen {
            addDash(from: CGPoint(x: x, y: -hh), to: CGPoint(x: x + dashLen, y: -hh))
            x += dashLen + gap
        }
        // Left straight
        var y = -hh + dashLen
        while y < hh - dashLen {
            addDash(from: CGPoint(x: -hw, y: y), to: CGPoint(x: -hw, y: y + dashLen))
            y += dashLen + gap
        }
        // Right straight
        y = -hh + dashLen
        while y < hh - dashLen {
            addDash(from: CGPoint(x: hw, y: y), to: CGPoint(x: hw, y: y + dashLen))
            y += dashLen + gap
        }
    }

    private func addDash(from: CGPoint, to: CGPoint) {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        let dash = SKShapeNode(path: path)
        dash.strokeColor = UIColor(white: 0.9, alpha: 0.6)
        dash.lineWidth = 3
        addChild(dash)
    }

    /// Starting position for the motorcycle
    static var startPosition: CGPoint {
        CGPoint(x: 0, y: -outerHeight / 2 + roadWidth / 2)
    }
}
