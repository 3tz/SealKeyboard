//
//  ViewController.swift
//  Seal
//
//  Created by tz on 6/12/21.
//

import UIKit

class ViewController: UITableViewController {
  let cellReuseID =  "ViewController.cellReuseID"
  var items:[[HostAppTableViewItemizable]]!

  func reloadData() {
    items = [
      [NameChange(controller: self)],
      [DeleteAll()]
    ]
    tableView.reloadData()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Seal"
    navigationController?.navigationBar.prefersLargeTitles = true
    view.backgroundColor = .systemGroupedBackground
    tableView.register(HostAppCustomCell.self, forCellReuseIdentifier: cellReuseID)
    tableView.rowHeight = 40

    reloadData()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reloadData()
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return items.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items[section].count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as! HostAppCustomCell
    let selectedItem = items[indexPath.section][indexPath.item]
    cell.leftLabel.text = selectedItem.leftLabelText
    cell.rightLabel.text = selectedItem.rightLabelText
    cell.accessoryType = selectedItem.accessoryType
    cell.leftLabel.textColor = selectedItem.leftLabelTextColor

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    items[indexPath.section][indexPath.row].performAction(controller: self)
  }
}

