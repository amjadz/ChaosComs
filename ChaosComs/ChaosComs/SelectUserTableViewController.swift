//
//  SelectUserTableViewController.swift
//  ChaosComs
//
//  Created by Zubair Amjad on 12/2/18.
//  Copyright © 2018 Zubair Amjad. All rights reserved.
//

import UIKit
import Firebase


struct User {
    let name: String!
    let uid: String!
}


class SelectUserTableViewController: UITableViewController {
    
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let uid = Auth.auth().currentUser?.uid
        
        let ref: DatabaseReference! = Database.database().reference()
        
        ref.child("users").child(uid!).queryOrderedByKey().observe(.childAdded) { (snapshot) in
            
            let name = (snapshot.value as? NSDictionary)?["name"] as? String ?? ""
            
            let uid = (snapshot.value as? NSDictionary)?["uid"] as? String ?? ""
            
            self.users.append(User(name: name, uid: uid))
                
            self.tableView.reloadData()
            
        }
        
        tableView.reloadData()
        
    }
     
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let nameTxtField = cell.viewWithTag(1) as! UILabel
        nameTxtField.text = users[indexPath.row].name
        return cell
    }
}
