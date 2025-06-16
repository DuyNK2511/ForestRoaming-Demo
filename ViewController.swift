import UIKit
import WebKit
import CoreMotion

class ViewController: UIViewController {
    var bridge: ReliableMessageBridge!
    var motionManager = CMMotionManager()
    var isTouching = false
    var sendInterval: TimeInterval = 0.1 

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup WebView
        let contentController = WKUserContentController()
        contentController.add(self, name: "iosBridge")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(frame: view.bounds, configuration: config)
        view.addSubview(webView)

        // Setup bridge
        bridge = ReliableMessageBridge(webView: webView)

        // Load WebGL app
        if let url = URL(string: "https://duynk2511.github.io/ForestRoamingWebGL/") {
            webView.load(URLRequest(url: url))
        }

        // Theo dõi nghiêng thiết bị
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = sendInterval
            motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
                if let attitude = motion?.attitude {
                    let tiltData = [
                        "pitch": attitude.pitch,
                        "roll": attitude.roll,
                        "yaw": attitude.yaw
                    ]
                    if let jsonData = try? JSONSerialization.data(withJSONObject: tiltData),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        self.bridge.enqueueMessage(type: "tilt", data: jsonString)
                    }
                }
            }
        }

        // Gửi trạng thái chạm định kỳ
        Timer.scheduledTimer(withTimeInterval: sendInterval, repeats: true) { _ in
            self.bridge.enqueueMessage(type: "touch", data: self.isTouching ? "1" : "0")
        }
    }

    // Touch tracking
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
    }
}

    // Handle Message received from webgl APP
    extension ViewController: WKScriptMessageHandler {
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "iosBridge",
               let body = message.body as? [String: Any] {
                bridge.receiveFromWeb(json: body)
            }
        }
    }
