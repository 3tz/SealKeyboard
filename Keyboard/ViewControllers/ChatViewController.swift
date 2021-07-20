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

  // MARK: methods for updating messages

  func reloadMessages(keepOffset: Bool = false) {
    if fetchedResultsController == nil {
      let request: NSFetchRequest<Message> = Message.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(key: "coreMessageId", ascending: true)]
      request.fetchBatchSize = 10
      request.includesPendingChanges = false

      fetchedResultsController = NSFetchedResultsController(
        fetchRequest: request,
        managedObjectContext: controller.persistentContainer.viewContext,
        sectionNameKeyPath: nil,
        cacheName: "ChatViewController.fetchedResultsController"
      )
      fetchedResultsController.delegate = self

      // Fetch first to get the number of total messages, so offset can be calculated.
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
    }
  }

  func appendStringMessage(_ string: String, sender: NSMessageSender) {
    let message = Message(context: controller.persistentContainer.viewContext)

    message.coreSentDate = Date.init()
    message.coreMessageId = "\(String(messageCount))"
    message.coreKind = NSMessageKind(message: MessageKind.text(string))
    message.coreSender = sender
    controller.saveContext()

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
    let context = controller.persistentContainer.viewContext
    try! context.execute(NSBatchDeleteRequest(fetchRequest: Message.fetchRequest()))
    controller.saveContext()
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
