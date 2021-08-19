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
    confirmButton.backgroundColor = .systemBlue
    confirmButton.setTitleColor(.white, for: .normal)
    // if .send, send the ECDH0 text upon press; otherwise, just paste it in textbox
    let returnKeyType = controller.textDocumentProxy.returnKeyType ?? .default
    switch returnKeyType {
      case .send:
        confirmButton.setTitle("send handshake request", for: .normal)
        confirmButton.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)
      default:
        confirmButton.setTitle("create handshake request", for: .normal)
        confirmButton.addTarget(self, action: #selector(pasteToTextBox), for: .touchUpInside)
    }



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
    controller.ECDHRequestStringToMessageBox(andSend: true)
    popoverPresentationController?.presentingViewController.dismiss(animated: true) { [unowned controller] in
      controller?.textDidChange(nil)
    }
  }

  @objc func pasteToTextBox() {
    controller.ECDHRequestStringToMessageBox()
    popoverPresentationController?.presentingViewController.dismiss(animated: true)
  }
}
