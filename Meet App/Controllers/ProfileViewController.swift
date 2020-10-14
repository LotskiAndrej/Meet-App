//
//  ProfileViewController.swift
//  Meet App
//
//  Created by Andrej Lotski on 14/10/20.
//  Copyright © 2020 Andrej Lotski. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        roundImageView()
        tapGestureMethods()
        
        emailLabel.text = Auth.auth().currentUser?.email
    }
    
    fileprivate func roundImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.contentMode = .scaleAspectFill
    }
    
    fileprivate func tapGestureMethods() {
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.editImage))
        let tapName = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.editName))
        
        imageView.isUserInteractionEnabled = true
        nameLabel.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapImage)
        nameLabel.addGestureRecognizer(tapName)
    }
    
    @objc func editImage(sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Update Image", message: "", preferredStyle: .alert)
        
        let chooseAction = UIAlertAction(title: "Choose Image", style: .default) { (action) in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(chooseAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage
        
        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        self.imageView.image = newImage
        
        self.dismiss(animated: true)
    }
    
    @objc func editName(sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Edit Name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "First and Last Name"
            textField.autocapitalizationType = .words
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            if let textField = alert.textFields?[0] {
                self.nameLabel.text = textField.text
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
