//
//  Config.swift
//  SwiftVoiceMemo
//
//  Created by 王嘉宁 on 2017/9/28.
//  Copyright © 2017年 jianing. All rights reserved.
//

import UIKit

struct Config {
    
    struct Color {
        static var cellColors: [UIColor] {
            return [#colorLiteral(red: 0.3490000069, green: 0.2899999917, blue: 0.6079999804, alpha: 1), #colorLiteral(red: 0.3179999888, green: 0.6389999986, blue: 0.2269999981, alpha: 1), #colorLiteral(red: 0.9176470588, green: 0.3450980392, blue: 0.2470588235, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.6705882353, blue: 0.09019607843, alpha: 1)]
        }
    }
    
    struct Identifier {
        static let mainViewController = "MainViewController"
        static let VoiceListViewController = "VoiceListViewController"
    }
    
    struct Storyboard {
        static var main: UIStoryboard {
            return UIStoryboard(name: "Main", bundle: nil)
        }
    }
    
    struct Size {
        static var screenWidth: CGFloat {
            return UIScreen.main.bounds.width
        }
        
        static var screenHeight: CGFloat {
            return UIScreen.main.bounds.height
        }
        
        static var screenSize: CGSize {
            return UIScreen.main.bounds.size
        }
        
        static var screenFrame: CGRect {
            return CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        }
    }
    
}
