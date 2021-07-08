//
//  MessageSenderTransformer.swift
//  Seal
//
//  Created by tz on 7/8/21.
//

import UIKit

@objc(MessageSenderTransformer)
class MessageSenderTransformer: NSSecureUnarchiveFromDataTransformer {

  override class func allowsReverseTransformation() -> Bool {
    return true
  }

  override class func transformedValueClass() -> AnyClass {
    return NSMessageSender.self
  }

  override class var allowedTopLevelClasses: [AnyClass] {
    return [NSMessageSender.self]
  }

  override func transformedValue(_ value: Any?) -> Any? {
    guard let data = value as? Data else {
      fatalError("Wrong data type: value must be a Data object; received \(type(of: value))")
    }
    return super.transformedValue(data)
  }

  override func reverseTransformedValue(_ value: Any?) -> Any? {
    guard let sender = value as? NSMessageSender else {
      fatalError("Wrong data type: value must be a CoreDataMessageSender object; received \(type(of: value))")
    }
    return super.reverseTransformedValue(sender)
  }
}

extension NSValueTransformerName {
  static let messageSenderTransformer = NSValueTransformerName(rawValue: "MessageSenderTransformer")
}
