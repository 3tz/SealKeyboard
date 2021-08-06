//
//  ClearMessagesPopoverViewController.swift
//  Keyboard
//
//  Created by tz on 8/5/21.
//

import Foundation
import UIKit

class ClearMessagesPopoverViewController: UIViewController {

  unowned var controller: KeyboardViewController!
  var confirmButton: UIButton!

  convenience init(parentController: KeyboardViewController) {
    self.init()
    controller = parentController
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemRed

    confirmButton = UIButton(type: .system)
    confirmButton.translatesAutoresizingMaskIntoConstraints = false
    confirmButton.setTitle("clear all messages", for: .normal)
    confirmButton.backgroundColor = .systemRed
    confirmButton.setTitleColor(.white, for: .normal)
    confirmButton.addTarget(self, action: #selector(clearAllMessages), for: .touchUpInside)
    view.addSubview(confirmButton)
    updateViewConstraints()
  }

  override func updateViewConstraints() {
    super.updateViewConstraints()
    NSLayoutConstraint.activate([
      confirmButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      confirmButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
      confirmButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
    ])
  }

  @objc func clearAllMessages() {
    controller.detailViewController.chatViewController.deleteAllChat()
    popoverPresentationController?.presentingViewController.dismiss(animated: true, completion: nil)
  }
}
