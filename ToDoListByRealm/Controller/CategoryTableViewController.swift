//
//  CategoryTableViewController.swift
//  ToDoListByRealm
//
//  Created by 林祐辰 on 2022/5/18.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryTableViewController: UITableViewController{

    let realm = try! Realm()
    var categories:Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        tableView.separatorStyle = .none
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        
        
        let appBarAppearance = UINavigationBarAppearance()
        appBarAppearance.backgroundColor = UIColor(hexString: "#1D9BF6")
        appBarAppearance.largeTitleTextAttributes = [.foregroundColor : UIColor.white]
        navBar.scrollEdgeAppearance = appBarAppearance
        
        
        let barButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(barButtonAttributes, for: .normal)
    }
    


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }

    func loadCategory(){
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    func saveCategory(category:Category){
        
        do {
            try realm.write({
                realm.add(category)
            })
        } catch  {
            print(error.localizedDescription)
        }
        
        
    }
    
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as? CategoryTableViewCell
        
        if let category = categories?[indexPath.row] {
            let backgroundColor = UIColor(hexString: category.color)
            cell?.backgroundColor = backgroundColor
            cell?.categoryText.text = categories?[indexPath.row].categoryName ?? ""
            cell?.categoryText.textColor = ContrastColorOf(backgroundColor: backgroundColor ?? UIColor(hexString: "3498DB"), returnFlat: true)
        }
               
        
        return cell!
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
    
            guard let deleteObject = categories?[indexPath.row] else{
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


    
    
    @IBAction func addCategory(_ sender: Any) {
        
        var textField = UITextField()
        let controller = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            let category = Category()
            category.categoryName = textField.text!
            category.color = UIColor.randomFlat().hexValue()
            self.saveCategory(category: category)
            self.tableView.reloadData()
        }
  
        controller.addAction(action)
        controller.addTextField { alertTextfield in
            textField = alertTextfield
        }
        present(controller, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "fetchItens", sender: self)
    }

    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let destination = segue.destination as? ToDoTableViewController,
           let index = tableView.indexPathForSelectedRow?.row {
            destination.selectedCategory = categories?[index]
        }
        
    }
    
    
}
