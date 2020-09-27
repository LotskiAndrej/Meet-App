//
//  MainTableViewController.swift
//  Meet App
//
//  Created by Andrej Lotski on 11/9/20.
//  Copyright © 2020 Andrej Lotski. All rights reserved.
//

import UIKit
import Firebase

class MainTableCell: UITableViewCell {
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var dateTimeLabel: UILabel!
    @IBOutlet var createdByLabel: UILabel!
    @IBOutlet var cellTrash: UIImageView!
}

class MainTableViewController: UITableViewController {
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {} else {
            if let vc = self.storyboard?.instantiateViewController(identifier: "Login") as? WelcomeViewController {
                
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    var spinnerView = UIActivityIndicatorView()
    let db = Firestore.firestore()
    var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        spinnerMethods()
        loadEvents()
        
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    func spinnerMethods() {
        spinnerView.color = .systemBlue
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinnerView)
        spinnerView.startAnimating()
    }
    
    @objc func refresh() {
        loadEvents()
    }
    
    @objc func addEvent() {
        if let vc = self.storyboard?.instantiateViewController(identifier: "Add") as? EventViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive) { (action) in
            do {
                try Auth.auth().signOut()
                if let vc = self.storyboard?.instantiateViewController(identifier: "Login") as? WelcomeViewController {
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(logOutAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - loadEvents() start
    func loadEvents() {
        db.collection("events").order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
            self.events = []
            
            if let e = error {
                print("There was an issue retrieving data from Firestore \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let sender = data["sender"] as? String, let location = data["location"] as? String, let time = data["time"] as? String, var date = data["date"] as? String, let dateCreated = data["dateCreated"] as? Int, let going = data["going"] as? [String] {
                            
                            let formatter = DateFormatter()
                            formatter.dateStyle = .short
                            formatter.dateFormat = "dd/MM/yy"
                            let today = formatter.string(from: Date())
                            let tomorrow = formatter.string(from: Date().addingTimeInterval(86400))
                            if today == date {
                                date = "Today"
                            } else if tomorrow == date {
                                date = "Tomorrow"
                            }
                            
                            let newEvent = Event(location: location, time: time, date: date, sender: sender, docID: doc.documentID, dateCreated: dateCreated, going: going)
                            self.events.append(newEvent)
                            
                            DispatchQueue.main.async {
                                self.spinnerView.stopAnimating()
                                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addEvent))
                                
                                self.tableView.reloadData()
                                self.refreshControl?.endRefreshing()
                            }
                        }
                    }
                }
            }
        }
    }
    //MARK: - loadEvents() end
}

//MARK: - TableView Delegate and DataSource Methods

extension MainTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Event", for: indexPath) as! MainTableCell
        let event = events[indexPath.row]
        cell.locationLabel.text = event.location
        cell.dateTimeLabel.text = "\(event.date) at \(event.time)"
        cell.createdByLabel.text = "Created by: \(event.sender)"
        cell.cellTrash.image = UIImage(systemName: "trash")
        
        if event.sender != Auth.auth().currentUser?.email {
            cell.cellTrash.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.event = events[indexPath.row]
            vc.eventID = events[indexPath.row].docID
            
            navigationController?.pushViewController(vc, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        if events[indexPath.row].sender == Auth.auth().currentUser?.email {
            return UITableViewCell.EditingStyle.delete
        } else {
            return UITableViewCell.EditingStyle.none
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if Auth.auth().currentUser?.email == events[indexPath.row].sender {
                let docID = events[indexPath.row].docID
                events.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                db.collection("events").document(docID).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            }
        }
    }
}

//MARK: - Keyboard Dismiss Method

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
