//
//  NameChangeViewController.swift
//  Seal
//
//  Created by tz on 8/11/21.
//

import UIKit

class NameChangeViewController: UITableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Your Display Name"
    navigationItem.largeTitleDisplayMode = .never
    view.backgroundColor = .systemGroupedBackground
  }


  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "NameChangeViewController.cellReuseID", for: indexPath)
      cell.textLabel?.text = "<name change placeholder>"
      return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    return
  }
}


