//
//  NSMessageSender.swift
//  Seal
//
//  Created by tz on 7/7/21.
//

import Foundation
import MessageKit

public class NSMessageSender: NSObject, NSSecureCoding, SenderType {
  public static var supportsSecureCoding: Bool = true

  enum Key: String {
    case senderId
    case displayName
  }

  public let senderId: String
  public let displayName: String

  public init(senderId: String, displayName: String) {
    self.senderId = senderId
    self.displayName = displayName
  }

  public required convenience init?(coder: NSCoder) {
    self.init(
      senderId: coder.decodeObject(forKey: Key.senderId.rawValue) as! String,
      displayName: coder.decodeObject(forKey: Key.displayName.rawValue) as! String
    )
  }

  public func encode(with coder: NSCoder) {
    coder.encode(senderId, forKey: Key.senderId.rawValue)
    coder.encode(displayName, forKey: Key.displayName.rawValue)
  }
}

