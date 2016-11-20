//
//  ViewController.swift
//  iQuoteJar
//
//  Created by BRAUER, BOBBY [AG/1155] on 11/12/2016.
//  Copyright © 2016 BRAUER, BOBBY [AG/1155]. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var myLoginModel = LoginModel()
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //triggered after shouldPerformSegue
        if (segue.identifier == "Login") {
            let viewQuoteVC = segue.destinationViewController as! ViewQuoteTableViewController
            viewQuoteVC.userID = myLoginModel.userID
            print("Thanks")
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        //try to login here
        if let ident = identifier {
            if ident == "Login" {
                print("Trying to Login")
                myLoginModel.LoginToQuoteJar(emailTextField.text!, password: passwordTextField.text!)
                
                while myLoginModel.loginComplete == false {
                    usleep(20000)
                }
                
                print(!myLoginModel.loginSuccessful)
                if !myLoginModel.loginSuccessful {
                    errorTextField.text = "Bad email/password"
                    return false
                }
            }
            errorTextField.text = ""
            return true
        }
        return true
    }
}

