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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let target = segue.destination as? SelectUserTableViewController {
//            target.member = User()
//        }
//    }
    
    func loginFirebase(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                print("Login Successful!")
//                let email = Auth.auth().currentUser?.email
//                var ref = Constants.refs.databaseRoot.child("users")
//                var query = ref.queryEqual(toValue: email, childKey: "email").queryLimited(toFirst: 1)
//                print(query)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "message_screen") as! SelectUserTableViewController
                self.present(vc, animated: true, completion: nil)
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
