//
//  NSManagedObjectContext.swift
//  SimpleCoreData
//
//  Created by Sam Walker on 10/9/15.
//  Copyright © 2015 Sam Walker. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    public static func contextForCoordinator(
        coordinator: NSPersistentStoreCoordinator, concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext
    {
        let context = NSManagedObjectContext(
            concurrencyType: concurrencyType)
        context.persistentStoreCoordinator = coordinator
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyStoreTrumpMergePolicyType)
        return context
    }
    
    public func insertObject<A: ManagedObject where A: ManagedObjectType>() -> A {
        guard let obj = NSEntityDescription.insertNewObjectForEntityForName(
            A.entityName, inManagedObjectContext: self) as? A
            else { fatalError("Wrong object type") }
        return obj
    }
 
    public func saveIfHaveChanges() -> Bool {
        do {
            if self.hasChanges {
                try save()
            }
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    public func performChanges(block: () -> ()) {
        performBlock {
            block()
            self.saveIfHaveChanges()
        }
    }
}
