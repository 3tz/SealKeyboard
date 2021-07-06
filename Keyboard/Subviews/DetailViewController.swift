//
//  BottomBarViewController.swift
//  Keyboard
//
//  Created by tz on 7/5/21.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
  var controller: KeyboardViewController!
  var chatViewController: ChatViewController!
  var bottomBarView: UIStackView!

  var buttonLookup: [String: UIButton] = [:]

  convenience init(keyboardViewController: KeyboardViewController) {
    self.init()
    controller = keyboardViewController
  }

  override func loadView() {
    let mainStackView = UIStackView()

    mainStackView.axis = .vertical
    mainStackView.spacing = 0
    mainStackView.alignment = .center
    mainStackView.translatesAutoresizingMaskIntoConstraints = false

    view = mainStackView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    chatViewController = ChatViewController(keyboardViewController: controller)
    (view as! UIStackView).addArrangedSubview(chatViewController.view)
    addChild(chatViewController)
    addBottomBarViewToView()
    view.sendSubviewToBack(chatViewController.view)
  }

  override func updateViewConstraints() {
    super.updateViewConstraints()
    NSLayoutConstraint.activate([
      bottomBarView.heightAnchor.constraint(
        equalToConstant:  KeyboardSpecs.bottomBarViewHeight),
      chatViewController.view.heightAnchor.constraint(equalToConstant: KeyboardSpecs.chatViewHeight),
      bottomBarView.widthAnchor.constraint(equalTo: view.widthAnchor),
      chatViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),

    ])

  }

  private func addBottomBarViewToView() {
    let globeButton = UIButton(type: .custom)
    globeButton.translatesAutoresizingMaskIntoConstraints = false
    globeButton.setImage(UIImage(systemName: "globe"), for: .normal)
    globeButton.tintColor = .white
    globeButton.backgroundColor = .systemBlue
    globeButton.addTarget(
      controller,
      action: #selector(controller.handleInputModeList(from:with:)),
      for: .allTouchEvents
    )
    globeButton.widthAnchor.constraint(equalTo: globeButton.heightAnchor).isActive = true

    // create the two button cryptobar
    let requestButton = UIButton(type: .system)
    requestButton.setTitle("Request", for: .normal)
    requestButton.sizeToFit()
    requestButton.backgroundColor = .systemBlue
    requestButton.setTitleColor(.white, for: [])
    requestButton.translatesAutoresizingMaskIntoConstraints = false
    requestButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    requestButton.addTarget(self, action: #selector(requestButtonPressed(_:)), for: .touchUpInside)

    let sealButton = UIButton(type: .system)
    sealButton.setTitle("Seal", for: .normal)
    sealButton.sizeToFit()
    sealButton.backgroundColor = .systemBlue
    sealButton.setTitleColor(.white, for: [])
    sealButton.translatesAutoresizingMaskIntoConstraints = false
    sealButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    sealButton.addTarget(self, action: #selector(sealButtonPressed(_:)), for: .touchUpInside)

    let returnButton = UIButton(type: .system)
    returnButton.setTitle("return", for: .normal)
    returnButton.sizeToFit()
    returnButton.backgroundColor = .systemBlue
    returnButton.setTitleColor(.white, for: [])
    returnButton.translatesAutoresizingMaskIntoConstraints = false
    returnButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    returnButton.addTarget(self, action: #selector(returnButtonPressed(_:)), for: .touchUpInside)

    buttonLookup["request"] = requestButton
    buttonLookup["seal"] = sealButton
    buttonLookup["return"] = returnButton


    // Add them to a horizontal stackview
    bottomBarView = UIStackView(
      arrangedSubviews: [globeButton, requestButton, sealButton, returnButton]
    )
    bottomBarView.axis = .horizontal
    bottomBarView.spacing = KeyboardSpecs.horizontalSpacing
    bottomBarView.backgroundColor = KeyboardSpecs.bottomBarViewBackgroundColor
    (view as! UIStackView).addArrangedSubview(bottomBarView)
  }

  // MARK: Internal methods

  func appendStringMessageToChatView(_ string: String, sender: Sender) {
    chatViewController.appendStringMessage(string, sender: sender)
  }

  // MARK: @objc #selector methods

  @objc func requestButtonPressed(_ sender: Any) { controller.ECDHRequestStringToMessageBox() }

  @objc func unsealButtonPressed(_ sender: Any) { controller.unsealCopiedText() }

  @objc func sealButtonPressed(_ sender: Any) { controller.sealMessageBox() }

  @objc func returnButtonPressed(_ sender: Any) { controller.textDocumentProxy.insertText("\n") }
}

