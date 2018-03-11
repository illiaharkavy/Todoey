//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Илья Горьковой on 10.03.2018.
//  Copyright © 2018 Illia Harkavy. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var todosArray = [Todo]() {
        didSet {
            saveTodos()
        }
    }
    
    let defaults = UserDefaults.standard
    
    var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("todos")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let data = try Data(contentsOf: url)
            todosArray = try JSONDecoder().decode([Todo].self, from: data)
        } catch {
            print("Unable to load todos. Error: \(error)")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todosArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)

        cell.textLabel?.text = todosArray[indexPath.row].title
        cell.accessoryType = todosArray[indexPath.row].done ? .checkmark : .none

        return cell
    }
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            todosArray[indexPath.row].done = !todosArray[indexPath.row].done
            selectedCell.accessoryType = todosArray[indexPath.row].done ? .checkmark : .none
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
            self.todosArray += [Todo(title: enteredText, done: false)]
            let indexPathToInsert = IndexPath(row: self.todosArray.count-1, section: 0)
            self.tableView.insertRows(at: [indexPathToInsert], with: .automatic)
            
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
    
    func saveTodos() {
        do {
            let jsonData = try JSONEncoder().encode(todosArray)
            try jsonData.write(to: url)
        } catch {
            print("Unable to save todos. Error: \(error)")
        }
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todosArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedTodo = todosArray[fromIndexPath.row]
        todosArray.remove(at: fromIndexPath.row)
        todosArray.insert(movedTodo, at: to.row)
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
