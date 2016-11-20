//
//  Tag.swift
//  iQuoteJar
//
//  Created by BRAUER, BOBBY [AG/1155] on 11/16/2016.
//  Copyright © 2016 BRAUER, BOBBY [AG/1155]. All rights reserved.
//

import Foundation

import CoreData

class Tag : NSManagedObject {
    @NSManaged var id: Int16
    @NSManaged var text: String
}

