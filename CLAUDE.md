# MotoGame — Project Reference

## Overview

iOS SpriteKit motorcycle racing game. Single-touch joystick controls a motorcycle around a top-down oval track. Built with Swift 6 / strict concurrency.

**Build:** `xcodegen generate` → open `MotoGame.xcodeproj` → run on simulator or device.

---

## File Map

| File | Responsibility |
|------|---------------|
| `project.yml` | XcodeGen config — orientations, deployment target, build settings |
| `AppDelegate.swift` | Boilerplate UIApplicationDelegate |
| `GameViewController.swift` | Hosts SKView, presents GameScene, declares supported orientations |
| `GameScene.swift` | Root SKScene — world setup, camera, HUD, touch routing, game loop |
| `Motorcycle.swift` | Physics/state: speed, heading, lean, position, sprite rotation |
| `InputController.swift` | Converts raw touch offset → `InputState` (throttle/brake/lean 0–1) |
| `Track.swift` | Static oval track geometry drawn with SKShapeNode |

---

## Architecture

### Coordinate conventions
- **World:** SpriteKit standard (Y up). `bikeHeading = 0` → moving in +Y direction.
- **UIKit touch:** Y down. `InputController` receives UIKit coords and flips Y when needed.
- **Camera:** `cameraNode.zRotation = -bikeHeading` keeps the bike always pointing screen-up.

### Motorcycle heading & rotation
- `Motorcycle` node: `zRotation = -bikeHeading` (set each frame in `update`)
- `spriteNode` (child): `zRotation = -leanAngle` (visual lean only)
- Together these make the sprite face its direction of travel with a lean tilt.

### Input → game loop
1. `GameScene` receives `UITouch`, passes UIKit location + view center to `InputController.update()`
2. `InputController` computes `InputState` (throttle/brake/lean) and `touchOffsetInScreen` for HUD
3. `GameScene.update()` passes `inputController.state` to `motorcycle.update(dt:input:)`

---

## Key Constants

### Motorcycle (`Motorcycle.swift`)
| Constant | Value |
|----------|-------|
| maxSpeed | 600 pt/s |
| acceleration | 280 pt/s² |
| brakeForce | 450 pt/s² |
| dragCoefficient | 0.85 (per-second, frame-rate-independent) |
| maxTurnRate | 3.5 rad/s |
| maxLeanAngle | 0.42 rad (~24°) |
| leanSpringK | 8.0 |

### InputController (`InputController.swift`)
| Constant | Value | Notes |
|----------|-------|-------|
| deadZone | 10 pt | circular — `hypot(dx,dy) > deadZone` |
| maxRadius | 80 pt | each axis clamped independently (square boundary) |

### Track (`Track.swift`)
| Constant | Value |
|----------|-------|
| outerWidth | 900 pt |
| outerHeight | 700 pt |
| roadWidth | 80 pt |
| corner radius | 60 pt |

---

## HUD

Drawn as children of `cameraNode` (screen-fixed):

- **`boundarySquare`** — `160×160` pt square outline (±80 pt), strokeColor white 40% alpha. Represents the input zone edges.
- **`crosshairNode`** — ±20 pt crosshair lines at screen center.
- **`inputDotNode`** — 8 pt radius circle. Position = `touchOffsetInScreen` directly (maxRadius = 80 pt = box half-size, no scaling needed). Color: green = throttle, red = brake, white = neutral/lean only.

---

## Input Scheme (square joystick)

```
dx = touch.x - center.x   (UIKit)
dy = touch.y - center.y   (UIKit, positive = down)

// Deadzone (circular)
guard hypot(dx, dy) > 10 else { return neutral }

// Square clamp (each axis independent, matches box size)
clampedDx = clamp(dx, -80, 80)
clampedDy = clamp(dy, -80, 80)

lean     = clampedDx / 80          // -1 (left) … +1 (right)
throttle = clampedDy < 0 ? -clampedDy/80 : 0   // finger above center
brake    = clampedDy > 0 ?  clampedDy/80 : 0   // finger below center
```

---

## Orientation

Portrait only. Set in two places (must match):
1. `project.yml` → `SUPPORTED_INTERFACE_ORIENTATIONS_IPHONE: UIInterfaceOrientationPortrait`
2. `GameViewController.swift` → `supportedInterfaceOrientations` returns `.portrait`

---

## Build Notes

- Swift 6 strict concurrency — all game state touched only on the main actor (SKScene/SKNode are main-thread).
- `xcodegen generate` must be re-run after any `project.yml` change.
- No storyboards or XIBs — `GameViewController.loadView()` creates the SKView programmatically.
