//
//  RegisterViewController.swift
//  Meet App
//
//  Created by Andrej Lotski on 11/9/20.
//  Copyright © 2020 Andrej Lotski. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    }
    
    //MARK: - registerToApp() start
    fileprivate func registerToApp() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    let ac = UIAlertController(title: "Error creating account", message: e.localizedDescription, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Dismiss", style: .cancel) { (action) in
                        self.passwordTextField.text = ""
                        ac.dismiss(animated: true, completion: nil)
                    }
                    ac.addAction(action)
                    
                    self.present(ac, animated: true)
                } else {
                    let ac = UIAlertController(title: "Account successfully created", message: nil, preferredStyle: .alert)
                    
                    self.present(ac, animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        ac.dismiss(animated: true, completion: nil)
                        
                        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                            if let e = error {
                                let ac = UIAlertController(title: "Error logging in", message: e.localizedDescription, preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: .none))
                                
                                self.present(ac, animated: true, completion: nil)
                            } else {
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    //MARK: - registerToApp() end
    
    @IBAction func registerPressed(_ sender: UIButton) {
        registerToApp()
    }
}

//MARK: - UITextField Delegate Methods

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            registerToApp()
        }
        return true
    }
}
