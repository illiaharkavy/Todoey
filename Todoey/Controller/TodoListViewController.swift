//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Илья Горьковой on 10.03.2018.
//  Copyright © 2018 Illia Harkavy. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    
    var todosArray = [Todo]() {
        didSet {
            //saveTodos()
        }
    }
    
    
    
    let defaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTodos()
        
        //self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        
        saveTodos()
        
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
            let todo = Todo(context: self.context)
            todo.done = false
            todo.title = enteredText
            self.todosArray += [todo]
            let indexPathToInsert = IndexPath(row: self.todosArray.count-1, section: 0)
            self.tableView.insertRows(at: [indexPathToInsert], with: .automatic)
            self.saveTodos()
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
            try context.save()
        } catch {
            print("Unable to save todos. Error: \(error)")
        }
        print("Saved")
    }
    
    func loadTodos(with request: NSFetchRequest<Todo> = Todo.fetchRequest()) {
        do {
            todosArray = try context.fetch(request)
        } catch {
            print("Error fetcing data from context \(error)")
        }
        tableView.reloadData()
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(todosArray[indexPath.row])
            todosArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveTodos()
        }
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedTodo = todosArray[fromIndexPath.row]
        context.delete(todosArray[fromIndexPath.row])
        todosArray.remove(at: fromIndexPath.row)
        todosArray.insert(movedTodo, at: to.row)
        
    }
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
*/
}


//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadTodos(with: request)
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadTodos()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
}
