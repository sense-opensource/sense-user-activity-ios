


import Foundation
import UIKit
import CoreTelephony
import CoreLocation
import Network
import SystemConfiguration.CaptiveNetwork
import LocalAuthentication
import AVFoundation
import MediaPlayer
import CoreBluetooth

@objc public protocol SenseOSDelegate {
    func onFailure(message: String)
    func onSuccess(data: String)
}

let sense = SenseOS()
public class SenseOS: NSObject{
    private static var senseConfig: SenseOSConfig?
    static var delegate: SenseOSDelegate?
    static var behaviourDelegate: SenseOSDelegate?
    private static var scrollTrackers: [UIScrollView: ScrollMetricsTracker] = [:]
    private static var touchscreenTracker: TouchscreenTracker?
    let motionSDK = MotionSDK.shared
    
    public override init() {
        motionSDK.onDataUpdate = { jsonString in
        }
        motionSDK.startMonitoring()
    }
    
    static func isEmpty(value: String?) -> Bool {
        return value == nil || trimValue(value: value!) == "";
    }
    static func trimValue(value: String) -> String {
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func clearNil(value: String?) -> String {
        return value == nil ? "": trimValue(value: value!)
    }
    
    public static func initSDK(senseConfig: SenseOSConfig?, withDelegate: SenseOSDelegate?) {
        self.delegate = withDelegate
        self.senseConfig = senseConfig
    }
    
    public static func getScrollData() -> [Any] {
        return scrollTrackers.values.map { $0.getScrollDataFn() }
    }
    
    public static func initKeyStrokeBehaviour(for textFields: [UITextField]){
        KeystrokeTracker.initKeyStrokeBehaviour(for: textFields)
    }
    public static func initScrollBehaviour(for scrollViews: [UIScrollView]) {
        for scrollView in scrollViews {
            let tracker = ScrollMetricsTracker(scrollView: scrollView)
            scrollTrackers[scrollView] = tracker
        }
    }
    public static func initTouchBehaviour(for view: UIView){
        touchscreenTracker = TouchscreenTracker(view: view)
    }
    
    public static func getBehaviourData(withDelegate behaviourDelegate: SenseOSDelegate?) {
        self.delegate = behaviourDelegate
        let body: [String: Any] = [
            "platform": "ios",
            "behaviour": [
                "keyStrokeData": KeystrokeTracker.getKeyStrokes(),
                "orientationData": MotionSDK.shared.getOrientationData() as Any,
                "touchScreenData": touchscreenTracker?.getTouchscreenData() ?? [:],
                "scrollMetrics": getScrollData()
            ],
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            behaviourDelegate?.onSuccess(data: jsonString)
        } else {
            behaviourDelegate?.onFailure(message: "Failed to serialize data")
        }
    }
}





