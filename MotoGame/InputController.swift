import UIKit
import CoreGraphics

struct InputState {
    var throttle: Float  // 0..1
    var brake: Float     // 0..1
    var lean: Float      // -1..1 (negative = left, positive = right)

    static let neutral = InputState(throttle: 0, brake: 0, lean: 0)
}

final class InputController {
    private let deadZone: CGFloat = 10
    private let maxRadius: CGFloat = 80

    private(set) var state: InputState = .neutral
    private(set) var touchOffsetInScreen: CGPoint = .zero  // for HUD dot

    func update(touchLocation: CGPoint, viewCenter: CGPoint) {
        let dx = touchLocation.x - viewCenter.x
        // UIKit: positive dy = finger BELOW center
        let dy = touchLocation.y - viewCenter.y

        let rawDist = hypot(dx, dy)
        guard rawDist > deadZone else {
            state = .neutral
            touchOffsetInScreen = .zero
            return
        }

        let clampedDx = max(-maxRadius, min(maxRadius, dx))
        let clampedDy = max(-maxRadius, min(maxRadius, dy))

        let lean     = Float(clampedDx / maxRadius)
        let throttle = clampedDy < 0 ? Float(-clampedDy / maxRadius) : 0
        let brake    = clampedDy > 0 ? Float( clampedDy / maxRadius) : 0

        state = InputState(throttle: throttle, brake: brake, lean: lean)

        // Store clamped offset for HUD dot (in screen coords, Y flipped for SpriteKit)
        touchOffsetInScreen = CGPoint(x: clampedDx, y: -clampedDy)
    }

    func reset() {
        state = .neutral
        touchOffsetInScreen = .zero
    }
}
