//
//  UpdateEventViewController.swift
//  Meet App
//
//  Created by Andrej Lotski on 13/9/20.
//  Copyright © 2020 Andrej Lotski. All rights reserved.
//

import UIKit
import Firebase

class UpdateEventViewController: UIViewController {
    
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    let db = Firestore.firestore()
    
    var location: String = ""
    var time: String = ""
    var date: String = ""
    var docID: String = ""
    var sender: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.text = location
        locationTextField.delegate = self
        createDatePicker()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func updateEventButtonPressed(_ sender: UIButton) {
        if locationTextField.text != "" {
            if let loc = locationTextField.text, let time = getPickerInfo(for: "time"), let date = getPickerInfo(for: "date") {
                db.collection("events").document(docID).updateData([
                    "location": loc,
                    "time": time,
                    "date": date
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
            
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Fill out the empty fields", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - DatePicker Methods
    
    func createDatePicker() {
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .compact
        } else {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.minimumDate = Date()
        
//        datePicker.setDate(Date(), animated: true)
    }

    func getPickerInfo(for info: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short

        if info == "time" {
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: datePicker.date)
        } else if info == "date" {
            formatter.dateFormat = "dd/MM/yy"
            return formatter.string(from: datePicker.date)
        } else {
            return nil
        }
    }
}

//MARK: - UITextField Delegate Methods

extension UpdateEventViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 60
    }
}
