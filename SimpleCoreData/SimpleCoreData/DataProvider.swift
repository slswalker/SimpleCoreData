//
//  DataSource.swift
//  SimpleCoreData
//
//  Created by Sam Walker on 10/12/15.
//  Copyright © 2015 Sam Walker. All rights reserved.
//

import CoreData

protocol DataProviderDelegate : class {
    typealias Object
    func didUpdateObjects(withUpdates updates: [DataRowUpdate<Object>])
    func didUpdateSection(withUpdate update: DataSectionUpdate)
}

protocol DataProvider : class  {
    typealias Object
    func numberOfSections() -> Int
    func numberOfItemsInSection(section: Int) -> Int
    func objectAtIndexPath(indexPath: NSIndexPath) -> Object
}

enum DataRowUpdate<Object> {
    case Update(NSIndexPath, Object)
    case Insert(NSIndexPath)
    case Delete(NSIndexPath)
    case Move(NSIndexPath, NSIndexPath)
}

enum DataSectionUpdate {
    case Insert(Int)
    case Delete(Int)
}