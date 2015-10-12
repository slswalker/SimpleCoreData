//
//  ContextOwnerType.swift
//  SimpleCoreData
//
//  Created by Sam Walker on 10/12/15.
//  Copyright © 2015 Sam Walker. All rights reserved.
//

import CoreData

protocol ContextOwnerType : class {
    var mainContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
}

extension ContextOwnerType {
    func setupContextNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    
    func contextDidSave(notification: NSNotification) {
        if let object = notification.object as? NSManagedObjectContext {
            if object == mainContext {
                mainContextDidSave(notification)
            } else if object == backgroundContext {
                backgroundContextDidSave(notification)
            }
        }
    }
    
    func mainContextDidSave(notification: NSNotification) {
        let context = backgroundContext
        context.performBlock { () -> Void in
            context.mergeChangesFromContextDidSaveNotification(notification)
        }
    }
    
    func backgroundContextDidSave(notification: NSNotification) {
        if NSThread.isMainThread() {
            mainContext.mergeChangesFromContextDidSaveNotification(notification)
        } else {
            let context = mainContext
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                context.mergeChangesFromContextDidSaveNotification(notification)
            })
        }
    }
}