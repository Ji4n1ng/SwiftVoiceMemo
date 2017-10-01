//
//  VoiceListViewController.swift
//  SwiftVoiceMemo
//
//  Created by 王嘉宁 on 2017/9/28.
//  Copyright © 2017年 jianing. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class VoiceListViewController: UITableViewController {
    
    // MARK: Properties
    
    var managedObjectContext: NSManagedObjectContext!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Record> = {
        let fetchRequest = NSFetchRequest<Record>()
        
        let entity = Record.entity()
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: "Records")
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    /// tableView 背景
    lazy var backImageView: UIImageView = {
        let imageView = UIImageView(frame: Config.Size.screenFrame)
        imageView.image = UIImage(named: "mine_background")
        return imageView
    }()
    
    /// 当前播放 cell 的 id
    var currentPlayingCellId = ""
    /// 当前播放的歌曲暂停了
    var isPausing: Bool = false
    
    var player: AVAudioPlayer!
    
    
    // MARK: Lifecycle
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavi()
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performFetch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPlaying()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: Config
    
    func configNavi() {
        guard let navigationController = self.navigationController else { return }
        
        // 设置边缘返回
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        // 设置返回按钮
        let backButton = UIButton(frame: CGRect(x:0, y:0, width:30, height:30))
        backButton.setImage(UIImage(named: "mine_btn_back"), for: .normal)
        backButton.addTarget(self, action: .back, for: .touchUpInside)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        let menuBarItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = menuBarItem
        
        // 标题字体颜色
        navigationController.navigationBar.titleTextAttributes =
            [ NSAttributedStringKey.foregroundColor: UIColor.white,
              NSAttributedStringKey.font: UIFont.systemFont(ofSize: 21)]
        
        navigationItem.title = Config.Title.mine
        
    }
    
    func configUI() {
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.rowHeight = 160
        
        tableView.backgroundView = backImageView
        tableView.register(UINib(nibName: Config.Cell.record, bundle: Bundle.main), forCellReuseIdentifier: Config.Cell.record)
    }
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            log(error.localizedDescription, .error)
        }
    }
    
    func stopPlaying() {
        currentPlayingCellId = ""
        isPausing = false
        tableView.reloadData()
    }
    
    // MARK: Button Action
    
    @objc func backButtonTapped() {
        guard let navigationController = self.navigationController else { return }
        navigationController.popViewController(animated: true)
    }
    
    
    // MARK: - TableView data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(RecordCell.self)
        cell.delegate = self
        let record = fetchedResultsController.object(at: indexPath)
        cell.configure(with: record)
        
        if record.id == currentPlayingCellId {
            cell.isPlaying = true
            cell.isPausing = self.isPausing
        } else {
            cell.isPlaying = false
        }
        
        cell.color = Config.Color.cellColors[indexPath.row % Config.Color.cellColors.count]
        
        return cell
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension VoiceListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        log("controllerWillChangeContent", .json)
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            log("*** NSFetchedResultsChangeInsert (object)", .json)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            log("*** NSFetchedResultsChangeDelete (object)", .json)
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            log("*** NSFetchedResultsChangeUpdate (object)", .json)
            if let cell = tableView.cellForRow(at: indexPath!) as? RecordCell {
                let record = controller.object(at: indexPath!) as! Record
                cell.configure(with: record)
            }
            
        case .move:
            log("*** NSFetchedResultsChangeMove (object)", .json)
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            log("*** NSFetchedResultsChangeInsert (section)", .json)
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            log("*** NSFetchedResultsChangeDelete (section)", .json)
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            log("*** NSFetchedResultsChangeUpdate (section)", .json)
        case .move:
            log("*** NSFetchedResultsChangeMove (section)", .json)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        log("*** controllerDidChangeContent", .json)
        tableView.endUpdates()
    }
}

// MARK: PlayButtonProtocol
extension VoiceListViewController: PlayButtonProtocol {
    
    func playButtonTapped(_ id: String) {
        
        if self.currentPlayingCellId == id && self.isPausing == false {
            // 当前正在播放，而且没有暂停，说明需要暂停
            self.isPausing = true
            self.player.pause()
            return
        } else if self.currentPlayingCellId == id && self.isPausing == true {
            // 当前正在播放，而且暂停，说明需要播放
            self.isPausing = false
            self.player.play()
            return
        }
        
        // 当前没有播放，说明需要初始化播放
        self.currentPlayingCellId = id
        
        var url = URL.init(string: "")
        for object in fetchedResultsController.fetchedObjects! {
            if object.id == id {
                let fileName = object.name
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                url = documentsDirectory.appendingPathComponent(fileName)
            }
        }
        log(url, .url)
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url!)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch {
            self.player = nil
            log(error.localizedDescription, .error)
        }
    }
}

// MARK: AVAudioPlayerDelegate
extension VoiceListViewController : AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        log("播放结束")
        stopPlaying()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            log("\(error.localizedDescription)", .error)
        }
    }
}

fileprivate extension Selector {
    static let back = #selector(VoiceListViewController.backButtonTapped)
}

extension VoiceListViewController: UIGestureRecognizerDelegate {
    
    // 设置边缘返回手势
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

