

import Foundation
import UIKit

public struct KeystrokeData {
    let timestamps: [TimeInterval]
    let typingSpeed: Double
    let backspaces: Int
    let keyTransitionTimes: [TimeInterval]
    let keystrokeRhythms: [TimeInterval]
    let sessionStart: TimeInterval?
    let sessionEnd: TimeInterval?
    let avgDigraphs: TimeInterval?
    let avgTrigraphs: TimeInterval?
}

class KeystrokeTracker: NSObject, UITextFieldDelegate {
    var textField: UITextField?
    var fieldName: Any
    var keyTimestamps: [TimeInterval] = []
    var startTime: TimeInterval?
    var characterCount = 0
    var backspaceCount = 0
    var lastKeyTime: TimeInterval?
    var keyTransitionTimes: [TimeInterval] = []
    var keystrokeRhythms: [TimeInterval] = []
    var sessionStartTime: TimeInterval?
    var sessionEndTime: TimeInterval?
    var lastTwoTimestamps: [TimeInterval] = []
    var lastThreeTimestamps: [TimeInterval] = []
    var avgDigraphs: TimeInterval?
    var avgTrigraphs: TimeInterval?
    
    var onTypingSessionEnd: (([TimeInterval],
      Double,
      Int,
      [TimeInterval],
      [TimeInterval],
      TimeInterval?,
      TimeInterval?,
      TimeInterval?,
      TimeInterval?) -> Void)?
    
    init(textField: UITextField, fieldName: Any) {
        self.textField = textField
        self.fieldName = fieldName
        super.init()
        self.textField?.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        sessionStartTime = Date().timeIntervalSince1970
        keyTimestamps = []
        characterCount = 0
        backspaceCount = 0
        keyTransitionTimes = []
        keystrokeRhythms = []
        lastTwoTimestamps = []
        lastThreeTimestamps = []
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        sessionEndTime = Date().timeIntervalSince1970

        avgDigraphs = keyTransitionTimes.isEmpty ? nil : (keyTransitionTimes.reduce(0, +) / Double(keyTransitionTimes.count))
        avgTrigraphs = keystrokeRhythms.count >= 2 ? (keystrokeRhythms.reduce(0, +) / Double(keystrokeRhythms.count)) : nil

        onTypingSessionEnd?(
            keyTimestamps,
            calculateTypingSpeed(),
            backspaceCount,
            keyTransitionTimes,
            keystrokeRhythms,
            sessionStartTime,
            sessionEndTime,
            avgDigraphs,
            avgTrigraphs
        )
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentTime = Date().timeIntervalSince1970
        keyTimestamps.append(currentTime)
        
        if !string.isEmpty {
            characterCount += string.count
        } else {
            backspaceCount += 1
        }
        
        if let lastTime = lastKeyTime {
            let transitionTime = currentTime - lastTime
            keyTransitionTimes.append(transitionTime) // ✅ Ensure transitions are stored
            keystrokeRhythms.append(transitionTime)
        }
        
        lastKeyTime = currentTime
        return true
    }
    
    private func calculateTypingSpeed() -> Double {
        guard let start = sessionStartTime else { return 0 }
        let elapsedTime = Date().timeIntervalSince1970 - start
        return elapsedTime > 0 ? Double(characterCount) / (elapsedTime / 60) : 0
    }

    func getKeyboardInfo() -> (language: String, layout: String) {
        if let textInputMode = textField?.textInputMode {
            return (textInputMode.primaryLanguage ?? "Unknown", "Default")
        }
        return ("Unknown", "Default")
    }

    func getKeystrokeData() -> [String: Any] {
        return [
            "id": fieldName,
            "keyStroke": [
                "avgTypingSpeed": calculateTypingSpeed(),
                "avgTransitionTime": keyTransitionTimes,
                "keyStrokeRhythms": keystrokeRhythms,
                "sessionStart": sessionStartTime ?? 0.0,
                "sessionEnd": sessionEndTime ?? 0.0,
                "avgTrigraphsTime": avgTrigraphs as Any,
                "avgDigraphsTime": avgDigraphs as Any,
                "keyCounts": ["backspace": backspaceCount],
                "info": ["language": getKeyboardInfo().language, "layout": getKeyboardInfo().layout]
            ]
        ]
    }
    
    static var trackers: [KeystrokeTracker] = []

    static func initKeyStrokeBehaviour(for textFields: [UITextField]) {
        for textField in textFields {
            let tracker = KeystrokeTracker(textField: textField, fieldName: textField.tag)
            trackers.append(tracker)
        }
    }

    static func getKeyStrokes() -> [[String: Any]] {
        return trackers.map { $0.getKeystrokeData() }
    }

    func inferKeyboardLayout(from language: String) -> String {
        switch language {
            case "en-US":
                return "QWERTY"
            case "en-GB":
                return "QWERTY (UK)"
            case "fr":
                return "AZERTY"
            case "fr-FR":
                return "AZERTY"
            case "en-IN":
                return "QWERTY"
            case "fr-BE":
                return "AZERTY (Belgium)"
            case "de":
                return "QWERTZ"
            case "de-CH":
                return "QWERTZ (Swiss)"
            case "de-AT":
                return "QWERTZ (Austrian)"
            case "en-DV":
                return "DVORAK"
            case "en-CM":
                return "COLEMAK"
            case "ja-JP":
                return "JIS (Japanese)"
            case "ja-Kana":
                return "Kana Input (Japanese)"
            case "ko-KR":
                return "Hangul (Korean 2-set)"
            case "ko-Hanja":
                return "Hanja (Korean 3-set)"
            case "ru-RU":
                return "JCUKEN (Cyrillic)"
            case "bg":
                return "Bulgarian Phonetic"
            case "sr-Cyrl":
                return "Serbian Cyrillic"
            case "sr-Latn":
                return "Serbian Latin"
            case "uk-UA":
                return "Ukrainian Keyboard"
            case "ar-SA":
                return "Arabic (101 Layout)"
            case "ar":
                return "Arabic (102 Layout)"
            case "fa-IR":
                return "Persian Keyboard"
            case "ur-PK":
                return "Urdu Keyboard"
            case "he-IL":
                return "Hebrew Keyboard"
            case "el-GR":
                return "Greek Keyboard"
            case "th-TH":
                return "Thai Keyboard"
            case "tr-TR":
                return "Turkish Q Layout"
            case "tr-F":
                return "Turkish F Layout"
            case "cs-CZ":
                return "Czech Keyboard"
            case "hu-HU":
                return "Hungarian Keyboard"
            case "pl-PL":
                return "Polish Keyboard"
            case "ro-RO":
                return "Romanian Keyboard"
            case "pt-BR":
                return "Portuguese (Brazilian ABNT2)"
            case "pt-PT":
                return "Portuguese (Portugal)"
            case "es-419":
                return "Spanish (Latin America)"
            case "es-ES":
                return "Spanish (Spain QWERTY)"
            case "it-IT":
                return "Italian Keyboard"
            case "vi-VN":
                return "Vietnamese Keyboard (Telex, VNI, VIQR)"
            case "en-PROG":
                return "Programmer’s Keyboard"
            case "en-GAME":
                return "Gaming Keyboard"
            case "num":
                return "Numeric Keypad (Numpad)"
            case "one-hand":
                return "One-Handed Keyboards"
            case "brl":
                return "Braille Keyboard"
                
            default:
                return "Unknown Layout"
        }
    }


}
