//
//  MainViewController.swift
//  SwiftVoiceMemo
//
//  Created by 王嘉宁 on 2017/9/28.
//  Copyright © 2017年 jianing. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class MainViewController: UIViewController {
    
    // MARK: Properties
    
    /// 提示
    @IBOutlet weak var hintLabel: UILabel!
    /// 时间仪表盘
    @IBOutlet weak var meterLabel: UILabel!
    
    /// 录音按钮
    lazy var recordButton: RecordButton = { [unowned self] in
        let button = RecordButton(frame: Rect((Config.Size.screenWidth - 120) / 2, Config.Size.screenHeight - 200, 120, 120))
        button.setImage(#imageLiteral(resourceName: "main_btn_record"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.bounds.height / 2
        button.delegate = self
        return button
    }()
    
    /// 播放按钮
    lazy var playButton: UIButton = { [unowned self] in
        let button = UIButton(frame: Rect(20, Config.Size.screenHeight + 200, Config.Size.screenWidth - 40, 55))
        button.addTarget(self, action: .play, for: .touchUpInside)
        button.backgroundColor = .white
        button.setTitleColor(#colorLiteral(red: 0, green: 0.4779999852, blue: 1, alpha: 1), for: .normal)
        button.setTitle("播放", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.bounds.height / 2
        return button
    }()
    
    /// 返回按钮
    lazy var backButton: UIButton = { [unowned self] in
        let button = UIButton(frame: Rect(20, Config.Size.screenHeight + 280, Config.Size.screenWidth - 40, 55))
        button.addTarget(self, action: .back, for: .touchUpInside)
        button.backgroundColor = .white
        button.setTitleColor(#colorLiteral(red: 0, green: 0.4779999852, blue: 1, alpha: 1), for: .normal)
        button.setTitle("返回", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.bounds.height / 2
        return button
    }()
    
    /// 录音
    var recorder: AVAudioRecorder!
    /// 播放
    var player:AVAudioPlayer!
    /// 当前文件的 URL
    var soundFileURL: URL!
    /// 当前文件的名称
    var soundFileName: String!
    /// 当前文件的创建时间
    var soundFileTime: Date!
    /// 当前文件的持续时长
    var soundFileDuration: Double!
    /// 仪表盘 Timer
    var meterTimer:Timer!
    
    var managedObjectContext: NSManagedObjectContext!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavi()
        configUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.stop()
    }
    
    
    // MARK: Config
    
    func configNavi() {
        guard let navigationController = self.navigationController else { return }
        
        // 导航栏透明
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.isTranslucent = true
        
        // 设置菜单按钮
        let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        menuButton.setImage(#imageLiteral(resourceName: "main_btn_menu"), for: .normal)
        menuButton.addTarget(self, action: .showList, for: .touchUpInside)
        let menuBarItem = UIBarButtonItem(customView: menuButton)
        navigationItem.rightBarButtonItem = menuBarItem

    }
    
    func configUI() {
        [recordButton, playButton, backButton].forEach {
            self.view.addSubview($0)
        }
    }
    
    /// 显示录音按钮
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
    
    /// 显示播放和返回按钮
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
    
    
    // MARK: AVAudioSession
    
    func recordWithPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] granted in
            if granted {
                DispatchQueue.main.async {
                    self.setSession(with: AVAudioSessionCategoryPlayAndRecord)
                    self.setupRecorder()
                    self.recorder.record()
                    
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                           target: self,
                                                           selector: .updateMeter,
                                                           userInfo: nil,
                                                           repeats: true)
                }
            } else {
                log("无录音权限", .error)
            }
        }
        
        if AVAudioSession.sharedInstance().recordPermission() == .denied {
            log("录音权限被拒绝", .error)
        }
    }
    
    func setupRecorder() {
        let date = Date()
        self.soundFileTime = date
        
        let fileName = String(date.ticks)
        self.soundFileName = "\(fileName).m4a"
        
        self.soundFileURL = getDocumentsDirectoryURL(with: soundFileName)
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: Config.Record.settings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
        } catch {
            recorder = nil
            log(error.localizedDescription, .error)
        }
        
    }
    
    func setSession(with category: String) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(category, with: .defaultToSpeaker)
        } catch {
            log(error.localizedDescription, .error)
        }
        do {
            try session.setActive(true)
        } catch {
            log(error.localizedDescription, .error)
        }
    }
    
    @objc func updateAudioMeter(_ timer:Timer) {
        
        if let recorder = self.recorder {
            if recorder.isRecording {
                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d:%02d", min, sec)
                meterLabel.text = s
                recorder.updateMeters()
            }
        }
    }
    
    func saveSoundFile() {

        let record = Record(context: managedObjectContext)
        record.date = self.soundFileTime! as NSDate
        record.name = self.soundFileName
        record.duration = self.soundFileDuration
        record.id = UUID().uuidString
        
        do {
            try managedObjectContext.save()
            log("saving...")
        } catch {
            log(error.localizedDescription, .error)
        }
    }
    
    
    // MARK: Button Action
    
    @objc func showVoiceListViewController() {
        guard let navigationController = self.navigationController else { return }
        let storyboard = Config.Storyboard.main
        let voiceListViewController = storyboard.instantiateViewController(withIdentifier: Config.Identifier.voiceListViewController) as! VoiceListViewController
        voiceListViewController.managedObjectContext = managedObjectContext
        navigationController.pushViewController(voiceListViewController, animated: true)
    }
    
    @objc func playButtonTapped(_ button: UIButton) {
        var url:URL?
        if self.recorder != nil {
            url = self.recorder.url
        } else {
            url = self.soundFileURL!
        }
        log("播放 \(String(describing: url))")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url!)
            playButton.isEnabled = false
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch {
            self.player = nil
            log(error.localizedDescription, .error)
        }
    }
    
    @objc func backButtonTapped(_ button: UIButton) {
        log("返回")
        showRecordButton()
        self.hintLabel.text = "长按录音"
        self.meterLabel.text = ""
        if player != nil && player.isPlaying {
            log("结束播放")
            player.stop()
        }
    }

}

extension MainViewController: RecordButtonDelegate {
    
    func recordButtonDidStartLongPress(_ button: RecordButton) {
        log("Long Press began")
        hintLabel.text = "录音中..."
        recordWithPermission()
    }
    
    func recordButtonDidStopLongPress(_ button: RecordButton) {
        log("Long Press stop")
        print(recorder.currentTime)
        self.soundFileDuration = recorder.currentTime as Double
        
        recorder?.stop()
        player?.stop()
        meterTimer.invalidate()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch {
            log(error.localizedDescription, .error)
        }
        
    }
}

// MARK: AVAudioRecorderDelegate
extension MainViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        hintLabel.text = "已保存录音"
        playButton.setTitle("播放 \(soundFileName ?? "")", for: .normal)
        showPlayButton()
        saveSoundFile()
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            log("\(error.localizedDescription)", .error)
        }
    }
    
}

// MARK: AVAudioPlayerDelegate
extension MainViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        log("播放结束")
        playButton.isEnabled = true
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            log("\(error.localizedDescription)", .error)
        }
    }
}

fileprivate extension Selector {
    static let showList = #selector(MainViewController.showVoiceListViewController)
    static let play = #selector(MainViewController.playButtonTapped)
    static let back = #selector(MainViewController.backButtonTapped)
    static let updateMeter = #selector(MainViewController.updateAudioMeter)
}

