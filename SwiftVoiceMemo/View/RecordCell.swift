//
//  RecordCell.swift
//  SwiftVoiceMemo
//
//  Created by 王嘉宁 on 2017/10/1.
//  Copyright © 2017年 jianing. All rights reserved.
//

import UIKit

protocol PlayButtonProtocol {
    func playButtonTapped(_ id: String)
}

class RecordCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topBackView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playingLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    
    fileprivate var id: String!
    
    var delegate: PlayButtonProtocol?
    
    var color: UIColor = .black {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.topBackView.backgroundColor = self.color
                self.playButton.backgroundColor = self.color
            }
        }
    }
    
    /// 正在播放
    var isPlaying: Bool = false {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.playingLabel.alpha = self.isPlaying == true ? 1 : 0
                let title = self.isPlaying == true ? "暂停" : "播放"
                self.playButton.setTitle(title, for: .normal)
            }
        }
    }
    
    /// 正在播放时暂停
    var isPausing: Bool = false {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                let title = self.isPausing == true ? "播放" : "暂停"
                self.playButton.setTitle(title, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 10
        playButton.layer.masksToBounds = true
        playButton.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        if isPlaying == false {
            isPlaying = true
        } else {
            isPausing = !isPausing
        }
        
        delegate?.playButtonTapped(self.id)
        
    }
    
    func configure(with record: Record) {
        self.id = record.id
        self.nameLabel.text = record.name
        
        let min = Int(record.duration / 60)
        let sec = Int(record.duration.truncatingRemainder(dividingBy: 60))
        let durationString = String(format: "%02d:%02d", min, sec)
        self.durationLabel.text = durationString
        
        let format = DateFormatter()
        format.dateFormat = "yyyy.MM.dd HH:mm:ss"
        self.timeLabel.text = "\(format.string(from: record.date as Date))"
        
    }
    
}
