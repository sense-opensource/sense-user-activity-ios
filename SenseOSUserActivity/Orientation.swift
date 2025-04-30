import Foundation
import CoreMotion
import UIKit

//struct MotionData: Codable {
//    var orientationData: OrientationData
//}

struct MotionData: Codable {
    var mode: [String]  // Device orientation
    var proximityData: [String]  // Proximity sensor data
    var tiltPosition: [String]  // Hand position
    var gyroscope: [[String: Double]]  // Gyroscope data
}

class MotionSDK {
    static let shared = MotionSDK() // Singleton Instance
        
    private let motionManager = CMMotionManager()
    private var lastHandPosition: String = "Unknown"
    
    private var motionData = MotionData(
        mode: [],
        proximityData: [],
        tiltPosition: [],
        gyroscope: []
    )


    var onDataUpdate: ((MotionData) -> Void)?
    
    private init() {}

    // Start monitoring all sensors
    func startMonitoring() {
        startDeviceOrientationUpdates()
        startGyroscopeMonitoring()
        startProximityMonitoring()
        startMotionUpdates()  // 🔹 Added motion updates
    }

    // MARK: 📌 Device Orientation
    private func startDeviceOrientationUpdates() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        handleOrientationChange()
    }

    @objc private func handleOrientationChange() {
        let currentOrientation = UIDevice.current.orientation
        var orientationDescription = "Flat orientation"

        switch currentOrientation {
        case .portrait:
            orientationDescription = "Portrait mode"
        case .landscapeLeft:
            orientationDescription = "Landscape Left"
        case .landscapeRight:
            orientationDescription = "Landscape Right"
        case .portraitUpsideDown:
            orientationDescription = "Upside Down"
        default:
            break
        }

        //motionData.orientationData.mode = [orientationDescription]
        motionData.mode.append(orientationDescription)
        sendDataUpdate()
    }

    // MARK: 📌 Hand Position Detection
    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            return
        }

        motionManager.deviceMotionUpdateInterval = 0.2
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] (motion, error) in
            guard let self = self, let motion = motion else {
                return
            }

            let pitch = motion.attitude.pitch * 180 / .pi
            let roll = motion.attitude.roll * 180 / .pi
            
            self.detectHandPosition(pitch: pitch, roll: roll)
        }
    }

    private func detectHandPosition(pitch: Double, roll: Double) {
        var handPosition = "Unknown"

        if pitch > 60 {
            handPosition = "Face Up"
        } else if pitch < -60 {
            handPosition = "Face Down"
        } else if abs(roll) > 30 {
            handPosition = (roll < 0) ? "Screen Tilted Right" : "Screen Tilted Left"
        } else if pitch > 10 {
            handPosition = "Slight Forward Tilt"
        } else if pitch < -10 {
            handPosition = "Slight Backward Tilt"
        }

        if handPosition != lastHandPosition {
            lastHandPosition = handPosition
            motionData.tiltPosition.append(handPosition)
            sendDataUpdate()
        }
    }

    // MARK: 📌 Gyroscope Monitoring
    private func startGyroscopeMonitoring() {
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: OperationQueue.main) { [weak self] (data, error) in
                guard let self = self, let gyroData = data else { return }
                
                let rotationData: [String: Double] = [
                    "x": gyroData.rotationRate.x,
                    "y": gyroData.rotationRate.y,
                    "z": gyroData.rotationRate.z
                ]
                
                self.motionData.gyroscope.append(rotationData)
                self.sendDataUpdate()
            }
        }
    }
    
    // MARK: 📌 Proximity Sensor
    private func startProximityMonitoring() {
        UIDevice.current.isProximityMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(proximityChanged), name: UIDevice.proximityStateDidChangeNotification, object: nil)
    }

    @objc private func proximityChanged(notification: Notification) {
        let proximityState = UIDevice.current.proximityState
        let proximityData = proximityState ? "Something is near the device" : "Nothing is near the device"
        
        motionData.proximityData.append(proximityData)
        sendDataUpdate()
    }

    // Stop all sensors
    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopGyroUpdates()
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    // MARK: 📌 Send Data to Listener
    private func sendDataUpdate() {
        if let motionData = getOrientationDataFn() {
            onDataUpdate?(motionData)
        }
    }
    func getOrientationDataFn() -> MotionData? {
        return motionData
    }
    func getOrientationData() -> [String: Any]? {
        do {
            let jsonData = try JSONEncoder().encode(MotionSDK.shared.getOrientationDataFn())
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])

            return jsonObject as? [String: Any]
        } catch {
            return nil
        }
    }

}
