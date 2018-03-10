//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Илья Горьковой on 10.03.2018.
//  Copyright © 2018 Illia Harkavy. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [String]()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemArray = defaults.array(forKey: "TodoListArray") as? [String] ?? []
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)

        cell.textLabel?.text = itemArray[indexPath.row]

        return cell
    }
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            if selectedCell.accessoryType == .checkmark {
                selectedCell.accessoryType = .none
            }
            else {
                selectedCell.accessoryType = .checkmark
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        class AddAction: UIAlertAction, UITextFieldDelegate {
            override init() {
                super.init()
                NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextChanged(notification:)), name: .UITextFieldTextDidChange, object: nil)
            }
            @objc func textFieldTextChanged(notification: NSNotification) {
                if let textField = notification.object as? UITextField {
                    if textField.text! == "" {
                        isEnabled = false
                    }
                    else {
                        isEnabled = true
                    }
                }
            }
        }
        
        let alert = UIAlertController(title: "New Todo", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = AddAction(title: "Add todo", style: .default) { (action) in
            let enteredText = alert.textFields!.first!.text!
            self.itemArray += [enteredText]
            let indexPathToInsert = IndexPath(row: self.itemArray.count-1, section: 0)
            self.tableView.insertRows(at: [indexPathToInsert], with: .automatic)
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
        }
        addAction.isEnabled = false
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Todo"
            textField.autocapitalizationType = .sentences
            textField.returnKeyType = .done
            textField.delegate = addAction
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
