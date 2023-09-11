//
//  ViewController.swift
//  WebCatcher
//
//  Created by Kiyoshi Nagahama on 9/29/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Cocoa
import WebKit

//
// Main UI Controller
//

class WebCatcherController: NSViewController {

    @IBOutlet weak var scheduleView: NSTableView!
    
    let webSnapshotsOperationQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(dataLoaded), name: .archivedScheduleDataLoaded, object: nil)
    }
    
    @objc func dataLoaded() {
        scheduleView.reloadData()
    }
    
    @IBAction func pushAddButton(_ sender: Any) {
        let scheduleViewController =  self.storyboard?.instantiateController(withIdentifier: "ScheduleViewController") as! ScheduleViewController
        self.presentAsSheet(scheduleViewController)
    }
}

extension WebCatcherController: ScheduleCellViewDelegate {
    func startSchedule(row: Int) {
        
        let scheduleController = PersistantData.sharedInstance.scheduleControllers[row]
        
        guard let nextDate = scheduleController.nextDate() else {
            print("Error: Cannot Start Schedule")
            return
        }
        
        let dateInterval = DateInterval(start: Date(), end: nextDate)
        let queue = DispatchQueue(label: "tv.digitalbytes.WebCatcher.queue.\(scheduleController.schedule.uuid.uuidString)")
        scheduleController.timer = DispatchSource.makeTimerSource(queue: queue)
        scheduleController.timer?.schedule(deadline: .now() + .seconds(Int(dateInterval.duration)), repeating: .seconds(scheduleController.activityInterval()))
        
        scheduleController.timer?.setEventHandler {
            
            self.presentSnapshotProcessViewController(scheduleController: scheduleController, testURL: nil)
            
        }
        
        scheduleController.timer?.resume()
        
    }
    
    func editSchedule(row: Int) {
        let scheduleViewController =  self.storyboard?.instantiateController(withIdentifier: "ScheduleViewController") as! ScheduleViewController
        scheduleViewController.scheduleController = PersistantData.sharedInstance.scheduleControllers[row]
        self.presentAsSheet(scheduleViewController)
    }
    
    func removeSchedule(row: Int) {
        PersistantData.sharedInstance.scheduleControllers[row].cancelTimer()
        PersistantData.sharedInstance.scheduleControllers.remove(at: row)
        DataHandler().savingSetting()
        scheduleView.reloadData()
    }
    
    func excuteCaptureSiteGroupProcess() {
        print("Test")
    }
    
    func testSchedule(row: Int) {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["jpg"]
        let i = savePanel.runModal()
        if (i == NSApplication.ModalResponse.OK){
            guard let testFileURL = savePanel.url else { return }
            self.presentSnapshotProcessViewController(scheduleController: PersistantData.sharedInstance.scheduleControllers[row], testURL: testFileURL)
        }
    }
    
    func presentSnapshotProcessViewController(scheduleController: ScheduleController, testURL: URL?) {
        DispatchQueue.main.async {
            let snapshotProcessViewController =  self.storyboard?.instantiateController(withIdentifier: "SnapshotProcessViewController") as! SnapshotProcessViewController
            snapshotProcessViewController.scheduleController = scheduleController
            snapshotProcessViewController.testURL = testURL
            self.presentAsSheet(snapshotProcessViewController)
        }
    }
}
