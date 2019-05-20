//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Nadia Ayala on 18/05/19.
//  Copyright © 2019 Nadia Ayala. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var categoryArray: [Cat] = [Cat]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()

    }
    
    //MARK: - TableView Data Source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].title
        
        return cell
        
    }
    
    //MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController

        if let indexPath = tableView.indexPathForSelectedRow {

            destinationVC.selectedCategory = categoryArray[indexPath.row]
//            print(destinationVC.selectedCategory)
            

        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            let deletedItem = self.categoryArray[indexPath.row].title
            self.categoryArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            print(self.categoryArray)
            //            self.saveItems()
            self.deleteCategory(objectToDelete: deletedItem!)
        }
        
        let share = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
            // share item at indexPath
            print("I want to share: \(self.categoryArray[indexPath.row])")
        }
        
        share.backgroundColor = UIColor.lightGray
        
        return [delete, share]
        
    }
    
    
    
    
    //MARK: - Data manipulation methods
    
    func saveCategories(){
        
        
        do {
            try self.context.save()
        }
        catch{
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
        print(categoryArray)
        
    }
    
    func loadCategories(with request: NSFetchRequest<Cat> = Cat.fetchRequest()){
        
        //        let request : NSFetchRequest<Item> = Item.fetchRequest()
        do{
            //The output for this method will be an array of Items that is stored in our persistent container
            categoryArray =  try context.fetch(request)
        }
        catch{
            print("Error fetching data from context. \(error)")
        }
        
        tableView.reloadData()
    }
    
    // MARK: -  Delete categories
    
    func deleteCategory(objectToDelete: String){
        let fetchRequest = NSFetchRequest<Cat>(entityName: "Cat")
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
    
    
    //MARK: - Add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()

        let alertController = UIAlertController(title: "Add category", message: " ", preferredStyle: .alert)

        let addAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if textField.text != "" {
                let newCat = Cat(context: self.context)
                newCat.title = textField.text!
                self.categoryArray.append(newCat)
                
                self.saveCategories()
//                print(self.categoryArray)
                
            }
    }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        alertController.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
  
    

   
    
    
    
    

}
