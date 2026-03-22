import SpriteKit

final class MenuScene: SKScene {

    private var trackCards: [(node: SKShapeNode, config: TrackConfig)] = []
    private var uiBuilt = false

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.10, green: 0.28, blue: 0.10, alpha: 1)
    }

    // didChangeSize is called with the real screen size after resizeFill applies.
    // Build UI here so all size-based positions are correct.
    override func didChangeSize(_ oldSize: CGSize) {
        guard size.width > 0, size.height > 0, !uiBuilt else { return }
        uiBuilt = true
        buildUI()
    }

    private func buildUI() {
        let w = size.width
        let h = size.height

        // Title — 30% down from the top of the screen
        let title = SKLabelNode(text: "MotoGame")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 48
        title.fontColor = .white
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: h * 0.5 - h * 0.18)
        addChild(title)

        let subtitle = SKLabelNode(text: "Select a Track")
        subtitle.fontName = "AvenirNext-Medium"
        subtitle.fontSize = 22
        subtitle.fontColor = UIColor(white: 0.8, alpha: 1)
        subtitle.verticalAlignmentMode = .center
        subtitle.position = CGPoint(x: 0, y: h * 0.5 - h * 0.18 - 52)
        addChild(subtitle)

        // Track cards stacked in the middle of the screen
        let cardWidth: CGFloat  = w * 0.84
        let cardHeight: CGFloat = 110
        let spacing: CGFloat    = 24
        let count               = CGFloat(TrackConfig.all.count)
        let totalH              = count * cardHeight + (count - 1) * spacing
        let topCardY            = totalH / 2 - cardHeight / 2  // center the stack

        for (i, config) in TrackConfig.all.enumerated() {
            let y = topCardY - CGFloat(i) * (cardHeight + spacing)
            let card = makeCard(config: config, width: cardWidth, height: cardHeight)
            card.position = CGPoint(x: 0, y: y)
            addChild(card)
            trackCards.append((node: card, config: config))
        }
    }

    private func makeCard(config: TrackConfig, width: CGFloat, height: CGFloat) -> SKShapeNode {
        let bg = SKShapeNode(rect: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), cornerRadius: 14)
        bg.fillColor = UIColor(white: 1, alpha: 0.08)
        bg.strokeColor = UIColor(white: 1, alpha: 0.3)
        bg.lineWidth = 1.5

        let nameLabel = SKLabelNode(text: config.name)
        nameLabel.fontName = "AvenirNext-Bold"
        nameLabel.fontSize = 28
        nameLabel.fontColor = .white
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: 0, y: 14)
        bg.addChild(nameLabel)

        let descLabel = SKLabelNode(text: trackDescription(config))
        descLabel.fontName = "AvenirNext-Regular"
        descLabel.fontSize = 16
        descLabel.fontColor = UIColor(white: 0.75, alpha: 1)
        descLabel.verticalAlignmentMode = .center
        descLabel.position = CGPoint(x: 0, y: -18)
        bg.addChild(descLabel)

        return bg
    }

    private func trackDescription(_ config: TrackConfig) -> String {
        switch config.name {
        case "Classic":  return "Balanced oval · sweeping corners"
        case "Speedway": return "Long straights · high speed"
        case "Stadium":  return "Tall hairpins · technical"
        default:         return ""
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for (card, config) in trackCards {
            if card.contains(location) {
                let game = GameScene(size: size, trackConfig: config)
                game.scaleMode = .resizeFill
                view?.presentScene(game, transition: SKTransition.fade(withDuration: 0.4))
                return
            }
        }
    }
}
