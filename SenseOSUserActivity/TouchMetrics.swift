import UIKit

class TouchscreenTracker: NSObject {
    
    private weak var view: UIView?
    private var pressureLevels: [Float] = []
    private var tapBehavior: [TimeInterval] = []
    private var holdPatterns: [String] = []
    private var swipeSpeeds: [[String: CGFloat]] = []
    private var swipeDurations: [TimeInterval] = []
    private var swipeDirections: [String] = []
    private var rotationAngles: [CGFloat] = []
    private var pinchGestures: [CGFloat] = []
    private var handedness: [String] = []
    
    private var lastTapTime: TimeInterval = 0
    private var lastSwipeTime: TimeInterval = 0
    private var totalRotation: CGFloat = 0  // Store accumulated rotation
    private var isForceTouchAvailable: Bool = false
    
    init(view: UIView) {
        super.init()
        self.view = view
        self.isForceTouchAvailable = view.traitCollection.forceTouchCapability == .available
        setupGestureRecognizers()
    }
    func initTouch(view: UIView) {
        self.view = view
        setupTouchTracking()
    }
    private func setupTouchTracking() {
        guard let view = self.view else { return }
        view.isUserInteractionEnabled = true  // Enable touch events
    }


    
    private func setupGestureRecognizers() {
            guard let view = self.view else { return }
            view.isUserInteractionEnabled = true

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            view.addGestureRecognizer(tapGesture)

            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            view.addGestureRecognizer(longPressGesture)

            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            view.addGestureRecognizer(panGesture)
            panGesture.isEnabled = true

            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            view.addGestureRecognizer(pinchGesture)
            
            let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))  // New!
            view.addGestureRecognizer(rotationGesture)
        }

        @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
            let tapTime = Date().timeIntervalSince1970
            let duration = tapTime - lastTapTime
            lastTapTime = tapTime
            tapBehavior.append(duration * 1000)
        }

        @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                holdPatterns.append("Long Press Detected")
            }
        }

    @objc private func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: gesture.view)

        let swipeTime = Date().timeIntervalSince1970
        let duration = swipeTime - lastSwipeTime
        lastSwipeTime = swipeTime
        swipeDurations.append(duration * 1000)

        let direction = getSwipeDirection(velocityX: velocity.x, velocityY: velocity.y)

        swipeSpeeds.append(["x": velocity.x, "y": velocity.y])
        swipeDirections.append(direction)
        handedness.append(velocity.x > 0 ? "Right-Handed Use" : "Left-Handed Use")
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        pinchGestures.append(gesture.scale)
    }

    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        if gesture.state == .began {
            totalRotation = 0  // Reset when gesture starts
        } else if gesture.state == .changed || gesture.state == .ended {
            totalRotation += gesture.rotation * (180 / .pi)  // Convert to degrees
            rotationAngles.append(CGFloat(Int(totalRotation)))  // Store as Integer
            gesture.rotation = 0  // Reset to avoid duplicate increments
        }
    }

    private func getSwipeDirection(velocityX: CGFloat, velocityY: CGFloat) -> String {
        if abs(velocityX) > abs(velocityY) {
            return velocityX > 0 ? "Right" : "Left"
        } else {
            return velocityY > 0 ? "Down" : "Up"
        }
    }
    func trackPressure(from touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        if isForceTouchAvailable {
            // Older iPhones with 3D Touch
            let pressure = touch.force / touch.maximumPossibleForce
            pressureLevels.append(Float(pressure))
        } else {
            // Newer iPhones (Fallback: Use touch size as a proxy for pressure)
            let touchSize = touch.majorRadius
            let normalizedPressure = min(max(Float(touchSize / 30.0), 0), 1)  // Normalize between 0-1
            pressureLevels.append(normalizedPressure)
        }
    }

    func getTouchscreenData() -> [String: Any] {
        return [
            "name": "Touchscreen Pressure and Gestures",
            "data": [
                "pressureLevels": pressureLevels,
                "tapBehaviour": tapBehavior.map { "\($0) ms" },
                "holdPatterns": holdPatterns,
                "swipeDynamics": [
                    "speed": swipeSpeeds,
                    "duration": swipeDurations.map { "\($0) ms" },
                    "direction": swipeDirections
                ],
                "multiTouchGestures": [
                    "rotation": rotationAngles.map { "\($0)°" },
                    "pinchGesture": pinchGestures
                ],
                "handedness": handedness
            ]
        ]
    }

}
class TouchTrackingView: UIView {
    var tracker: TouchscreenTracker?

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        tracker?.trackPressure(from: touches)
    }
}
