//
//  MainViewController.swift
//  SwiftVoiceMemo
//
//  Created by 王嘉宁 on 2017/9/28.
//  Copyright © 2017年 jianing. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    // MARK: Properties
    
    var recorder: AVAudioRecorder!
    var player:AVAudioPlayer!
    
    @IBOutlet weak var hintLabel: UILabel!
    
    lazy var recordButton: RecordButton = { [unowned self] in
        let button = RecordButton(frame:
            CGRect(x: (Config.Size.screenWidth - 120) / 2,
                   y: Config.Size.screenHeight - 200,
                   width: 120,
                   height: 120))
        button.setImage(UIImage.init(named: "main_btn_record"), for: .normal) // Why can't I use #imageLiteral(resourceName: "main_btn_record@2x.png") ?
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.bounds.height / 2
        button.delegate = self
        return button
    }()
    
    lazy var playButton: UIButton = { [unowned self] in
        let button = UIButton(frame:
            CGRect(x: 20,
                   y: Config.Size.screenHeight + 200,
                   width: Config.Size.screenWidth - 40,
                   height: 55))
        button.addTarget(self, action: .play, for: .touchUpInside)
        button.backgroundColor = .white
        button.setTitleColor(#colorLiteral(red: 0, green: 0.4779999852, blue: 1, alpha: 1), for: .normal)
        button.setTitle("播放", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.bounds.height / 2
        return button
    }()
    
    lazy var backButton: UIButton = { [unowned self] in
        let button = UIButton(frame:
            CGRect(x: 20,
                   y: Config.Size.screenHeight + 280,
                   width: Config.Size.screenWidth - 40,
                   height: 55))
        button.addTarget(self, action: .back, for: .touchUpInside)
        button.backgroundColor = .white
        button.setTitleColor(#colorLiteral(red: 0, green: 0.4779999852, blue: 1, alpha: 1), for: .normal)
        button.setTitle("返回", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.bounds.height / 2
        return button
    }()
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavi()
        configUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Config
    
    func configNavi() {
        if let navigationController = self.navigationController {
            // navigation bar translucent
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController.navigationBar.shadowImage = UIImage()
            navigationController.navigationBar.isTranslucent = true
            
            // set up menu button
            let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            menuButton.setImage(UIImage.init(named: "main_btn_menu"), for: .normal)
            menuButton.addTarget(self, action: .showList, for: .touchUpInside)
            let menuBarItem = UIBarButtonItem(customView: menuButton)
            navigationItem.rightBarButtonItem = menuBarItem
            
        }
    }
    
    func configUI() {
        [recordButton, playButton, backButton].forEach {
            self.view.addSubview($0)
        }
        
        
    }
    
    func showRecordButton() {
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseIn, animations: {
            self.recordButton.center.y += 100
            self.recordButton.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
            self.playButton.center.y += 400
            self.playButton.alpha = 0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.backButton.center.y += 400
            self.backButton.alpha = 0
        }, completion: nil)
    }
    
    func showPlayButton() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.recordButton.center.y -= 100
            self.recordButton.alpha = 0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
            self.playButton.center.y -= 400
            self.playButton.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseOut, animations: {
            self.backButton.center.y -= 400
            self.backButton.alpha = 1
        }, completion: nil)

    }
    
    
    // MARK: Button Action
    
    @objc func showVoiceListViewController() {
        guard let navigationController = self.navigationController else { return }
        let storyboard = Config.Storyboard.main
        let voiceListViewController = storyboard.instantiateViewController(withIdentifier: Config.Identifier.VoiceListViewController)
        navigationController.pushViewController(voiceListViewController, animated: true)
    }
    
    @objc func recordButtonTapped(_ button: UIButton) {

    }
    
    @objc func playButtonTapped(_ button: UIButton) {
        log("播放")
    }

    @objc func backButtonTapped(_ button: UIButton) {
        log("返回")
        showRecordButton()
        self.hintLabel.text = "长按录音"
    }
    
    
}

extension MainViewController: RecordButtonDelegate {
    
    func recordButtonDidStartLongPress(_ button: RecordButton) {
        log("Long Press began")
        hintLabel.text = "录音中..."
    }
    
    func recordButtonDidStopLongPress(_ button: RecordButton) {
        log("Long Press cancelled")
        hintLabel.text = "录音完成"
        showPlayButton()
    }
    
    
}

fileprivate extension Selector {
    static let showList = #selector(MainViewController.showVoiceListViewController)
    static let record = #selector(MainViewController.recordButtonTapped)
    static let play = #selector(MainViewController.playButtonTapped)
    static let back = #selector(MainViewController.backButtonTapped)
//    static let longPress = #selector(MainViewController.longPress)

}

