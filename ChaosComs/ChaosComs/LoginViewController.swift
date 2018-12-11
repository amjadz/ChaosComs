//
//  LoginViewController.swift
//  ChaosComs
//
//  Created by Zubair Amjad on 11/27/18.
//  Copyright © 2018 Zubair Amjad. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    var member: User!
    
    @IBOutlet weak var email_login: UITextField!
    
    @IBOutlet weak var password_login: UITextField!
    
    @IBAction func login(_ sender: Any) {
        guard let email_login_text = email_login.text  else {
            return
            
        }
        
        guard let password_login_text = password_login.text else {
            return
        }
        
        loginFirebase(email: email_login_text, password: password_login_text)
        
    }
    
    
    
    @IBAction func go_back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func loginFirebase(email: String, password: String){
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error == nil {
                print("Login Successful!")
                let email = Auth.auth().currentUser?.email
                var ref = Constants.refs.databaseRoot.child("users")
                var query = ref.queryOrdered(byChild: "email").queryEqual(toValue: email)
                var userName: String = "someuser"
                
                query.observe(.value, with: { (snapshot) in
                    
                    if snapshot.childrenCount > 0 {
                        
                        if let snapDict = snapshot.value as? [String:AnyObject]{
                            for each in snapDict{
                                let holder = each.value["name"] as! String
                                self.member = User(name: holder, uid: email ?? "no uid")
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "message_screen") as! SelectUserTableViewController
                                vc.member = self.member
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                })
            } else {
                print("Login Failed!")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
