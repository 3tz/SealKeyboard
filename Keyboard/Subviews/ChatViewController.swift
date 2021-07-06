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

  weak var controller: KeyboardViewController!

  convenience init(keyboardViewController: KeyboardViewController) {
    self.init()
    controller = keyboardViewController
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    showMessageTimestampOnSwipeLeft = true

    let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout

    layout?.collectionView?.backgroundColor = KeyboardSpecs.chatViewBackgroundColor

    // Hide the outgoing avatar and adjust the label alignment to line up with the messages
    layout?.setMessageOutgoingAvatarSize(.zero)
    let outgoingAlignment = LabelAlignment(
      textAlignment: .right,
      textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    )
    layout?.setMessageOutgoingMessageTopLabelAlignment(outgoingAlignment)
    layout?.setMessageOutgoingMessageBottomLabelAlignment(outgoingAlignment)

    // Set outgoing avatar to overlap with the message bubble
    layout?.setMessageIncomingAvatarSize(.zero)
    let incomingAlignment = LabelAlignment(
      textAlignment: .left,
      textInsets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    )
    layout?.setMessageIncomingMessageTopLabelAlignment(incomingAlignment)
    layout?.setMessageIncomingMessageBottomLabelAlignment(incomingAlignment)
  }


  func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
      let name = message.sender.displayName
      return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
  }

  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
      return 20
  }


}

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

// Some global variables for the sake of the example. Using globals is not recommended!
let senderMe = Sender(senderId: "s01", displayName: "me")
let senderThem = Sender(senderId: "s02", displayName: "bob")
let messages: [MessageType] = [
  Message(
    sender: senderMe,
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
    from bob
    """)
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

extension ChatViewController: MessagesDataSource {

  func currentSender() -> SenderType {
    return senderMe
  }

  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }

  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
}

extension ChatViewController: MessagesDisplayDelegate {
  func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

      let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
      return .bubbleTail(tail, .curved)
  }

}

extension ChatViewController: MessagesLayoutDelegate {}
