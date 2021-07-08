//
//  NSMessageKind.swift
//  Seal
//
//  Created by tz on 7/8/21.
//

import Foundation
import MessageKit

public class NSMessageKind: NSObject, NSSecureCoding {
  public static var supportsSecureCoding: Bool = true

  enum Key: String {
    case kind
    case text
  }

  public let kind: String

  // Atrributes for MessageKind.text
  public let text: String


  public init(message: MessageKind) {
    switch message {
      case .text(let text):
        self.kind = "text"
        self.text = text
      default:
        fatalError("MessageKind \(message) not yet supported")
    }
  }

  public required convenience init?(coder: NSCoder) {
    let kind = coder.decodeObject(forKey: Key.kind.rawValue) as! String

    let message: MessageKind
    switch kind {
      case "text":
        message = MessageKind.text(coder.decodeObject(forKey: Key.text.rawValue) as! String)
      default:
        fatalError()
    }

    self.init(message: message)
  }


  public func encode(with coder: NSCoder) {
    coder.encode(kind, forKey: Key.kind.rawValue)
    switch kind {
      case "text":
        coder.encode(text, forKey: Key.text.rawValue)
      default:
        fatalError("MessageKind \(kind) not yet supported")
    }
  }

  public func asMessageKind() -> MessageKind {
    switch kind {
      case "text":
        return MessageKind.text(text)
      default:
        fatalError()
    }
  }
}

