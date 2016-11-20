//
//  QuoteJarModel.swift
//  iQuoteJar
//
//  Created by BRAUER, BOBBY [AG/1155] on 11/12/2016.
//  Copyright © 2016 BRAUER, BOBBY [AG/1155]. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class QuoteDataModel {
    //var managedObjectContext: NSManagedObjectContext
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var quotesJSON: JSON = ""
    var queryComplete = false
    
    /*override init() {
        
        guard let modelURL = NSBundle.mainBundle().URLForResource("iQuoteJar", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = psc
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let docURL = urls[urls.endIndex-1]
            
            let storeURL = docURL.URLByAppendingPathComponent("Quote.sqlite")
            do {
                try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }*/
    
    func removeQuotes() {
        //remove existing items from Quotes table in CoreData
        let fetchRequest = NSFetchRequest(entityName: "Quote")
        
        do {
            let quoteContents = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Quote]
            for q in quoteContents {
                self.managedObjectContext.deleteObject(q)
            }
        } catch {
            fatalError("Failed to fetch quotes: \(error)")
        }
    }
    
    func retrieveQuotes(userID: String) {
        self.queryComplete = false
        
        let quoteJarUrl = "http://localhost:3000/api/quotes/query"
        let url: NSURL = NSURL(string: quoteJarUrl)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "{\"user_id\":\"" + userID + "\"}"
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
            //print(myJSON)
            self.quotesJSON = myJSON
            self.queryComplete = true
        }
        
        task.resume()
    }
    
    func loadQuotes(userID: String) {
        print("Loading Quotes")
        self.removeQuotes()
        self.retrieveQuotes(userID)
        
        while self.queryComplete == false {
            usleep(20000)
        }
        
        //create quotes from json and load into core data
        print(self.quotesJSON)
        for (_, q) in self.quotesJSON {
            print("Adding quote to core data")
            print(q)
            let quote = NSEntityDescription.insertNewObjectForEntityForName("Quote", inManagedObjectContext: managedObjectContext) as! Quote
            
            quote.id = q["_id"].string!
            quote.user_id = q["user_id"].string!
            quote.isFavorite = q["isFavorite"].string!
            quote.text = q["text"].string!
            quote.said_by = q["said_by"].string!
            quote.rating = q["rating"].number!.shortValue
            
            //placeholder need to work on tags
            var tagArray = [NSNumber]()
            for (_, t) in q["tags"] {
                var tagId: NSNumber
                if let tagString = t.string {
                    tagId = Int(tagString)!
                } else {
                    tagId = t.number!
                }
                print (t)
                tagArray.append(tagId)
            }
            quote.tags = tagArray

        }
    }
    
    func createQuotes(userID: String) {
        let quoteRequest = NSFetchRequest(entityName: "Quote")
        var quotes = [Quote]()
        do {
            let quoteResults = try managedObjectContext.executeFetchRequest(quoteRequest) as? [Quote]
            quotes = quoteResults!
        } catch let error as NSError {
            print("failed fetch \(error.localizedDescription)")
        }
        
        //if quote id doesn't exist - then add it
        for q in quotes {
            print(q.id)
            if q.id == "" {
                print("Writing quote to database")
                writeQuote(q)
                while self.queryComplete == false {
                    usleep(20000)
                }
            }
        }
        self.loadQuotes(userID)
    }
    
    func writeQuote(quote: Quote) {
        self.queryComplete = false
        
        let quoteJarUrl = "http://localhost:3000/api/quotes"
        let url: NSURL = NSURL(string: quoteJarUrl)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        var tagArray = [String]()
        for t in quote.tags {
            tagArray.append(String(t))
        }
        let tagString = tagArray.description
        //let tagJSONArray = JSON(tagArray)
        
        let json: [String: AnyObject] = ["user_id": quote.user_id, "text": quote.text, "said_by": quote.said_by, "rating": Int(quote.rating), "isFavorite": quote.isFavorite, "tags": quote.tags]
        print("json for quote:")
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
            self.queryComplete = true
        }
        task.resume()
    }
}