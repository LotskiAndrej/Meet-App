//
//  EventViewController.swift
//  Meet App
//
//  Created by Andrej Lotski on 11/9/20.
//  Copyright © 2020 Andrej Lotski. All rights reserved.
//

import UIKit
import Firebase

class EventViewController: UIViewController {
    
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var addEventButton: UIButton!
    @IBOutlet var datePicker: UIDatePicker!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.delegate = self
        createDatePicker()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func addEventPressed(_ sender: UIButton) {
        if locationTextField.text != "" {
            if let loc = locationTextField.text, let time = getPickerInfo(for: "time"), let date = getPickerInfo(for: "date"), let sender = Auth.auth().currentUser?.email {
                db.collection("events").addDocument(data: [
                    "location": loc,
                    "time": time,
                    "date": date,
                    "sender": sender,
                    "dateCreated": Int(Date().timeIntervalSince1970),
                    "going": [sender]
                ]) { error in
                    if let e = error {
                        print("Error adding document: \(e)")
                    } else {
                        print("Document added successfully")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Fill out the location field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func createDatePicker() {
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .compact
        } else {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.minimumDate = Date()
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

extension EventViewController: UITextFieldDelegate {
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
