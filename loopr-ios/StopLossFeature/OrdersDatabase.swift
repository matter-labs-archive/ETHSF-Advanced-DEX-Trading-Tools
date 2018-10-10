//
//  OrdersDatabase.swift
//  loopr-ios
//
//  Created by Anton Grigorev on 09.10.2018.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import CoreData

class OrdersDatabase {
    
    enum DataBaseError: Error {
        case noSuchOrderInStorage
        case problemsWithInsertingNewEntity
        case cantSaveOrderInStorage
    }
    
    lazy var container: NSPersistentContainer = NSPersistentContainer(name: "loopr_ios")
    private lazy var mainContext = self.container.viewContext
    
    init() {
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
    }
    
    public func getAllOrders() -> [OrderCDModel] {
        let requestOrders: NSFetchRequest<OrderCD> = OrderCD.fetchRequest()
        do {
            let results = try mainContext.fetch(requestOrders)
            return results.map {
                return OrderCDModel.fromCoreData(crModel: $0)
            }
            
        } catch {
            print(error)
            return []
        }
    }
    
    public func saveOrder(order: OrderCDModel?, completion: @escaping (Error?) -> Void) {
        container.performBackgroundTask { (context) in
            guard let order = order else {
                return
            }
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "OrderCD", into: context) as? OrderCD else {
                DispatchQueue.main.async {
                    completion(DataBaseError.cantSaveOrderInStorage)
                }
                return
            }
            entity.orderHash = order.hash
            entity.stopLoss = order.stopLoss
            do {
                try context.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    public func deleteOrder(order: OrderCDModel, completion: @escaping (Error?) -> Void) {
        let requestOrder: NSFetchRequest<OrderCD> = OrderCD.fetchRequest()
        requestOrder.predicate = NSPredicate(format: "hash = %@", order.hash)
        do {
            let results = try mainContext.fetch(requestOrder)
            guard let result = results.first else {
                DispatchQueue.main.async {
                completion(DataBaseError.noSuchOrderInStorage)
                }
                return
            }
            mainContext.delete(result)
            try mainContext.save()
            DispatchQueue.main.async {
                completion(nil)
            }
        } catch {
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    public func deleteOrder(order: Order, completion: @escaping (Error?) -> Void) {
        let requestOrder: NSFetchRequest<OrderCD> = OrderCD.fetchRequest()
        requestOrder.predicate = NSPredicate(format: "hash = %@", order.originalOrder.hash)
        do {
            let results = try mainContext.fetch(requestOrder)
            guard let result = results.first else {
                DispatchQueue.main.async {
                    completion(DataBaseError.noSuchOrderInStorage)
                }
                return
            }
            mainContext.delete(result)
            try mainContext.save()
            DispatchQueue.main.async {
                completion(nil)
            }
        } catch {
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    public func getOrder(order: OrderCDModel) -> OrderCDModel? {
        let requestOrder: NSFetchRequest<OrderCD> = OrderCD.fetchRequest()
        requestOrder.predicate = NSPredicate(format: "orderHash = %@", order.hash)
        do {
            let results = try mainContext.fetch(requestOrder)
            return results.map {
                return OrderCDModel.fromCoreData(crModel: $0)
                }.first
        } catch {
            return nil
        }
    }
    
    public func getOrder(order: Order) -> OrderCDModel? {
        let requestOrder: NSFetchRequest<OrderCD> = OrderCD.fetchRequest()
        requestOrder.predicate = NSPredicate(format: "orderHash = %@", order.originalOrder.hash)
        do {
            let results = try mainContext.fetch(requestOrder)
            return results.map {
                return OrderCDModel.fromCoreData(crModel: $0)
                }.first
        } catch {
            return nil
        }
    }
    
    public func getOrder(hash: String) -> OrderCDModel? {
        let requestOrder: NSFetchRequest<OrderCD> = OrderCD.fetchRequest()
        requestOrder.predicate = NSPredicate(format: "orderHash = %@", hash)
        do {
            let results = try mainContext.fetch(requestOrder)
            return results.map {
                return OrderCDModel.fromCoreData(crModel: $0)
                }.first
        } catch {
            return nil
        }
    }
}
