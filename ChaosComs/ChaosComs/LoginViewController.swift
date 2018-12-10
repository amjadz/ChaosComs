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
    
    
    @IBAction func login_to_message(_ sender: Any) {
        let login_to_message = self.storyboard?.instantiateViewController(withIdentifier: "message_screen") as! SelectUserTableViewController
        
        self.navigationController?.pushViewController(login_to_message, animated: true)
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let target = segue.destination as? SelectUserTableViewController {
//            target.member = User()
//        }
//    }
    
    func loginFirebase(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                let loginScreenToMessage = self.storyboard?.instantiateViewController(withIdentifier: "message_screen") as! SelectUserTableViewController
                
                self.navigationController?.pushViewController(loginScreenToMessage, animated: true)
            } else {
                print("Login Failed!")
            }
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
