//
//  ViewController.swift
//  TaskApp
//
//  Created by koux2 on 2021/03/22.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    
    let realm = try! Realm()
    
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    var filterTaskArray = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchField.delegate = self
        
        filterTaskArray = Array(taskArray)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController: InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = tableView.indexPathForSelectedRow
            inputViewController.task = filterTaskArray[indexPath!.row]
        } else {
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterTaskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = filterTaskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
                
        if editingStyle == .delete {
            
            let task = filterTaskArray[indexPath.row]
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            try! realm.write {
                realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        let word = searchBar.text
        filterTaskArray.removeAll()
        if word == "" {
            filterTaskArray = Array(taskArray)
        } else {
            for task in taskArray {
                if task.category == word {
                    filterTaskArray.append(task)
                }
            }
        }
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterTaskArray = Array(taskArray)
        tableView.reloadData()
    }
}

