//
//  InputViewController.swift
//  TaskApp
//
//  Created by koux2 on 2021/03/22.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var task: Task!
    
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            task.title = titleTextField.text!
            task.contents = contentsTextView.text ?? ""
            task.date = datePicker.date
            realm.add(task, update: .modified)
        }
        
        super.viewWillDisappear(animated)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

}
