//
//  MessageTransformer.swift
//  Seal
//
//  Created by tz on 7/8/21.
//

import UIKit

@objc(MessageKindTransformer)
class MessageKindTransformer: NSSecureUnarchiveFromDataTransformer {

  override class func allowsReverseTransformation() -> Bool {
    return true
  }

  override class func transformedValueClass() -> AnyClass {
    return NSMessageKind.self
  }

  override class var allowedTopLevelClasses: [AnyClass] {
    return [NSMessageKind.self]
  }

  override func transformedValue(_ value: Any?) -> Any? {
    guard let data = value as? Data else {
      fatalError("Wrong data type: value must be a Data object; received \(type(of: value))")
  }
    return super.transformedValue(data)
  }

  override func reverseTransformedValue(_ value: Any?) -> Any? {
  guard let kind = value as? NSMessageKind else {
    fatalError("Wrong data type: value must be a CoreDataMessageKind object; received \(type(of: value))")
  }
    return super.reverseTransformedValue(kind)
  }
}

extension NSValueTransformerName {
  static let MessageKindTransformer = NSValueTransformerName(rawValue: "MessageKindTransformer")
}
