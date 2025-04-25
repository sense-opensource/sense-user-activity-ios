import UIKit

class ScrollMetricsTracker: NSObject, UIScrollViewDelegate {
    
    private weak var scrollView: UIScrollView?
    private var lastScrollY: CGFloat = 0.0
    private var lastTime: TimeInterval = 0.0
    private var scrollPositions: [[String: CGFloat]] = []
    private var scrollSpeeds: [[String: CGFloat]] = []
    private var accelerations: [[String: CGFloat]] = []
    private var directions: [String] = []
    
    init(scrollView: UIScrollView) {
        super.init()
        self.scrollView = scrollView
        self.scrollView?.delegate = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentY = scrollView.contentOffset.y
        let currentTime = Date().timeIntervalSince1970

        if lastTime != 0 {
            let timeDiff = currentTime - lastTime
            let speedY = (currentY - lastScrollY) / CGFloat(timeDiff)
            let accelerationY = (speedY - lastScrollY) / CGFloat(timeDiff)

            scrollSpeeds.append(["x": 0.0, "y": speedY])
            accelerations.append(["x": 0.0, "y": accelerationY])

            let direction: String
            if currentY > lastScrollY {
                direction = "Scrolling Down"
            } else if currentY < lastScrollY {
                direction = "Scrolling Up"
            } else {
                direction = "Static"
            }
            directions.append(direction)
        }
        
        scrollPositions.append(["x": 0.0, "y": currentY])
        lastScrollY = currentY
        lastTime = currentTime
    }
    
    func getScrollDataFn() -> [String: Any] {
        return [
            "scrollPositions": scrollPositions,
            "scrollSpeeds": scrollSpeeds,
            "acceleration": accelerations,
            "direction": directions
        ]
    }
}
