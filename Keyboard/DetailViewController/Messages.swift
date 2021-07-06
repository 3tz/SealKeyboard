//
//  Messages.swift
//  Keyboard
//
//  Created by tz on 7/6/21.
//

import Foundation
import MessageKit

public struct Sender: SenderType {
    public let senderId: String

    public let displayName: String
}


public struct Message: MessageType {
  public let sender: SenderType
  public let messageId: String
  public let sentDate: Date
  public let kind: MessageKind
}

class Messages{
  private var buffer: [Message] = [
    Message(
      sender: ChatView.senderMe,
      messageId: "a01",
      sentDate: Date.init(),
      kind: .text("abcdefg some text")
    ),
    Message(
      sender: senderThem,
      messageId: "a02",
      sentDate: Date.init(),
      kind: .text("""
      line 1
      line 2
      line 3
      line 4
      line 5 line 5 line 5 line 5 line 5 line 5 line 5 line 5
      from bob
      """)
    )
  ]

  var count: Int {
    return buffer.count
  }

  var isEmpty: Bool {
    return buffer.isEmpty
  }

  func append(_ message: Message) {
    buffer.append(message)
  }

  subscript(index: Int) -> Message {
    get {
      return buffer[index]
    }
    set(item) {
      buffer.insert(item, at: index)
    }
  }
}
