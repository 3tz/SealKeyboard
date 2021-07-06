/*
MIT License

Copyright (c) 2017-2020 MessageKit

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
//
//  LogViewController.swift
//  Seal
//  Modified from MessageKit
//
//  Created by tz on 7/3/21.
//

import Foundation
import UIKit
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


let senderThem = Sender(senderId: "s02", displayName: "bob")

class ChatViewController: MessagesViewController {

  weak var controller: KeyboardViewController!

  var messages: [MessageType] = [
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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
  }

  func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
      let name = message.sender.displayName
      return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
  }

  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
      return 20
  }

  // MARK: internal methods for modifying messages

  func appendStringMessage(_ string: String, sender: Sender) {
    appendMessage(Message(
      sender: sender,
      messageId: "\(String(messages.count))",
      sentDate: Date.init(),
      kind: .text(string)
    ))
  }

  // MARK: Helper methods

  private func appendMessage(_ message: Message) {
      messages.append(message)
      // Reload last section to update header/footer labels and insert a new one
      messagesCollectionView.performBatchUpdates({
          messagesCollectionView.insertSections([messages.count - 1])
          if messages.count >= 2 {
              messagesCollectionView.reloadSections([messages.count - 2])
          }
      }, completion: { [weak self] _ in
          if self?.isLastSectionVisible() == true {
              self?.messagesCollectionView.scrollToLastItem(animated: true)
          }
      })
  }

  private func isLastSectionVisible() -> Bool {
      guard !messages.isEmpty else { return false }
      let lastIndexPath = IndexPath(item: 0, section: messages.count - 2)
      return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
  }

}



extension ChatViewController: MessagesDataSource {

  func currentSender() -> SenderType {
    return ChatView.senderMe
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
