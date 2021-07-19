//
//  ChatSelectionPopoverViewController.swift
//  Keyboard
//
//  Created by tz on 7/19/21.
//

import Foundation
import UIKit

class ChatSelectionPopoverViewController: UITableViewController {
  let reuseIdentifier = "ChatSelectionPopoverViewController.cellReuseID"

  unowned var controller: KeyboardViewController!

  convenience init(parentController: KeyboardViewController) {
    self.init()
    controller = parentController
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return controller.chats.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    cell.textLabel?.text = controller.chats[indexPath.row]

    cell.accessoryType = (indexPath.row == controller.selectedChatIndex) ? .checkmark : .none

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    controller.selectedChatIndex = indexPath.row
    tableView.reloadData()
    controller.updateCurrentChatTitle()
  }

}
