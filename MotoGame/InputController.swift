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
    private let maxX: CGFloat = 170  // half-width  (~340pt total, near screen width)
    private let maxY: CGFloat = 104  // half-height (208pt total, 30% taller)

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

        let clampedDx = max(-maxX, min(maxX, dx))
        let clampedDy = max(-maxY, min(maxY, dy))

        let lean     = Float(clampedDx / maxX)
        let throttle = clampedDy < 0 ? Float(-clampedDy / maxY) : 0
        let brake    = clampedDy > 0 ? Float( clampedDy / maxY) : 0

        state = InputState(throttle: throttle, brake: brake, lean: lean)

        // Store clamped offset for HUD dot (in screen coords, Y flipped for SpriteKit)
        touchOffsetInScreen = CGPoint(x: clampedDx, y: -clampedDy)
    }

    func reset() {
        state = .neutral
        touchOffsetInScreen = .zero
    }
}
