//
//  AddUserViewController.swift
//  iQuoteJar
//
//  Created by BRAUER, BOBBY [AG/1155] on 12/2/2016.
//  Copyright © 2016 BRAUER, BOBBY [AG/1155]. All rights reserved.
//

import Foundation
import UIKit

class AddUserViewController: UIViewController {
    var queryComplete = false
    var userJSON: JSON = ""
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func createUserAction(sender: AnyObject) {
        addUser()
        while self.queryComplete == false {
            usleep(20000)
        }
        if userJSON[0]["_id"].string != nil {
            let userCreatedAlertController = UIAlertController(title: "User Added!", message: "email: " + emailTextField.text!, preferredStyle: UIAlertControllerStyle.Alert)
            userCreatedAlertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {_ in self.performSegueWithIdentifier("CreateUser", sender: nil)}))
            self.presentViewController(userCreatedAlertController, animated: true, completion: nil)
        } else {
            errorLabel.text = "Please enter valid matching email/password"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if let ident = identifier {
            if ident == "CreateUser" {
                addUser()
                while self.queryComplete == false {
                    usleep(20000)
                }
                if userJSON[0]["_id"].string != nil {
                    
                    return true
                } else {
                    errorLabel.text = "Please enter valid matching email/password"
                    return false
                }
            }
            return true
        }
        return true
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "CreateUser") {
            
        }
    }
    
    func addUser() {
        self.queryComplete = false
        
        let addUserUrl = "http://localhost:3000/api/createUser"
        let url: NSURL = NSURL(string: addUserUrl)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let json: [String: AnyObject] = ["email": emailTextField.text!, "confirmEmail": confirmEmailTextField.text!, "password": passwordTextField.text!, "confirmPassword": confirmPasswordTextField.text!]
        print("json for addUser: ")
        print(json)
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            request.HTTPBody = jsonData
        } catch let error as NSError {
            print("failed json serialization \(error.localizedDescription)")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            let myJSON = JSON(data: data!)
            print("response from writing to database")
            print(myJSON)
            self.userJSON = myJSON
            self.queryComplete = true
        }
        task.resume()
    }
    
}
