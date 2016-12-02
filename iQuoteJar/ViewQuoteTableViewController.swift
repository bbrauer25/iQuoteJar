//
//  ViewQuoteTableViewController.swift
//  iQuoteJar
//
//  Created by BRAUER, BOBBY [AG/1155] on 11/12/2016.
//  Copyright © 2016 BRAUER, BOBBY [AG/1155]. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ViewQuoteTableViewController: UITableViewController {
    
    //loaded in user quotes and all tags at segue
    var quotes = [Quote]()
    var tags = [Tag]()
    //var userID: String!
    var userID = ""
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var myQuoteDataModel = QuoteDataModel()
    var quoteID: String!
    var quoteText: String!
    var quoteSaidBy: String!
    var quoteRating: Int16!
    var quoteIsFavorite: String!
    var quoteTags: [NSNumber]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        print(userID)
        loadTags()
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UITableView.reloadData), name: "reloadData", object: nil)
        //loadQuotes()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func syncQuotes(sender: AnyObject) {
        //deletes any deleted quotes
        
        //edits edited quotes
        
        //pushes any new quotes to database
        myQuoteDataModel.syncQuotes(userID)
        
        updateQuotes()
    }
    
    func reloadAfterDelete() {
        let quoteRequest = NSFetchRequest(entityName: "Quote")
        let quotePredicate = NSPredicate(format: "delete != true")
        quoteRequest.predicate = quotePredicate
        do {
            let quoteResults = try managedContext.executeFetchRequest(quoteRequest) as? [Quote]
            quotes = quoteResults!
        } catch let error as NSError {
            print("failed fetch \(error.localizedDescription)")
        }

        self.tableView.reloadData()
    }
    
    func editQuote(quoteID: String, text: String, saidBy: String, rating: Int16, isFavorite: String, tags: [NSNumber]) {
        self.quoteID = quoteID
        self.quoteText = text
        self.quoteSaidBy = saidBy
        self.quoteRating = rating
        self.quoteIsFavorite = isFavorite
        self.quoteTags = tags
        performSegueWithIdentifier("AddQuote", sender: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        //update data from core data
        print("View did Appear")
        //myQuoteDataModel.loadQuotes(userID)
        let tagRequest = NSFetchRequest(entityName: "Tag")
        do {
            let tagResults = try managedContext.executeFetchRequest(tagRequest) as? [Tag]
            tags = tagResults!
        } catch let error as NSError {
            print("failed fetch \(error.localizedDescription)")
        }
            
        let quoteRequest = NSFetchRequest(entityName: "Quote")
        let quotePredicate = NSPredicate(format: "delete != true")
        quoteRequest.predicate = quotePredicate
        do {
            let quoteResults = try managedContext.executeFetchRequest(quoteRequest) as? [Quote]
            quotes = quoteResults!
        } catch let error as NSError {
            print("failed fetch \(error.localizedDescription)")
        }
        
        print(tags)
        print(quotes)
        
        tableView.reloadData()
    }
    
    func updateQuotes() {
        let quoteRequest = NSFetchRequest(entityName: "Quote")
        do {
            let quoteResults = try managedContext.executeFetchRequest(quoteRequest) as? [Quote]
            quotes = quoteResults!
        } catch let error as NSError {
            print("failed fetch \(error.localizedDescription)")
        }
        print(quotes)
        tableView.reloadData()
    }
    
    func loadTags() {
        let tagRequest = NSFetchRequest(entityName: "Tag")
        do {
            let tagResults = try managedContext.executeFetchRequest(tagRequest) as? [Tag]
            tags = tagResults!
        } catch let error as NSError {
            print("failed fetch \(error.localizedDescription)")
        }
        
        if tags.count == 0 {
            print("loading tags")
            
            var tag = NSEntityDescription.insertNewObjectForEntityForName("Tag", inManagedObjectContext: managedContext) as! Tag
            tag.id = 1
            tag.text = "modern"
            tag = NSEntityDescription.insertNewObjectForEntityForName("Tag", inManagedObjectContext: managedContext) as! Tag
            tag.id = 2
            tag.text = "silly"
            tag = NSEntityDescription.insertNewObjectForEntityForName("Tag", inManagedObjectContext: managedContext) as! Tag
            tag.id = 3
            tag.text = "funny"
            tag = NSEntityDescription.insertNewObjectForEntityForName("Tag", inManagedObjectContext: managedContext) as! Tag
            tag.id = 4
            tag.text = "sports"
            tag = NSEntityDescription.insertNewObjectForEntityForName("Tag", inManagedObjectContext: managedContext) as! Tag
            tag.id = 5
            tag.text = "historical"
            tag = NSEntityDescription.insertNewObjectForEntityForName("Tag", inManagedObjectContext: managedContext) as! Tag
            tag.id = 6
            tag.text = "inspirational"
            tag = NSEntityDescription.insertNewObjectForEntityForName("Tag", inManagedObjectContext: managedContext) as! Tag
            tag.id = 7
            tag.text = "epic"
        }
    }
    
    func loadQuotes() {
        print("loading quotes")
        let quoteOne = NSEntityDescription.insertNewObjectForEntityForName("Quote", inManagedObjectContext: managedContext) as! Quote
        quoteOne.isFavorite = "false"
        quoteOne.rating = 5
        quoteOne.said_by = "somebody"
        quoteOne.text = "I said something that somebody said about someone sometime"
        quoteOne.user_id = userID
        quoteOne.tags = [1, 2]
        
        
        let quoteTwo = NSEntityDescription.insertNewObjectForEntityForName("Quote", inManagedObjectContext: managedContext) as! Quote
        quoteTwo.isFavorite = "true"
        quoteTwo.rating = 9
        quoteTwo.said_by = "Mother Goose"
        quoteTwo.text = "Hey Diddle Diddle, the Cat and the Fiddle"
        quoteTwo.user_id = userID
        quoteTwo.tags = [2]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToViewQuoteTableViewController(segue: UIStoryboardSegue) {
        //nothing goes here
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "AddQuote") {
            //set variables in new controller
            let editQuoteVC = segue.destinationViewController as! EditQuoteViewController
            if editQuoteVC.tags.count == 0 {
                for t in tags {
                    let tagTuple = (data: t, isSet: false)
                    editQuoteVC.tags.append(tagTuple)
                }
            }
            editQuoteVC.userID = userID
            
            if quoteID != nil {
                editQuoteVC.quoteID = quoteID
                editQuoteVC.quoteText = quoteText
                editQuoteVC.quoteSaidBy = quoteSaidBy
                editQuoteVC.quoteRating = Float(quoteRating)
                editQuoteVC.quoteIsFavorite = quoteIsFavorite
                for t in quoteTags {
                    for (i, eqt) in editQuoteVC.tags.enumerate() {
                        if t == NSNumber(short: eqt.data.id) {
                            editQuoteVC.tags[i].isSet = true
                        }
                    }
                }
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("QuoteTableViewCell", forIndexPath: indexPath) as! QuoteTableViewCell
        
        //configure cell
        let quote = quotes[indexPath.row]
        cell.quoteLabel.text = "Quote: " + quote.text
        cell.saidByLabel.text = "Said By: " + quote.said_by
        cell.ratingLabel.text = "Rating: " + String(quote.rating)
        cell.favoriteLabel.text = "Is Favorite: " + String(quote.isFavorite)
        cell.quoteID = quote.id
        cell.onDeleteButtonTapped = {
            self.reloadAfterDelete()
        }
        cell.onEditButtonTapped = {
            self.editQuote(quote.id, text: quote.text, saidBy: quote.said_by, rating: quote.rating, isFavorite: quote.isFavorite, tags: quote.tags)
        }
        var tagsText = [String]()
        for tag in quote.tags {
            for t in tags {
                if t.id == tag.shortValue {
                    tagsText.append(t.text)
                }
            }
        }
        
        cell.tagLabel.text = "Tags: "
        for tt in tagsText {
            cell.tagLabel.text? += " " + tt
        }
        
        return cell
    }
    
    
    
}
