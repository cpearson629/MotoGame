import SpriteKit

final class Motorcycle: SKNode {

    // MARK: - Constants
    private let maxSpeed: CGFloat      = 600
    private let acceleration: CGFloat  = 280
    private let brakeForce: CGFloat    = 450
    private let dragCoefficient: CGFloat = 0.85
    private let maxTurnRate: CGFloat   = 3.5   // rad/sec
    private let maxLeanAngle: CGFloat  = 0.42  // radians (~24°)
    private let springK: CGFloat       = 8.0

    // MARK: - State
    private(set) var bikeSpeed: CGFloat = 0
    private(set) var bikeHeading: CGFloat = 0  // radians, 0 = pointing +Y (up)
    private var leanAngle: CGFloat = 0

    // MARK: - Nodes
    private let spriteNode: SKShapeNode

    // MARK: - Init
    override init() {
        // Simple rectangle representing the bike body
        let bikeRect = CGRect(x: -12, y: -20, width: 24, height: 40)
        spriteNode = SKShapeNode(rect: bikeRect, cornerRadius: 4)
        spriteNode.fillColor = .red
        spriteNode.strokeColor = .orange
        spriteNode.lineWidth = 2

        // Front indicator dot
        let frontDot = SKShapeNode(circleOfRadius: 4)
        frontDot.fillColor = .yellow
        frontDot.position = CGPoint(x: 0, y: 18)
        spriteNode.addChild(frontDot)

        super.init()
        addChild(spriteNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    // MARK: - Update
    func update(dt: CGFloat, input: InputState) {
        let throttle = CGFloat(input.throttle)
        let brake    = CGFloat(input.brake)
        let lean     = CGFloat(input.lean)

        // --- Speed ---
        bikeSpeed += throttle * acceleration * dt
        bikeSpeed -= brake * brakeForce * dt
        bikeSpeed *= pow(dragCoefficient, dt)   // frame-rate-independent drag
        bikeSpeed = max(0, min(bikeSpeed, maxSpeed))

        // --- Heading ---
        let speedFraction = bikeSpeed / maxSpeed
        let turnRate = lean * maxTurnRate * speedFraction
        bikeHeading += turnRate * dt
        zRotation = -bikeHeading

        // --- Position (bikeHeading=0 → moving along +Y world axis) ---
        position.x += sin(bikeHeading) * bikeSpeed * dt
        position.y += cos(bikeHeading) * bikeSpeed * dt

        // --- Lean visual (spring to target) ---
        let targetLean = lean * maxLeanAngle
        leanAngle += (targetLean - leanAngle) * min(1.0, springK * dt)
        spriteNode.zRotation = -leanAngle
    }
}
