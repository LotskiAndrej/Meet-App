//
//  WelcomeViewController.swift
//  Meet App
//
//  Created by Andrej Lotski on 11/9/20.
//  Copyright © 2020 Andrej Lotski. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        navigationItem.hidesBackButton = true
        
        self.hideKeyboardWhenTappedAround()
    }
    
    fileprivate func loginToApp() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    let ac = UIAlertController(title: "Error logging in", message: e.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (UIAlertAction) in
                        self.passwordTextField.text = ""
                        ac.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(ac, animated: true, completion: nil)
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        loginToApp()
    }
}

//MARK: - UITextField Delegate Methods

extension WelcomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            loginToApp()
        }
        return true
    }
}
