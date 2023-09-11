//
//  WebURLTableController.swift
//  WebCatcher
//
//  Created by Kiyoshi on 10/23/18.
//  Copyright © 2018 Digital Bytes Inc. All rights reserved.
//

import Cocoa

protocol CaptureSiteGroupViewControllerDelegate {
    func addCaptureSiteGroup(_ captureSiteGroup: CaptureSiteGroup)
    func updateCaptureSiteGroup(_ captureSiteGroup: CaptureSiteGroup, row: Int)
}

class CaptureSiteGroupViewController: NSViewController {

    @IBOutlet weak var groupTitle: NSTextField!
    @IBOutlet weak var captureSiteList: NSTableView!
    @IBOutlet weak var captureSiteAddRemobeSegment: NSSegmentedControl!
    @IBOutlet weak var controlCreateButton: NSButton!
    @IBOutlet weak var controlUpdateButton: NSButton!
    
    var row: Int?
    var captureSiteGroup: CaptureSiteGroup?
    
    var delegate: CaptureSiteGroupViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let captureSiteGroup = self.captureSiteGroup else {
            groupTitle.stringValue = "Untitle Site Group"
            controlUpdateButton.isHidden = true
            self.captureSiteGroup = CaptureSiteGroup(groupName: groupTitle.stringValue)
            return
        }
        
        groupTitle.stringValue = captureSiteGroup.groupName
        controlCreateButton.isHidden = true
        self.captureSiteGroup = captureSiteGroup
    }
    
    @IBAction func pushCaptureSiteAddRemoveSegment(_ sender: NSSegmentedCell) {
        switch sender.selectedSegment {
        case 0:
            addCaptureSite()
        case 1:
            removeCaptureSite()
        default:
            break
        }
    }
    
    private func addCaptureSite() {
        guard let newURL = URL(string: "https://www.google.com") else { return }
        let captureSite = CaptureSite(siteName: "Untitle", url: newURL)
        captureSiteGroup?.captureSites.append(captureSite)
        captureSiteList.reloadData()
    }
    
    private func removeCaptureSite() {
        captureSiteGroup?.captureSites.remove(at: captureSiteList.selectedRow)
        captureSiteList.reloadData()
        captureSiteAddRemobeSegment.setEnabled(false, forSegment: 1)
    }
    
    @IBAction func pushControlCreateButton(_ sender: Any) {
        captureSiteGroup?.groupName = groupTitle.stringValue
        delegate?.addCaptureSiteGroup(captureSiteGroup!)
        self.dismiss(nil)
    }

    @IBAction func pushControlUpdateButton(_ sender: Any) {
        captureSiteGroup?.groupName = groupTitle.stringValue
        delegate?.updateCaptureSiteGroup(captureSiteGroup!, row: row!)
        self.dismiss(nil)
    }
    
    @IBAction func pushControlCancelButton(_ sender: Any) {
        self.dismiss(nil)
    }
}

extension CaptureSiteGroupViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let captureSiteGroup = captureSiteGroup else { return 0 }
        return captureSiteGroup.captureSites.count
    }
    
    func tableView(_ tableView: NSTableView,
                   shouldEdit tableColumn: NSTableColumn?,
                   row: Int) -> Bool {
        
        return true
    }
}

extension CaptureSiteGroupViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    
        guard let captureSiteGroup = captureSiteGroup else { return nil }
        
        var cellIdentifier: String = ""
        
        if tableColumn == tableView.tableColumns[0] {
            cellIdentifier = "URL"
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = captureSiteGroup.captureSites[row].url.absoluteString
                cell.textField?.delegate = self
                cell.textField?.identifier = NSUserInterfaceItemIdentifier(rawValue: "URL")
                return cell
            }
            
        } else {
            cellIdentifier = "Name"
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = captureSiteGroup.captureSites[row].siteName
                cell.textField?.delegate = self
                cell.textField?.identifier = NSUserInterfaceItemIdentifier(rawValue: "Name")
                return cell
            }
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard captureSiteList.selectedRow >= 0 else {
            captureSiteAddRemobeSegment.setEnabled(false, forSegment: 1)
            return
        }
        
        captureSiteAddRemobeSegment.setEnabled(true, forSegment: 1)
    }
}

extension CaptureSiteGroupViewController: NSTextFieldDelegate {
    
        func controlTextDidEndEditing(_ obj: Notification) {
            
            guard let editedTextField = obj.object as? NSTextField,
                let cellView = editedTextField.superview as? NSTableCellView,
                let identifier = cellView.identifier?.rawValue else { return }
            
            if identifier == "URL" {
                let newURL = URLWithHTTPProtocolValidate(urlString: editedTextField.stringValue)
                editedTextField.stringValue = newURL!.absoluteString
                captureSiteGroup?.captureSites[captureSiteList.selectedRow].url = newURL!
            } else {
                captureSiteGroup?.captureSites[captureSiteList.selectedRow].siteName = editedTextField.stringValue
            }
        }
}
