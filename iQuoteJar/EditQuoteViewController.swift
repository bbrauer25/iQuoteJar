//
//  EditQuoteViewController.swift
//  iQuoteJar
//
//  Created by BRAUER, BOBBY [AG/1155] on 11/12/2016.
//  Copyright © 2016 BRAUER, BOBBY [AG/1155]. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class EditQuoteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var quoteTextField: UITextField!
    @IBOutlet weak var saidByTextField: UITextField!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var isFavoriteSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    var quoteText: String!
    var quoteSaidBy: String!
    var quoteRating: Float!
    var quoteIsFavorite: String!
    var userID: String! //passed from segue, user id from login
    var tags = [(data: Tag, isSet: Bool)]()
    var quoteID: String!
    
    @IBAction func SaveButton(sender: AnyObject) {
        saveQuote()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (quoteID != nil) {
            print("My QuoteID is: " + quoteID)
            quoteTextField.text = quoteText
            saidByTextField.text = quoteSaidBy
            ratingSlider.value = quoteRating
            if quoteIsFavorite! == "true" {
                isFavoriteSwitch.on = true
            } else {
                isFavoriteSwitch.on = false
            }
        }
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.reloadData()
        /*if quote != nil {
            //populate text
            quoteTextField.text = quote.text
            saidByTextField.text = quote.said_by
            ratingSlider.value = Float(quote.rating)
            if quote.isFavorite {
                isFavoriteSwitch.setOn(true, animated: true)
            }
        }*/
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
                cell.accessoryType = .None
                tags[indexPath.row].isSet = false
            } else {
                cell.accessoryType = .Checkmark
                tags[indexPath.row].isSet = true
            }
        }
    }
    
    func saveQuote() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        var goodInput = true
        var badInputMessage = ""
        
        if quoteTextField.text == "" {
            goodInput = false
            badInputMessage += " *ENTER QUOTE TEXT* "
        }
        if saidByTextField.text == "" {
            goodInput = false
            badInputMessage += " *ENTER SAID BY* "
        }
        
        if goodInput {
            if quoteID != nil {
                let fetchRequest = NSFetchRequest(entityName: "Quote")
                let quotePredicate = NSPredicate(format: "id = %@", quoteID)
                fetchRequest.predicate = quotePredicate
                do {
                    let quoteContents = try managedContext.executeFetchRequest(fetchRequest) as! [Quote]
                    for q in quoteContents {
                        if q.id != "" {
                            q.edit = true
                        }
                        q.text = quoteTextField.text!
                        q.said_by = saidByTextField.text!
                        q.rating = Int16(ratingSlider.value)
                        if isFavoriteSwitch.on {
                            q.isFavorite = "true"
                        } else {
                            q.isFavorite = "false"
                        }
                        
                        var tagArray = [NSNumber]()
                        //iterate through cells in table view and add tags for any that are checked
                        for t in tags {
                            if t.isSet {
                                tagArray.append(NSNumber(short: t.data.id))
                            }
                        }
                        q.tags = tagArray
                        self.performSegueWithIdentifier("ShowViewQuotes", sender: self)
                    }
                } catch {
                    fatalError("Failed to fetch quotes: \(error)")
                }
            } else {
                let newQuote = NSEntityDescription.insertNewObjectForEntityForName("Quote", inManagedObjectContext: managedContext) as! Quote
                newQuote.text = quoteTextField.text!
                newQuote.said_by = saidByTextField.text!
                newQuote.rating = Int16(ratingSlider.value)
                newQuote.user_id = userID
                if isFavoriteSwitch.on {
                    newQuote.isFavorite = "true"
                } else {
                    newQuote.isFavorite = "false"
                }

                var tagArray = [NSNumber]()
                //iterate through cells in table view and add tags for any that are checked
                for t in tags {
                    if t.isSet {
                        tagArray.append(NSNumber(short: t.data.id))
                    }
                }
                
                newQuote.tags = tagArray
                self.performSegueWithIdentifier("ShowViewQuotes", sender: self)
            }
        } else {
            badInputAlert(badInputMessage)
        }
    }
    
    func badInputAlert(badInputMessage: String) {
        let ac = UIAlertController(title: "Bad Input", message: badInputMessage, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowViewQuotes") {
            let viewQuoteVC = segue.destinationViewController as! ViewQuoteTableViewController
            viewQuoteVC.userID = userID
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(tags.count)
        return tags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        //configure cell
        print(tags[indexPath.row].data.text)
        cell.textLabel?.text = tags[indexPath.row].data.text
        if tags[indexPath.row].isSet {
            cell.accessoryType = .Checkmark
        }

        return cell
    }
    
}