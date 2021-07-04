//
//  LogViewController.swift
//  Seal
//
//  Created by tz on 7/3/21.
//

import Foundation
import UIKit
import MessageKit

class ChatViewController: MessagesViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
  }

}

public struct Sender: SenderType {
    public let senderId: String

    public let displayName: String
}

public struct Message: MessageKit.MessageType {
  public let sender: SenderType
  public let messageId: String
  public let sentDate: Date
  public let kind: MessageKind
}

// Some global variables for the sake of the example. Using globals is not recommended!
let sender = Sender(senderId: "any_unique_id", displayName: "Steven")
let messages: [MessageKit.MessageType] = [
  Message(
    sender: Sender(senderId: "me", displayName: "Steven"),
    messageId: "a01",
    sentDate: Date.init(),
    kind: .text("abcdefg some text")
  ),
  Message(
    sender: Sender(senderId: "bob", displayName: "bob"),
    messageId: "a02",
    sentDate: Date.init(),
    kind: .text("from bob")
  )
]

extension ChatViewController: MessagesDataSource {

  func currentSender() -> SenderType {
    return Sender(senderId: "me", displayName: "Steven")
  }

  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }

  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageKit.MessageType {
    return messages[indexPath.section]
  }
}

extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {}
