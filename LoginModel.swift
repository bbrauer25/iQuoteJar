//
//  LoginModel.swift
//  iQuoteJar
//
//  Created by BRAUER, BOBBY [AG/1155] on 11/20/2016.
//  Copyright © 2016 BRAUER, BOBBY [AG/1155]. All rights reserved.
//

import Foundation

class LoginModel {
    
    var loginJSON: JSON = ""
    var loginComplete = false
    var loginSuccessful = false
    var userID = ""
    
    func LoginToQuoteJar(email: String, password: String) {
        
        let quoteJarUrl = "http://localhost:3000/api/userID"
        let url: NSURL = NSURL(string: quoteJarUrl)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "{\"email\":\"" + email + "\",\"password\": \"" + password + "\"}"
        print(paramString)
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            let myJSON = JSON(data: data!)
            print(myJSON)
            self.loginJSON = myJSON
            /*if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    self.loginSuccessful = true
                }
            }*/
            if myJSON[0]["email"].string != nil {
                self.loginSuccessful = true
                print("login success")
                print(myJSON[0]["email"])
                self.userID = String(myJSON[0]["_id"])
            }
            self.loginComplete = true
        }
        
        task.resume()
    }
}