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
  var chats = ["chat 1", "chat 2", "chat 3", "chat 4"]

  //  unowned var controller: KeyboardViewController!

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chats.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    cell.textLabel?.text = chats[indexPath.row]

    return cell
  }

//  convenience init(parentController: KeyboardViewController) {
//    self.init()
//    controller = parentController
//  }

}
