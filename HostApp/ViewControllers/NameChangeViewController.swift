//
//  NameChangeViewController.swift
//  Seal
//
//  Created by tz on 8/11/21.
//

import UIKit

class NameChangeViewController: UITableViewController {
  let cellReuseID =  "NameChangeViewController.cellReuseID"
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Your Display Name"
    navigationItem.largeTitleDisplayMode = .never
    view.backgroundColor = .systemGroupedBackground
    tableView.register(NameChangeCustomCell.self, forCellReuseIdentifier: cellReuseID)
    tableView.rowHeight = 40
  }


  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as! NameChangeCustomCell

    let userDefaults = UserDefaults(suiteName: "group.com.3tz.seal")!
    let displayName = userDefaults.string(forKey: UserDefaultsKeys.chatDisplayName.rawValue)!
    cell.controller = self
    cell.textField.text = displayName
    cell.textField.becomeFirstResponder()
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    return
  }
}


