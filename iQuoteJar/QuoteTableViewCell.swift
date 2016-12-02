//
//  QuoteTableViewCell.swift
//  iQuoteJar
//
//  Created by BRAUER, BOBBY [AG/1155] on 11/18/2016.
//  Copyright © 2016 BRAUER, BOBBY [AG/1155]. All rights reserved.
//

import UIKit

class QuoteTableViewCell: UITableViewCell {
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var saidByLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    var quoteID: String!
    var onDeleteButtonTapped: (() -> Void)? = nil
    var onEditButtonTapped: (() -> Void)? = nil
    
    @IBAction func EditQuote(sender: AnyObject) {
        print("I pressed the edit button")
        print(quoteID)
        if let onEditButtonTapped = self.onEditButtonTapped {
            onEditButtonTapped()
        }
        //notification center - segue to editVC
    }
    
    @IBAction func DeleteQuote(sender: AnyObject) {
        let myQuoteDataModel = QuoteDataModel()
        print("I pressed the delete button")
        print(quoteID)
        myQuoteDataModel.deleteQuote(quoteID)
        if let onDeleteButtonTapped = self.onDeleteButtonTapped {
            onDeleteButtonTapped()
        }
        //NSNotificationCenter.defaultCenter().postNotificationName("reloadData", object: self)
    }
}
