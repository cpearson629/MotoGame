import SpriteKit

final class Track: SKNode {

    private let config: TrackConfig

    init(config: TrackConfig) {
        self.config = config
        super.init()
        buildTrack()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    private func buildTrack() {
        let ow = config.outerWidth
        let oh = config.outerHeight
        let rw = config.roadWidth
        let r  = config.cornerRadius

        // Background fill (grass) — large enough to fill any viewport
        let background = SKShapeNode(rect: CGRect(x: -5000, y: -5000, width: 10000, height: 10000))
        background.fillColor = UIColor(red: 0.13, green: 0.37, blue: 0.13, alpha: 1)
        background.strokeColor = .clear
        addChild(background)

        // Road surface: outer rounded rect filled gray
        let outerRoad = SKShapeNode(path: CGPath(
            roundedRect: CGRect(x: -ow / 2, y: -oh / 2, width: ow, height: oh),
            cornerWidth: r + rw / 2, cornerHeight: r + rw / 2, transform: nil
        ))
        outerRoad.fillColor = UIColor(white: 0.22, alpha: 1)
        outerRoad.strokeColor = .clear
        addChild(outerRoad)

        // Inner grass patch to create road ring
        let innerGrass = SKShapeNode(path: CGPath(
            roundedRect: CGRect(x: -ow / 2 + rw, y: -oh / 2 + rw, width: ow - rw * 2, height: oh - rw * 2),
            cornerWidth: r - rw / 2, cornerHeight: r - rw / 2, transform: nil
        ))
        innerGrass.fillColor = UIColor(red: 0.13, green: 0.37, blue: 0.13, alpha: 1)
        innerGrass.strokeColor = .clear
        addChild(innerGrass)

        // Center-line dashes
        addCenterLineDashes()

        // Start/finish line
        let startLine = SKShapeNode(rect: CGRect(
            x: -rw / 2,
            y: -oh / 2 - rw / 2,
            width: rw,
            height: 12
        ))
        startLine.fillColor = .white
        startLine.strokeColor = .clear
        addChild(startLine)
    }

    private func addCenterLineDashes() {
        let ow = config.outerWidth
        let oh = config.outerHeight
        let rw = config.roadWidth
        let hw = ow / 2 - rw / 2   // centerline half-width
        let hh = oh / 2 - rw / 2   // centerline half-height
        let dashLen: CGFloat = 40
        let gap: CGFloat = 40

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
        dash.strokeColor = UIColor(white: 0.9, alpha: 0.5)
        dash.lineWidth = 5
        addChild(dash)
    }
}
