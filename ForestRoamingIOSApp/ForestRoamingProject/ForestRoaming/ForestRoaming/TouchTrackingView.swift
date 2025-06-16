//
//  TouchTrackingView.swift
//  ForestRoaming
//
//  Created by xr on 16/6/25.
//
import UIKit

class TouchTrackingView: UIView {
    var onTouchChanged: ((Bool) -> Void)?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTouchChanged?(true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTouchChanged?(false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTouchChanged?(false)
    }
}
