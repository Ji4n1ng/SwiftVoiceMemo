//
//  RecordButton.swift
//  SwiftVoiceMemo
//
//  Created by 王嘉宁 on 2017/9/30.
//  Copyright © 2017年 jianing. All rights reserved.
//

import UIKit

@objc public protocol RecordButtonDelegate {
    func recordButtonDidStartLongPress(_ button : RecordButton)
    func recordButtonDidStopLongPress(_ button: RecordButton)
}

open class RecordButton: UIButton {
    
    open weak var delegate : RecordButtonDelegate?
    
    fileprivate var longPressRecognizer : UILongPressGestureRecognizer!

    // MARK: Initializers
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        commonInit()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RecordButton.handleLongPress(_:)))
        longPressRecognizer.cancelsTouchesInView = false
        longPressRecognizer.minimumPressDuration = 0.3
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc fileprivate func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if (recognizer.state == .began) {
            delegate?.recordButtonDidStartLongPress(self)
        } else if (recognizer.state == .ended) {
            delegate?.recordButtonDidStopLongPress(self)
        }
    }
    
}

