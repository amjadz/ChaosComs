//
//  LoginViewController.swift
//  ChaosComs
//
//  Created by Zubair Amjad on 11/27/18.
//  Copyright © 2018 Zubair Amjad. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBAction func go_back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func login_to_message(_ sender: Any) {
        let login_to_message = self.storyboard?.instantiateViewController(withIdentifier: "message_screen_log_in") as! MessageViewController
        
        self.navigationController?.pushViewController(login_to_message, animated: true)
        
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
