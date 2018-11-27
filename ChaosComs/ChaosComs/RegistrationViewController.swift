//
//  ViewController.swift
//  ChaosComs
//
//  Created by Zubair Amjad on 11/26/18.
//  Copyright © 2018 Zubair Amjad. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewController: UIViewController {


    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var passowrd: UITextField!
    
    @IBAction func login_screen_button(_ sender: UIButton) {

        let loginScreen = self.storyboard?.instantiateViewController(withIdentifier: "go_back") as! LoginViewController
        
        self.navigationController?.pushViewController(loginScreen, animated: true)
    }
    
    
    @IBAction func registe_button(_ sender: UIButton) {
        
        guard let emailText = email.text else {
            print("Didn't work")
            return
            
        }
        
        guard let passwordText = passowrd.text else  {
            print("Didn't work")
            return
        }

        registerUser(email: emailText, password: passwordText)
        let messageScreen = self.storyboard?.instantiateViewController(withIdentifier: "message_screen") as! MessageViewController
            
        self.navigationController?.pushViewController(messageScreen, animated: true)
        
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        

    }
    
    func registerUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            print("ded")

            guard let user = authResult?.user else { return }
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}
