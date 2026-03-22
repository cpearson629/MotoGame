# MotoGame — Project Reference

## Overview

iOS SpriteKit motorcycle racing game. Player selects a track from a menu, then controls a motorcycle around a top-down oval track using a single-touch joystick. Built with Swift 6 / strict concurrency.

**Build:** `xcodegen generate` → open `MotoGame.xcodeproj` → run on simulator or device.

---

## File Map

| File | Responsibility |
|------|---------------|
| `project.yml` | XcodeGen config — orientations, deployment target, build settings |
| `AppDelegate.swift` | Boilerplate UIApplicationDelegate, creates UIWindow |
| `GameViewController.swift` | Hosts SKView, presents MenuScene on launch |
| `MenuScene.swift` | Track selection UI — 3 cards, tap to start GameScene |
| `GameScene.swift` | Root game SKScene — world, camera, HUD, touch, game loop |
| `Motorcycle.swift` | Physics/state: speed, heading, lean, position, sprite rotation |
| `InputController.swift` | Converts raw touch offset → `InputState` (throttle/brake/lean 0–1) |
| `TrackConfig.swift` | Struct defining per-track data; 3 static configs (`.classic`, `.speedway`, `.stadium`) |
| `Track.swift` | Draws a track from a `TrackConfig` using SKShapeNode |

---

## Architecture

### Scene Flow
`MenuScene` → (tap card) → `GameScene(size:trackConfig:)` → (tap ‹ Menu) → `MenuScene`

Both transitions use `SKTransition.fade(withDuration: 0.4)`.

### Coordinate conventions
- **World:** SpriteKit standard (Y up). `bikeHeading = 0` → moving in +Y direction.
- **UIKit touch:** Y down. `InputController` receives UIKit coords and flips Y when needed.
- **Camera:** `cameraNode.zRotation = -bikeHeading` keeps the bike always pointing screen-up.

### Motorcycle heading & rotation
- `Motorcycle` node: `zRotation = -bikeHeading` (set each frame in `update`)
- `spriteNode` (child): `zRotation = -leanAngle` (visual lean only)
- Together these make the sprite face its direction of travel with a lean tilt.

### Input → game loop
1. `GameScene` receives `UITouch`, checks if it's on the menu button first
2. Otherwise passes UIKit location + computed center to `InputController.update()`
3. `InputController` computes `InputState` and `touchOffsetInScreen` for HUD dot
4. `GameScene.update()` passes `inputController.state` to `motorcycle.update(dt:input:)`

---

## TrackConfig

Defined in `TrackConfig.swift`. All tracks use `roadWidth: 240` (~3x the original 80pt).

| Track | outerWidth | outerHeight | cornerRadius | Character |
|-------|-----------|------------|-------------|-----------|
| Classic | 1400 | 900 | 280 | Balanced oval, sweeping corners |
| Speedway | 2600 | 750 | 250 | Very long straights, high speed |
| Stadium | 900 | 2200 | 330 | Tall hairpins, technical |

`startPosition` is always the midpoint of the bottom straight: `(0, -outerHeight/2 + roadWidth/2)`.

`TrackConfig.all` is the ordered array used by MenuScene to render cards.

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
| maxX | 170 pt | horizontal axis clamp (square boundary) |
| maxY | 104 pt | vertical axis clamp (square boundary) |

---

## HUD

Drawn as children of `cameraNode` (screen-fixed). Joystick elements are grouped under `joystickNode`.

- **`joystickNode`** — container, positioned at `(0, -joystickYOffset)`. Offset computed in `didChangeSize`: `size.height/2 - 104 - 20` so the bottom edge sits 20pt above the screen bottom.
- **`boundarySquare`** — `340×208` pt rectangle outline (±170 x, ±104 y). Edges = full input.
- **`crosshairNode`** — ±20 pt crosshair at joystick center.
- **`inputDotNode`** — 8 pt radius circle. Position = `touchOffsetInScreen` directly. Green = throttle, red = brake, white = neutral.
- **`menuButton`** — "‹ Menu" label, top-left corner of camera view. Updated each frame to `(-size.width/2 + 20, size.height/2 - 20)`.

---

## Input Scheme (rectangular joystick)

```
dx = touch.x - center.x   (UIKit)
dy = touch.y - center.y   (UIKit, positive = down)
center = (view.midX, view.midY + joystickYOffset)

// Deadzone (circular)
guard hypot(dx, dy) > 10 else { return neutral }

// Rectangular clamp
clampedDx = clamp(dx, -170, 170)
clampedDy = clamp(dy, -104, 104)

lean     = clampedDx / 170         // -1 (left) … +1 (right)
throttle = clampedDy < 0 ? -clampedDy/104 : 0   // finger above center
brake    = clampedDy > 0 ?  clampedDy/104 : 0   // finger below center
```

---

## Orientation & Full-Screen

Portrait only. Set in three places (must all match):
1. `project.yml` → `SUPPORTED_INTERFACE_ORIENTATIONS_IPHONE: UIInterfaceOrientationPortrait`
2. `GameViewController.swift` → `supportedInterfaceOrientations` returns `.portrait`
3. `Info.plist` → `UISupportedInterfaceOrientations: [UIInterfaceOrientationPortrait]`

Full-screen: `loadView()` creates `SKView(frame: UIScreen.main.bounds)`. `Info.plist` has `UILaunchScreen: {}` so iOS doesn't letterbox the app.

---

## Build Notes

- Swift 6 strict concurrency — all game state touched only on the main actor.
- `xcodegen generate` must be re-run after any `project.yml` change.
- No storyboards or XIBs — everything is programmatic.
- New source files must appear in `MotoGame/` directory; XcodeGen picks them up automatically.
