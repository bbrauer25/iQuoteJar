//
//  Quote.swift
//  iQuoteJar
//
//  Created by BRAUER, BOBBY [AG/1155] on 11/12/2016.
//  Copyright © 2016 BRAUER, BOBBY [AG/1155]. All rights reserved.
//

import Foundation
import CoreData

class Quote : NSManagedObject {
    @NSManaged var id: String
    @NSManaged var user_id: String
    @NSManaged var isFavorite: String
    @NSManaged var rating: Int16
    @NSManaged var tags: [NSNumber]
    @NSManaged var text: String
    @NSManaged var said_by: String
}

