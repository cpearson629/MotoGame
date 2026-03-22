import SpriteKit
import UIKit

final class GameScene: SKScene {

    // MARK: - Nodes
    private let worldNode  = SKNode()
    private let motorcycle = Motorcycle()
    private let track      = Track()
    private let cameraNode = SKCameraNode()

    // HUD
    private let joystickNode   = SKNode()
    private let crosshairNode  = SKNode()
    private let inputDotNode   = SKShapeNode(circleOfRadius: 8)
    private let boundarySquare = SKShapeNode(rect: CGRect(x: -80, y: -80, width: 160, height: 160))

    // Computed in didMove(to:) once the scene size is known
    private var joystickYOffset: CGFloat = 250

    // MARK: - Controllers
    private let inputController = InputController()

    // MARK: - Touch
    private var activeTouch: UITouch?

    // MARK: - Timing
    private var lastUpdateTime: TimeInterval = 0

    // MARK: - Setup
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.13, green: 0.37, blue: 0.13, alpha: 1)

        setupWorld()
        setupCamera()
        setupHUD()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard size.height > 0 else { return }
        joystickYOffset = size.height / 2 - 80 - 20
        joystickNode.position = CGPoint(x: 0, y: -joystickYOffset)
    }

    private func setupWorld() {
        addChild(worldNode)
        worldNode.addChild(track)
        worldNode.addChild(motorcycle)
        motorcycle.position = Track.startPosition
    }

    private func setupCamera() {
        camera = cameraNode
        addChild(cameraNode)
        cameraNode.position = motorcycle.position
    }

    private func setupHUD() {
        // Container positioned below screen center
        joystickNode.position = CGPoint(x: 0, y: -joystickYOffset)
        cameraNode.addChild(joystickNode)

        // Boundary square
        boundarySquare.strokeColor = UIColor(white: 0.5, alpha: 0.4)
        boundarySquare.lineWidth = 1
        boundarySquare.fillColor = .clear
        joystickNode.addChild(boundarySquare)

        // Crosshair lines
        let hLine = makeLine(from: CGPoint(x: -20, y: 0), to: CGPoint(x: 20, y: 0))
        let vLine = makeLine(from: CGPoint(x: 0, y: -20), to: CGPoint(x: 0, y: 20))
        crosshairNode.addChild(hLine)
        crosshairNode.addChild(vLine)
        joystickNode.addChild(crosshairNode)

        // Input dot
        inputDotNode.fillColor = .white
        inputDotNode.strokeColor = .clear
        inputDotNode.position = .zero
        joystickNode.addChild(inputDotNode)
    }

    private func makeLine(from: CGPoint, to: CGPoint) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        let node = SKShapeNode(path: path)
        node.strokeColor = UIColor(white: 0.7, alpha: 0.6)
        node.lineWidth = 1
        return node
    }

    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        let dt: CGFloat
        if lastUpdateTime == 0 {
            dt = 1.0 / 60.0
        } else {
            dt = CGFloat(min(currentTime - lastUpdateTime, 0.05))
        }
        lastUpdateTime = currentTime

        motorcycle.update(dt: dt, input: inputController.state)

        // Camera follows bike, rotated so bike faces screen-up
        cameraNode.position = motorcycle.position
        cameraNode.zRotation = -motorcycle.bikeHeading

        // HUD dot
        updateHUDDot()
    }

    private func updateHUDDot() {
        let input = inputController.state
        let offset = inputController.touchOffsetInScreen

        inputDotNode.position = offset

        if input.throttle > 0.01 {
            inputDotNode.fillColor = .green
        } else if input.brake > 0.01 {
            inputDotNode.fillColor = .red
        } else {
            inputDotNode.fillColor = .white
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard activeTouch == nil, let touch = touches.first else { return }
        activeTouch = touch
        handleTouch(touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let active = activeTouch, touches.contains(active) else { return }
        handleTouch(active)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let active = activeTouch, touches.contains(active) else { return }
        activeTouch = nil
        inputController.reset()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let active = activeTouch, touches.contains(active) else { return }
        activeTouch = nil
        inputController.reset()
    }

    private func handleTouch(_ touch: UITouch) {
        guard let view = view else { return }
        // Use UIKit coordinates (Y increases downward) — NOT scene coordinates
        let location = touch.location(in: view)
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY + joystickYOffset)
        inputController.update(touchLocation: location, viewCenter: center)
    }
}
