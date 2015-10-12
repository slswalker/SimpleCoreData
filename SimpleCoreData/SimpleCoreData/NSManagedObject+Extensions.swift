//
//  NSManagedObject+Extensions.swift
//  SimpleCoreData
//
//  Created by Sam Walker on 10/9/15.
//  Copyright © 2015 Sam Walker. All rights reserved.
//

import CoreData

public class ManagedObject: NSManagedObject {
    @NSManaged public private(set) var identifier: NSString?
    
    public func isOnlyLocal() -> Bool {
        return identifier != nil
    }
}

public protocol ManagedObjectType : class {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    static var defaultPredicate: NSPredicate { get }
    var managedObjectContext: NSManagedObjectContext? { get }
}

extension ManagedObjectType {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    public static var sortedFetchRequest: NSFetchRequest {
        let request = NSFetchRequest(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        request.predicate = defaultPredicate
        return request
    }
}

extension ManagedObjectType where Self: ManagedObject {
    
    public static func findOrCreateInContext(moc: NSManagedObjectContext,
        matchingPredicate predicate: NSPredicate, configure: Self -> ()) -> Self
    {
        guard let obj = findOrFetchInContext(moc, matchingPredicate: predicate)
            else {
                let newObject: Self = moc.insertObject()
                configure(newObject)
                return newObject
        }
        return obj
    }
    
    
    public static func findOrFetchInContext(moc: NSManagedObjectContext,
        matchingPredicate predicate: NSPredicate) -> Self?
    {
        guard let obj = materializedObjectInContext(moc,
            matchingPredicate: predicate)
            else {
                return fetchInContext(moc) { request in
                    request.predicate = predicate
                    request.returnsObjectsAsFaults = false
                    request.fetchLimit = 1
                    }.first
        }
        return obj
    }
    
    public static func fetchInContext(context: NSManagedObjectContext,
        @noescape configurationBlock: NSFetchRequest -> ()) -> [Self]
    {
        let request = NSFetchRequest(entityName: Self.entityName)
        configurationBlock(request)
        guard let result = try! context.executeFetchRequest(request) as? [Self]
            else {
                fatalError("Fetched objects have wrong type")
        }
        return result
    }
    
    public static func fetchInContext(context: NSManagedObjectContext, forIdentifier identifier: String) -> Self? {
        let request = NSFetchRequest(entityName: Self.entityName)
        request.predicate = NSPredicate(format: "%K == %@", "identifier", identifier)
        guard let result = try! context.executeFetchRequest(request) as? [Self]
            else {
                fatalError("Fetched objects have wrong type")
        }
        return result.count > 0 ? result.first : nil
    }
    
    public static func countInContext(context: NSManagedObjectContext, @noescape configurationBlock: NSFetchRequest -> () = { _ in }) -> Int {
        let request = NSFetchRequest(entityName: entityName)
        configurationBlock(request)
        var error: NSError?
        let result = context.countForFetchRequest(request, error: &error)
        guard result != NSNotFound else { fatalError("Failed to execute fetch request: \(error)") }
        return result
    }
    
    public static func materializedObjectInContext(moc: NSManagedObjectContext,
        matchingPredicate predicate: NSPredicate) -> Self?
    {
        for obj in moc.registeredObjects where !obj.fault {
            guard let res = obj as? Self where predicate.evaluateWithObject(res)
                else { continue }
            return res
        }
        return nil
    }
}
