//
//  ViewController.swift
//  Todoey
//
//  Created by Nadia Ayala on 11/05/19.
//  Copyright © 2019 Nadia Ayala. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController  {
    

//    @IBOutlet var todoTableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var itemArray: [Item] = [Item]()
    
    var selectedCategory: Cat? {
        //Everything insid didSet will happen as soon as the variable gets set with a value
        didSet{
            loadItems()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        print(itemArray)
        loadItems()
    }

    //MARK - TableView data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }
    
    
    //MARK - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //Next line checks the currenct value of the done property of the selected item and then changes it to its opposite
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        
           //context.delete(itemArray[indexPath.row])
          //itemArray.remove(at: indexPath.row)
          saveItems()
 
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            let deletedItem = self.itemArray[indexPath.row].title
            self.itemArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            print(self.itemArray)
            self.deleteItem(objectToDelete: deletedItem!)
        }
        let share = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
            // share item at indexPath
            print("I want to share: \(self.itemArray[indexPath.row])")
        }
        
        share.backgroundColor = UIColor.lightGray
        
        return [delete, share]
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alertController = UIAlertController(title: "Add item", message: " ", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if textField.text != "" {
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)
                self.saveItems()
        }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(cancelAction)
        alertController.addAction(action)
        
        alertController.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        present(alertController, animated: true, completion: nil)
        }
    
    func saveItems(){
        
        
        do {
            try self.context.save()
        }
        catch{
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
        print(itemArray)
        
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        

//        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let categoryPredicate = NSPredicate(format: "parentCategory.title MATCHES %@", selectedCategory!.title!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
           
        }
        else {
            request.predicate = categoryPredicate
            
        }
        
        do{
            //The output for this method will be an array of Items that is stored in our persistent container
            itemArray =  try context.fetch(request)
        }
        catch{
            print("Error fetching data from context. \(error)")
        }
        
        tableView.reloadData()
    }
    
    func deleteItem(objectToDelete: String){
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "title = %@", objectToDelete)
        
        do {
            let test = try self.context.fetch(fetchRequest)
            
            let objectToDelete = test[0] as NSManagedObject
            context.delete(objectToDelete)
            
            do{
                try context.save()
            }
            catch{
                print("Error: \(error)")
            }
        }
            
        catch {
            print("Error: \(error)")
        }
    }
}
    


// MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
    
        
//        do{
//            //The output for this method will be an array of Items that is stored in our persistent container
//            itemArray =  try context.fetch(request)
//        }
//        catch{
//            print("Error fetching data from context. \(error)")
//        }
        
        loadItems(with: request)
        
        
        
        
        tableView.reloadData()
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


    
    
    
    



