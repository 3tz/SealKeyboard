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
import CoreData

class ChatViewController: MessagesViewController, NSFetchedResultsControllerDelegate {

  unowned var controller: KeyboardViewController!
  var fetchedResultsController: NSFetchedResultsController<Message>!
  unowned var currentChat: Chat! = nil

  var messageCount: Int {
    return fetchedResultsController.fetchedObjects?.count ?? 0
  }

  var fetchOffset: Int!
  var numberOfNewMessagesToLoad = 10

  convenience init(keyboardViewController: KeyboardViewController) {
    self.init()
    controller = keyboardViewController
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupMessagesCollectionView()
    reloadMessages()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // Override to add a long press gesture recognizer for menu
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath)

    guard let view = (cell as? TextMessageCell)?.messageContainerView else {
      NSLog("Non-TextMessageCell. No need to add long press gesture recognizer.")
      return cell
    }


    // If a long press gesture recognizer already exists, return cell immediately.
    for recognizer in view.gestureRecognizers ?? [] {
      if let _ = recognizer as? UILongPressGestureRecognizer {
        return cell
      }
    }
    // And add one if not
    view.isUserInteractionEnabled = true
    view.addGestureRecognizer(
      UILongPressGestureRecognizer(target: self, action: #selector(textCellLongPressed(sender:)))
    )
    return cell
  }

  // MARK: methods for updating messages

  func reloadMessages(keepOffset: Bool = false) {
    // Initialize if it's the first time or reinitialize if chat has switched
    if fetchedResultsController == nil || currentChat != ChatManager.shared.currentChat {
      currentChat = ChatManager.shared.currentChat
      let request: NSFetchRequest<Message> = Message.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(key: "coreSentDate", ascending: true)]
      request.fetchBatchSize = 10
      request.includesPendingChanges = false
      request.predicate = NSPredicate(format: "chat = %@", ChatManager.shared.currentChat)

      fetchedResultsController = NSFetchedResultsController(
        fetchRequest: request,
        managedObjectContext: CoreDataContainer.shared.persistentContainer.viewContext,
        sectionNameKeyPath: nil,
        cacheName: "ChatViewController.fetchedResultsController"
      )
      fetchedResultsController.delegate = self

      // Fetch first to get the number of total messages, so offset can be calculated.
      NSFetchedResultsController<Message>.deleteCache(
        withName: "ChatViewController.fetchedResultsController")
      try! fetchedResultsController.performFetch()
      fetchOffset = max(messageCount - numberOfNewMessagesToLoad, 0)
    }

    fetchedResultsController.fetchRequest.fetchOffset = fetchOffset
    NSFetchedResultsController<Message>.deleteCache(
      withName: "ChatViewController.fetchedResultsController")
    try! fetchedResultsController.performFetch()
    if keepOffset {
      self.messagesCollectionView.reloadDataAndKeepOffset()
    } else {
      messagesCollectionView.reloadData()
      messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
    }
  }

  func appendStringMessage(_ string: String, sender: NSMessageSender) {
    ChatManager.shared.appendMessageToCurrentChat(
      coreMessageId: UUID().uuidString,
      coreSentDate: Date.init(),
      coreSender: sender,
      coreKind: NSMessageKind(message: MessageKind.text(string))
    )
    reloadMessages()
    reloadMessagesCollectionViewLastSection()
  }

  func reloadMessagesCollectionViewLastSection() {
      // Reload last section to update header/footer labels
    messagesCollectionView.performBatchUpdates({
        if messageCount >= 2 {
          messagesCollectionView.reloadSections([messageCount - 2])
        }
      },
      completion: { [weak self] _ in
        if self?.isLastSectionVisible() == true {
          self?.messagesCollectionView.scrollToLastItem(animated: true)
        }
      }
    )
  }

  func deleteAllChat() {
    let context = CoreDataContainer.shared.persistentContainer.viewContext
    try! context.execute(NSBatchDeleteRequest(fetchRequest: Message.fetchRequest()))
    CoreDataContainer.shared.saveContext()
    reloadMessages()
  }

  private(set) lazy var refreshControl: UIRefreshControl = {
    let control = UIRefreshControl()
    control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    return control
  }()

  @objc func loadMoreMessages() {
    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
      DispatchQueue.main.async {
        // reduce the fetch offset and load from there
        // Fetch offset of 0 means load everything from message 0 and up, i.e., all messages
        self.fetchOffset = max(0, self.fetchOffset-self.numberOfNewMessagesToLoad)

        // Load linearly more for each refresh
        if self.fetchOffset != 0 {
          self.numberOfNewMessagesToLoad += self.numberOfNewMessagesToLoad
        }
        self.reloadMessages(keepOffset: true)
        self.refreshControl.endRefreshing()
      }
    }
  }

  @objc func textCellLongPressed(sender: UILongPressGestureRecognizer) {
    if sender.state != .began {
      return
    }

    guard let label = sender.view?.subviews[0] as? MessageLabel else {
      NSLog("Non-MessageLabel long pressed.")
      NSLog("\(sender)")
      return
    }

    let coordinate = sender.location(in: label)
    let popover = MessageCellLongPressMenuViewController(
      parentController: controller, pressedLabel: label)
    popover.modalPresentationStyle = .popover
    popover.preferredContentSize = CGSize(
      width: KeyboardSpecs.messageCellPopoverMenuWidth,
      height: KeyboardSpecs.messageCellPopoverMenuHeight)
    popover.popoverPresentationController?.delegate = self
    popover.popoverPresentationController?.sourceView = label
    popover.popoverPresentationController?.sourceRect = CGRect(
      x: coordinate.x, y: coordinate.y, width: 0, height: 0)
    popover.popoverPresentationController?.backgroundColor = .darkGray
    popover.popoverPresentationController?.permittedArrowDirections = .any
    present(popover, animated: true, completion: nil)
  }

  // MARK: view setup

  func setupMessagesCollectionView() {
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    showMessageTimestampOnSwipeLeft = true
    messagesCollectionView.refreshControl = refreshControl

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

  func isLastSectionVisible() -> Bool {
      guard messageCount != 0 else { return false }
      let lastIndexPath = IndexPath(item: 0, section: messageCount - 2)
      return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
  }

}

extension ChatViewController: MessagesDataSource {

  func currentSender() -> SenderType {
    return ChatView.senderMe
  }

  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messageCount
  }

  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return fetchedResultsController.fetchedObjects![indexPath.section]
  }
}

extension ChatViewController: MessagesDisplayDelegate {
  func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

      let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
      return .bubbleTail(tail, .curved)
  }

}

extension ChatViewController: MessagesLayoutDelegate {}

extension ChatViewController: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
}
