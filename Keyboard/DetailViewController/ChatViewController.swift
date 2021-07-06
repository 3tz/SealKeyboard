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


let senderThem = Sender(senderId: "s02", displayName: "bob")

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
      messageId: "\(String(Messages.default.count))",
      sentDate: Date.init(),
      kind: .text(string)
    ))
  }

  // MARK: Helper methods

  private func appendMessage(_ message: Message) {
      Messages.default.append(message)
      // Reload last section to update header/footer labels and insert a new one
      messagesCollectionView.performBatchUpdates({
          messagesCollectionView.insertSections([Messages.default.count - 1])
          if Messages.default.count >= 2 {
              messagesCollectionView.reloadSections([Messages.default.count - 2])
          }
      }, completion: { [weak self] _ in
          if self?.isLastSectionVisible() == true {
              self?.messagesCollectionView.scrollToLastItem(animated: true)
          }
      })
  }

  private func isLastSectionVisible() -> Bool {
      guard !Messages.default.isEmpty else { return false }
      let lastIndexPath = IndexPath(item: 0, section: Messages.default.count - 2)
      return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
  }

}

extension ChatViewController: MessagesDataSource {

  func currentSender() -> SenderType {
    return ChatView.senderMe
  }

  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return Messages.default.count
  }

  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return Messages.default[indexPath.section]
  }
}

extension ChatViewController: MessagesDisplayDelegate {
  func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

      let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
      return .bubbleTail(tail, .curved)
  }

}

extension ChatViewController: MessagesLayoutDelegate {}
