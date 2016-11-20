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
    
    
    @IBAction func SaveButton(sender: AnyObject) {
        saveQuote()
    }

    var userID: String! //passed from segue, user id from login
    var tags = [(data: Tag, isSet: Bool)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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