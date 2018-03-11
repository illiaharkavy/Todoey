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

    var todos = [Todo]()
    var filteredTodos = [Todo]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Candies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        loadTodos()
        
        //self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredTodos.count
        }
        else {
            return todos.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)

        let todo: Todo
        if isFiltering() {
            todo = filteredTodos[indexPath.row]
        }
        else {
            todo = todos[indexPath.row]
        }
        
        cell.textLabel?.text = todo.title
        cell.accessoryType = todo.done ? .checkmark : .none

        return cell
    }
    
    
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            let todo: Todo
            if isFiltering() {
                todo = filteredTodos[indexPath.row]
            }
            else {
                todo = todos[indexPath.row]
            }
            todo.done = !todo.done
            selectedCell.accessoryType = todo.done ? .checkmark : .none
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
            self.todos += [todo]
            let indexPathToInsert = IndexPath(row: self.todos.count-1, section: 0)
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
            textField.enablesReturnKeyAutomatically = true
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
            todos = try context.fetch(request)
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
            context.delete(todos[indexPath.row])
            todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveTodos()
        }
    }
    
    func filterContentForSearchText(_ searchText: String) {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        do {
            filteredTodos = try context.fetch(request)
        } catch {
            print("Error fetcing data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
}

extension TodoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    
}
