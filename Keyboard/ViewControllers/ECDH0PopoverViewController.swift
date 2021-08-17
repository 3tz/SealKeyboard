//
//  ECDH0PopoverViewController.swift
//  Keyboard
//
//  Created by tz on 8/17/21.
//

import Foundation
import UIKit

class ECDH0PopoverViewController: UIViewController {

  unowned var controller: KeyboardViewController!
  var confirmButton: UIButton!

  convenience init(parentController: KeyboardViewController) {
    self.init()
    controller = parentController
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBlue

    confirmButton = UIButton(type: .system)
    confirmButton.translatesAutoresizingMaskIntoConstraints = false
    confirmButton.setTitle("send request", for: .normal)
    confirmButton.backgroundColor = .systemBlue
    confirmButton.setTitleColor(.white, for: .normal)
    confirmButton.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)
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

  @objc func sendRequest() {
    controller.ECDHRequestStringToMessageBox()
    popoverPresentationController?.presentingViewController.dismiss(animated: true, completion: nil)
  }
}
