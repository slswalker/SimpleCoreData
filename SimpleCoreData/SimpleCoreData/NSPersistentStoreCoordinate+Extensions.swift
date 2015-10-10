//
//  NSPersistentStoreCoordinate+Extensions.swift
//  SimpleCoreData
//
//  Created by Sam Walker on 10/9/15.
//  Copyright © 2015 Sam Walker. All rights reserved.
//

import CoreData

extension NSPersistentStoreCoordinator {
    
    public static func coordinatorForModelWithName(name: String) -> NSPersistentStoreCoordinator
    {
        let modelURL = NSBundle.mainBundle().URLForResource(name, withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let url = storeURLForName(name)
        
        // Throw if fails
        try! coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                    configuration: nil, URL: url, options: nil)
        
        return coordinator
    }
    
    private static func storeURLForName(name: String) -> NSURL {
        let urlExtension = "sqlite"
        let fm = NSFileManager.defaultManager()
        let documentDirURL = try! fm.URLForDirectory(.DocumentDirectory,
            inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        return documentDirURL
            .URLByAppendingPathComponent(name)
            .URLByAppendingPathExtension(urlExtension)
    }
    
}
