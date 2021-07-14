//
//  Message+CoreDataClass.swift
//  Seal
//
//  Created by tz on 7/7/21.
//
//

import Foundation
import CoreData

@objc(Message)
public class Message: NSManagedObject {
  static var counter = 0
  override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
      super.init(entity: entity, insertInto: context)
    NSLog("Init called! \(Message.counter)")
    Message.counter += 1
  }

  deinit {
    Message.counter -= 1
    NSLog("deinit \(Message.counter)")
  }
}
