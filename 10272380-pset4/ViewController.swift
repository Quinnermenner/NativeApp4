//
//  ViewController.swift
//  10272380-pset4
//
//  Created by Quinten van der Post on 22/11/2016.
//  Copyright © 2016 Quinten van der Post. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addToDo: UITextField!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    var selectedIndexPath: IndexPath?
    var extraHeight: CGFloat?
    
    
    
    @IBAction func addButton(_ sender: Any) {
        if let text = addToDo.text, !text.isEmpty {
            do {
                try db?.create(title: addToDo.text!,    description: "I'm a description.", done: false)
                tableView.reloadData()
                addToDo.text = ""
                addToDo.endEditing(true)
            } catch {
                print(error)
            }
        }
    }
    
    let db = DataBaseHelper()
    var todoList = Array<Row>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
        
       if db == nil {
            print("DB error")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeToDo(index: Int) {
        
        do {
            try db?.deleteIndex(index: index)
        } catch {
            print(error)
        }
        
    }
    func todoCheckTapped(cell: ToDOTableViewCell) {
        //Get the indexpath of cell where button was tapped
        let indexPath = self.tableView.indexPath(for: cell)
        do {
            try db?.updateCheck(index: indexPath!.row)
            tableView.reloadData()
        } catch  {
            print(error)
        }
    }
    
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(show: true, notification: notification)
        
    }
    
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(show: false, notification: notification)
        
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        var userInfo = notification.userInfo!
        
        if addToDo.isFirstResponder {
            let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
            let changeInHeight = (keyboardFrame.height + 10) * (show ? 1 : -1)
            UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
                self.bottomViewConstraint.constant += changeInHeight
            })
        }
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        
        if let addToDoText = addToDo.text {
            coder.encode(addToDoText, forKey: "addToDoText")
        }
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        
        if let addToDoText = coder.decodeObject(forKey: "addToDoText") as? String {
            self.addToDo.text = addToDoText
        }
        
        
        super.decodeRestorableState(with: coder)
    }

}






extension ViewController: UITableViewDelegate, UITableViewDataSource, ToDOTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do {
            let count = try db?.countRows()
            return count!
        } catch  {
            print(error)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell")! as! ToDOTableViewCell
        
        do {
            let todo = try db?.readIndex(index: indexPath)
            cell.todoTitle.text = todo?["title"] as? String
            cell.todoDesc.text = todo?["desc"] as? String
            cell.done = todo?["done"] as! Bool
            
        } catch  {
            print("Could not read cell info")
        }
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndexPath == indexPath {
            return 60.0 + extraHeight!
        }
        
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.beginUpdates()
        
        selectedIndexPath = indexPath
        let currentCell = tableView.cellForRow(at: selectedIndexPath!) as! ToDOTableViewCell
        if !currentCell.expanded {
            currentCell.todoDesc.sizeToFit()
            extraHeight = currentCell.todoDesc.frame.height + 10
            currentCell.expanded = true
        }
        else {
            extraHeight = 0
            currentCell.expanded = false
        }
        tableView.endUpdates()
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let cellAction = UITableViewRowAction(style: .default, title: "Remove") { (action, index) in
            
            self.removeToDo(index: indexPath.row)
            self.tableView.reloadData()
            
                    }
        cellAction.backgroundColor = UIColor.blue
        
        // Second action
        selectedIndexPath = indexPath
        let cellEditAction = UITableViewRowAction(style: .default, title: "Edit") { (action, index) in
            let cell = tableView.cellForRow(at: self.selectedIndexPath!) as! ToDOTableViewCell
            self.tableView.setEditing(false, animated: true)
            cell.todoDesc.sizeToFit()
            self.extraHeight = cell.todoDesc.frame.height + 10
            cell.expanded = true
            tableView.reloadRows(at: [self.selectedIndexPath!], with: .none)
            cell.todoDesc.becomeFirstResponder()
            
        }
        cellEditAction.backgroundColor = UIColor.cyan

        
        return [cellAction,cellEditAction]
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}








