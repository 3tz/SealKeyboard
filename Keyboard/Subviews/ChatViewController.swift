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

// Some global variables for the sake of the example. Using globals is not recommended!
let sender = Sender(senderId: "any_unique_id", displayName: "Steven")
let messages: [MessageKit.MessageType] = []

extension ChatViewController: MessagesDataSource {

  func currentSender() -> SenderType {
    return Sender(senderId: "any_unique_id", displayName: "Steven")
  }

  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }

  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageKit.MessageType {
    return messages[indexPath.section]
  }
}

extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {}
