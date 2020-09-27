//
//  DetailViewController.swift
//  Meet App
//
//  Created by Andrej Lotski on 12/9/20.
//  Copyright © 2020 Andrej Lotski. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {
    
    @IBOutlet var locationTextLabel: UILabel!
    @IBOutlet var dateTextLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var goingButtonLabel: UIButton!
    
    var event = Event()
    var eventID = ""
    let db = Firestore.firestore()
    var goings = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        locationTextLabel.text = event.location
        dateTextLabel.text = "\(event.date) at \(event.time)"
        
        if Auth.auth().currentUser?.email != event.sender {
            navigationItem.setRightBarButton(nil, animated: true)
        }
        
        refreshMethods()
        
        goings = event.going
        toggleButton(goings)
    }
    
    func refreshMethods() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = .systemBlue
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    func toggleButton(_ goingsToCheck: [String]) {
        let checkGoings = goingsToCheck
        if let currentUser = Auth.auth().currentUser?.email {
            if !checkGoings.contains(currentUser) {
                goingButtonLabel.setTitle("Going", for: .normal)
                goingButtonLabel.setTitleColor(.systemBlue, for: .normal)
            } else {
                goingButtonLabel.setTitle("Not Going", for: .normal)
                goingButtonLabel.setTitleColor(.systemRed, for: .normal)
            }
        }
    }
    
    @objc func refresh() {
        db.collection("events").document(event.docID).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            if let going = data["going"] as? [String] {
                self.goings = going
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    fileprivate func updateGoingsInDB(_ updatedGoing: [String]) {
        db.collection("events").document(event.docID).updateData([
            "going": updatedGoing
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                self.goings = updatedGoing
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func goingButtonPressed(_ sender: UIButton) {
        var updatedGoing = goings
        if let currentUser = Auth.auth().currentUser?.email {
            if !updatedGoing.contains(currentUser) {
                updatedGoing.append(currentUser)
            } else {
                updatedGoing.remove(at: updatedGoing.firstIndex(of: currentUser)!)
            }
            updateGoingsInDB(updatedGoing)
        }
        
        toggleButton(updatedGoing)
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if let vc = storyboard?.instantiateViewController(identifier: "Edit") as? UpdateEventViewController {
            vc.location = event.location
            vc.time = event.time
            vc.date = event.date
            vc.docID = event.docID
            vc.sender = event.sender
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - TableView DataSource and Delegate Methods

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let going = goings[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoingCell", for: indexPath)
        cell.textLabel?.text = going
        
        return cell
    }
}
