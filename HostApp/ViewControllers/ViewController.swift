//
//  ViewController.swift
//  Seal
//
//  Created by tz on 6/12/21.
//

import UIKit

class ViewController: UITableViewController {
  let cellReuseID =  "ViewController.cellReuseID"
  var items:[[HostAppTableViewItemizable]] = [
    [NameChange()],
    [DeleteAll()]
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Seal"
    navigationController?.navigationBar.prefersLargeTitles = true
    view.backgroundColor = .systemGroupedBackground

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseID)
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return items.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items[section].count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
//    let left = cell.contentView.subviews[0] as! UILabel
//    left.text = items[indexPath.section][indexPath.item].displayTitle
    cell.textLabel?.text = items[indexPath.section][indexPath.item].displayTitle

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    items[indexPath.section][indexPath.row].performAction(controller: self)
  }
}

