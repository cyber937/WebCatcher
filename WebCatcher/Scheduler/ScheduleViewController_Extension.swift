//
//  ScheduleViewController_CaptureSiteGroupListExtension.swift
//  WebCatcher
//
//  Created by Kiyoshi on 11/8/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Cocoa

extension ScheduleViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return captureSiteGroups.count
    }
}

extension ScheduleViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellIdentifier: String = ""
        
        if tableColumn == tableView.tableColumns[0] {
            cellIdentifier = "Group Title"
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? CaptureSiteGroupListCellView {
                cell.textField?.stringValue = captureSiteGroups[row].groupName
                cell.row = row
                cell.deligate = self
                return cell
            }
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard captureSiteGroupListView.selectedRow >= 0 else {
            captureSiteGroupAddRemoveSegment.setEnabled(false, forSegment: 1)
            return
        }
        
        captureSiteGroupAddRemoveSegment.setEnabled(true, forSegment: 1)
    }
}

extension ScheduleViewController: CaptureSiteGroupViewControllerDelegate {
    func addCaptureSiteGroup(_ captureSiteGroup: CaptureSiteGroup) {
        captureSiteGroups.append(captureSiteGroup)
        captureSiteGroupListView.reloadData()
    }
    
    func updateCaptureSiteGroup(_ captureSiteGroup: CaptureSiteGroup, row: Int) {
        captureSiteGroups[row] = captureSiteGroup
        captureSiteGroupListView.reloadData()
    }
}

extension ScheduleViewController: CaptureSiteGroupListCellViewDelegate {
    func startEditingCaptureSiteGroupWithRow(_ row: Int) {
        let mainStoryBoard = NSStoryboard(name: "Main", bundle: nil)
        let captureSiteGroupViewController = mainStoryBoard.instantiateController(withIdentifier: "CaptureSiteGroupViewController") as! CaptureSiteGroupViewController
        captureSiteGroupViewController.delegate = self
        captureSiteGroupViewController.captureSiteGroup = captureSiteGroups[row]
        captureSiteGroupViewController.row = row
        self.presentAsSheet(captureSiteGroupViewController)
    }
}
