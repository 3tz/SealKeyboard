//
//  ViewController.swift
//  Seal
//
//  Created by tz on 6/12/21.
//

import UIKit

class ViewController: UITableViewController {
  var items:[String] = ["Your Display Name", "Delete All Chats & Messages"]

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Seal"
    navigationController?.navigationBar.prefersLargeTitles = true

    view.backgroundColor = .systemGroupedBackground
  }


  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ViewController.cellReuseID", for: indexPath)
      cell.textLabel?.text = items[indexPath.row]
      return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch items[indexPath.row] {
      case "Your Display Name":
        let vc = storyboard?.instantiateViewController(withIdentifier: "NameChangeViewController") as! UITableViewController
          navigationController?.pushViewController(vc, animated: true)
      default:
        return
    }

  }
}

