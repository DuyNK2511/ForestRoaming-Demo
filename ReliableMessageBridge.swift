import Foundation
import WebKit

class ReliableMessageBridge {
    struct Message {
        let id: Int
        let type: String
        let data: String
        var isAcked: Bool = false
    }

    private let webView: WKWebView
    private let maxSeq = 256
    private let windowSize = 16 // Window size have to be < maxSeq / 2
    private let timeoutInterval: TimeInterval = 1.0

    private var sendBase = 0
    private var nextSeqNum = 0
    private var sendBuffer = [Int: Message]()
    private var timers = [Int: Timer]()

    init(webView: WKWebView) {
        self.webView = webView
    }

    func send(type: String, data: String) {
        guard windowDistance(from: nextSeqNum, to: sendBase) < windowSize else {
            print("Window full, cannot send")
            return
        }

        let message = Message(id: nextSeqNum, type: type, data: data)
        sendBuffer[nextSeqNum] = message
        sendToWebView(message)

        startTimer(for: nextSeqNum)
        nextSeqNum = (nextSeqNum + 1) % maxSeq
    }

    func receiveAck(_ ackId: Int) {
        if isInWindow(ackId) {
            sendBuffer[ackId]?.isAcked = true
            stopTimer(for: ackId)

            // slide the window if meet ACK
            while sendBuffer[sendBase]?.isAcked == true {
                sendBuffer.removeValue(forKey: sendBase)
                sendBase = (sendBase + 1) % maxSeq
            }
        }
    }

    private func sendToWebView(_ message: Message) {
        let json = """
        { "id": \(message.id), "type": "\(message.type)", "data": "\(message.data)" }
        """
        webView.evaluateJavaScript("onNativeMessage(\(json))", completionHandler: nil)
    }

    private func startTimer(for id: Int) {
        stopTimer(for: id)
        timers[id] = Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false) { [weak self] _ in
            self?.resendMessage(id)
        }
    }

    private func stopTimer(for id: Int) {
        timers[id]?.invalidate()
        timers.removeValue(forKey: id)
    }

    private func resendMessage(_ id: Int) {
        guard let message = sendBuffer[id], !message.isAcked else { return }
        print("Resending message \(id)")
        sendToWebView(message)
        startTimer(for: id)
    }

    private func isInWindow(_ seq: Int) -> Bool {
        return windowDistance(from: seq, to: sendBase) < windowSize
    }

    private func windowDistance(from a: Int, to b: Int) -> Int {
        return (a - b + maxSeq) % maxSeq
    }
}
