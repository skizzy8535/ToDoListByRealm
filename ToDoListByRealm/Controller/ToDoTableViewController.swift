//
//  ToDoTableViewController.swift
//  ToDoListByRealm
//
//  Created by 林祐辰 on 2022/5/18.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoTableViewController: UITableViewController {

    let realm = try! Realm()
    var items:Results<Items>?
    var selectedCategory:Category? {
        didSet{
            loadItems()
        }
    }
    
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = selectedCategory?.color {
            title = selectedCategory!.categoryName
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
            }
            
            
            if let navBarColor = UIColor(hexString: colorHex) {
                
                let appBarAppearance = UINavigationBarAppearance()
                appBarAppearance.backgroundColor = navBarColor
                appBarAppearance.largeTitleTextAttributes = [.foregroundColor : UIColor.white]
                navBar.scrollEdgeAppearance = appBarAppearance
                navBar.backgroundColor = navBarColor
                navBar.tintColor = ContrastColorOf(backgroundColor: navBarColor, returnFlat: true)
                searchBar.barTintColor = navBarColor
            }
        }
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoTableViewCell", for: indexPath) as? ToDoTableViewCell

        if let item = items?[indexPath.row]  {
            cell?.toDoText.text = item.title
            let backgroundColor = UIColor(hexString: selectedCategory?.color ?? "EF717A").darken(byPercentage:  CGFloat(indexPath.row)/CGFloat(items!.count))
            let contrastColor = ContrastColorOf(backgroundColor: backgroundColor ?? UIColor(hexString:"FFFFFF"), returnFlat: true)
            cell?.backgroundColor = backgroundColor
            cell?.toDoText.textColor = contrastColor
            cell?.accessoryType = item.done ? .checkmark : .none
            cell?.accessoryView?.tintColor = contrastColor
        }
        return cell!
    }





    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let deleteObject = items?[indexPath.row] else{
                return
            }
            
            do {
                try realm.write({
                    realm.delete(deleteObject)
                })
            } catch  {
                print(error.localizedDescription)
            }
        
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }

    }


    
    @IBAction func addItem(_ sender: Any) {
        
        var textField = UITextField()
        let controller = UIAlertController(title: "Add Items", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            if let selectCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                        let item = Items()
                        item.title = textField.text!
                        item.addDate = Date()
                        item.done = false
                        selectCategory.items.append(item)
                    }
                } catch  {
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
  
        controller.addAction(action)
        controller.addTextField { alertTextfield in
            textField = alertTextfield
        }
        present(controller, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let pickItem = self.items?[indexPath.row] else{
            return
        }
        
        do{
            try realm.write {
                pickItem.done = !pickItem.done
            }
        }catch{
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
     
        let swipeLeft = UIContextualAction(style: .normal, title: "Modify Items") { action, view, completion in
            var textField = UITextField()
            let controller = UIAlertController(title: "Modify", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                
                guard let pickItem = self.items?[indexPath.row] else{
                    return
                }
            
                do{
                    try self.realm.write {
                        pickItem.title = textField.text!
                    }
                }catch{
                    print(error.localizedDescription)
                }
                self.tableView.reloadData()
            }
      
            controller.addAction(action)
            controller.addTextField { alertTextfield in
                textField = alertTextfield
            }
            self.present(controller, animated: true, completion: nil)
            completion(true)
        }
        swipeLeft.backgroundColor = .orange
        let swipeToModiyConfiguration = UISwipeActionsConfiguration(actions: [swipeLeft])
        return swipeToModiyConfiguration
    }
    
    
    func loadItems(){
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    

    func saveItems(item:Items){
        do {
            try realm.write({
                realm.add(item)
            })
        } catch  {
            print(error.localizedDescription)
        }
        
      
    }
    
}


extension ToDoTableViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
        }
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
    
    
}
