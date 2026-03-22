import SpriteKit
import UIKit

final class GameScene: SKScene {

    // MARK: - Track
    private let trackConfig: TrackConfig

    // MARK: - Nodes
    private let worldNode  = SKNode()
    private let motorcycle = Motorcycle()
    private let cameraNode = SKCameraNode()

    // HUD
    private let joystickNode   = SKNode()
    private let crosshairNode  = SKNode()
    private let inputDotNode   = SKShapeNode(circleOfRadius: 8)
    private let boundarySquare = SKShapeNode(rect: CGRect(x: -170, y: -104, width: 340, height: 208))
    private let menuButton     = SKLabelNode(text: "‹ Menu")

    // Computed in didChangeSize once the scene size is known
    private var joystickYOffset: CGFloat = 250

    // MARK: - Controllers
    private let inputController = InputController()

    // MARK: - Touch
    private var activeTouch: UITouch?

    // MARK: - Timing
    private var lastUpdateTime: TimeInterval = 0

    // MARK: - Init
    init(size: CGSize, trackConfig: TrackConfig) {
        self.trackConfig = trackConfig
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    // MARK: - Setup
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.13, green: 0.37, blue: 0.13, alpha: 1)

        setupWorld()
        setupCamera()
        setupHUD()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard size.height > 0 else { return }
        joystickYOffset = size.height / 2 - 104 - 20
        joystickNode.position = CGPoint(x: 0, y: -joystickYOffset)
    }

    private func setupWorld() {
        addChild(worldNode)
        worldNode.addChild(Track(config: trackConfig))
        worldNode.addChild(motorcycle)
        motorcycle.position = trackConfig.startPosition
    }

    private func setupCamera() {
        camera = cameraNode
        addChild(cameraNode)
        cameraNode.position = motorcycle.position
    }

    private func setupHUD() {
        // Joystick container
        joystickNode.position = CGPoint(x: 0, y: -joystickYOffset)
        cameraNode.addChild(joystickNode)

        boundarySquare.strokeColor = UIColor(white: 0.5, alpha: 0.4)
        boundarySquare.lineWidth = 1
        boundarySquare.fillColor = .clear
        joystickNode.addChild(boundarySquare)

        let hLine = makeLine(from: CGPoint(x: -20, y: 0), to: CGPoint(x: 20, y: 0))
        let vLine = makeLine(from: CGPoint(x: 0, y: -20), to: CGPoint(x: 0, y: 20))
        crosshairNode.addChild(hLine)
        crosshairNode.addChild(vLine)
        joystickNode.addChild(crosshairNode)

        inputDotNode.fillColor = .white
        inputDotNode.strokeColor = .clear
        joystickNode.addChild(inputDotNode)

        // Menu button — top-left of camera view
        menuButton.fontName = "AvenirNext-Medium"
        menuButton.fontSize = 22
        menuButton.fontColor = UIColor(white: 1, alpha: 0.7)
        menuButton.horizontalAlignmentMode = .left
        menuButton.verticalAlignmentMode = .top
        // Positioned after didChangeSize sets the size; use a safe default offset
        menuButton.position = CGPoint(x: -size.width / 2 + 20, y: size.height / 2 - 20)
        cameraNode.addChild(menuButton)
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

        cameraNode.position = motorcycle.position
        cameraNode.zRotation = -motorcycle.bikeHeading

        updateHUDDot()

        // Keep menu button fixed at top-left regardless of scene size
        menuButton.position = CGPoint(x: -size.width / 2 + 20, y: size.height / 2 - 20)
    }

    private func updateHUDDot() {
        let input  = inputController.state
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
        guard let touch = touches.first else { return }

        // Menu button hit-test (in camera/screen space)
        let locInCamera = touch.location(in: cameraNode)
        if menuButton.contains(locInCamera) {
            goToMenu()
            return
        }

        guard activeTouch == nil else { return }
        activeTouch = touch
        handleJoystickTouch(touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let active = activeTouch, touches.contains(active) else { return }
        handleJoystickTouch(active)
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

    private func handleJoystickTouch(_ touch: UITouch) {
        guard let view = view else { return }
        let location = touch.location(in: view)
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY + joystickYOffset)
        inputController.update(touchLocation: location, viewCenter: center)
    }

    private func goToMenu() {
        let menu = MenuScene(size: size)
        menu.scaleMode = .resizeFill
        view?.presentScene(menu, transition: SKTransition.fade(withDuration: 0.4))
    }
}
