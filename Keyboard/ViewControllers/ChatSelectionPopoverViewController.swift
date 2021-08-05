//
//  ChatSelectionPopoverViewController.swift
//  Keyboard
//
//  Created by tz on 7/19/21.
//

import Foundation
import UIKit
import CoreData

class ChatSelectionPopoverViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  let reuseIdentifier = "ChatSelectionPopoverViewController.cellReuseID"

  unowned var controller: KeyboardViewController!
  var fetchedResultsController: NSFetchedResultsController<Chat>!

  var messageCount: Int {
    return fetchedResultsController.fetchedObjects?.count ?? 0
  }

  convenience init(parentController: KeyboardViewController) {
    self.init()
    controller = parentController
  }

  // MARK: TableView overrides

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    reloadChats()
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messageCount
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    cell.textLabel?.text = fetchedResultsController.fetchedObjects![indexPath.row].displayTitle
    cell.textLabel?.font = cell.textLabel?.font.withSize(KeyboardSpecs.popupViewCellFontSize)
    cell.accessoryType = (indexPath.row == ChatManager.shared.currentIndex) ? .checkmark : .none

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    ChatManager.shared.setCurrentIndex(indexPath.row)
    reloadChats()
    controller.updateCurrentChatTitle()
    // refresh chatviewcontroller to load the messages in the newly switched chat
    controller.detailViewController.chatViewController.reloadMessages()
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      ChatManager.shared.deleteChat(at: indexPath.row)
      try! fetchedResultsController.performFetch()
      controller.updateCurrentChatTitle()
      controller.detailViewController.chatViewController.reloadMessages()
      tableView.deleteRows(at: [indexPath], with: .fade)
      tableView.reloadData()
    }
  }

  // MARK: Data loading
  func reloadChats() {
    if fetchedResultsController == nil {
      let request: NSFetchRequest<Chat> = Chat.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(key: "lastEditTime", ascending: false)]
      request.includesPendingChanges = false

      fetchedResultsController = NSFetchedResultsController(
        fetchRequest: request,
        managedObjectContext: CoreDataContainer.shared.persistentContainer.viewContext,
        sectionNameKeyPath: nil,
        cacheName: "ChatSelectionPopupViewController.fetchedResultsController"
      )
      fetchedResultsController.delegate = self
    }

    try! fetchedResultsController.performFetch()
    tableView.reloadData()
  }


}
