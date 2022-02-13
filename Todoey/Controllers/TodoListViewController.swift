//
//  ViewController.swift
//  Todoey
//
//  Created by Vladyslav Taranenko on 02.02.2022.
//

import UIKit
import CoreData
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    var itemArray: [Item] = []
    var selectedCategory: Category?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let categoryColour = selectedCategory?.colour {
            title = selectedCategory!.name
            
            if let navbarColour = UIColor(hexString: categoryColour) {
                searchBar.barTintColor = navbarColour
                navigationController?.navigationBar.backgroundColor = navbarColour
                navigationController?.navigationBar.tintColor = ContrastColorOf(navbarColour, returnFlat: true)
                navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navbarColour, returnFlat: true)]
            }
        }
    }
    
    // MARK: - Table Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        if let categoryColour = selectedCategory?.colour {
            if let colour = UIColor(hexString: categoryColour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
        }
        
        return cell
    }
    
    // MARK: - Table Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
    }
    
    // MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        // Create Add button with action handler
        alert.addAction(UIAlertAction(title: "Add", style: .default) { (action) in
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()
        })
        
        // Create Cancel button with action handler
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Model Manipulation Methods
    
    func saveItems() {
        do {
            try self.context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = itemArray[indexPath.row] as? NSManagedObject {
            context.delete(itemForDeletion)
            saveItems()
            loadItems()
        }
    }
}

// MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
