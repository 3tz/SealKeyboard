//
//  BottomBarViewController.swift
//  Keyboard
//
//  Created by tz on 7/5/21.
//

import Foundation
import UIKit
import MessageKit

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
    let bottomBarButtonHeight = KeyboardSpecs.bottomBarViewHeight - KeyboardSpecs.verticalSpacing

    NSLayoutConstraint.activate([
      bottomBarView.heightAnchor.constraint(equalToConstant:  KeyboardSpecs.bottomBarViewHeight),
      bottomBarView.widthAnchor.constraint(equalTo: view.widthAnchor),
      chatViewController.view.heightAnchor.constraint(equalToConstant: KeyboardSpecs.chatViewHeight),
      chatViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
      buttonLookup["globeButton"]!.widthAnchor.constraint(equalTo: buttonLookup["globeButton"]!.heightAnchor),
      buttonLookup["globeButton"]!.heightAnchor.constraint(equalToConstant: bottomBarButtonHeight),
      buttonLookup["deleteChatButton"]!.heightAnchor.constraint(equalToConstant: bottomBarButtonHeight),
      buttonLookup["request"]!.heightAnchor.constraint(equalToConstant: bottomBarButtonHeight),
      buttonLookup["seal"]!.heightAnchor.constraint(equalToConstant: bottomBarButtonHeight),
      buttonLookup["return"]!.heightAnchor.constraint(equalToConstant: bottomBarButtonHeight),
    ])

  }

  private func addBottomBarViewToView() {
    let globeButton = UIButton(type: .custom)
    globeButton.setImage(UIImage(systemName: "globe"), for: .normal)
    globeButton.tintColor = .white
    globeButton.backgroundColor = .systemBlue
    globeButton.translatesAutoresizingMaskIntoConstraints = false
    globeButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    globeButton.addTarget(
      controller,
      action: #selector(controller.handleInputModeList(from:with:)),
      for: .allTouchEvents
    )

    let deleteChatButton = UIButton(type: .system)
    deleteChatButton.setTitle("delete all chat", for: .normal)
    deleteChatButton.sizeToFit()
    deleteChatButton.backgroundColor = .systemRed
    deleteChatButton.setTitleColor(.white, for: [])
    deleteChatButton.translatesAutoresizingMaskIntoConstraints = false
    deleteChatButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    deleteChatButton.addTarget(self, action: #selector(deleteChatButtonPressed(_:)), for: .touchUpInside)

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

    buttonLookup["globeButton"] = globeButton
    buttonLookup["deleteChatButton"] = deleteChatButton
    buttonLookup["request"] = requestButton
    buttonLookup["seal"] = sealButton
    buttonLookup["return"] = returnButton


    // Add them to a horizontal stackview
    let spacerView1 = UIView(),
        spacerView2 = UIView()
    spacerView1.widthAnchor.constraint(equalToConstant: 0).isActive = true
    spacerView2.widthAnchor.constraint(equalToConstant: 0).isActive = true
    bottomBarView = UIStackView(
      arrangedSubviews: [spacerView1, globeButton, deleteChatButton, requestButton, sealButton, returnButton, spacerView2]
    )
    bottomBarView.axis = .horizontal
    bottomBarView.spacing = KeyboardSpecs.horizontalSpacing
    bottomBarView.distribution = .fillProportionally
    bottomBarView.alignment = .center
    bottomBarView.backgroundColor = KeyboardSpecs.bottomBarViewBackgroundColor
    (view as! UIStackView).addArrangedSubview(bottomBarView)
  }

  // MARK: Internal methods

  func appendStringMessageToChatView(_ string: String, sender: NSMessageSender) {
    chatViewController.appendStringMessage(string, sender: sender)
  }

  // MARK: @objc #selector methods

  @objc func deleteChatButtonPressed(_ sender: Any) {
    chatViewController.deleteAllChat()
  }

  @objc func requestButtonPressed(_ sender: Any) {
    controller.ECDHRequestStringToMessageBox()
  }

  @objc func unsealButtonPressed(_ sender: Any) {
    controller.unsealCopiedText()
  }

  @objc func sealButtonPressed(_ sender: Any) {
    controller.sealMessageBox()
  }

  @objc func returnButtonPressed(_ sender: Any) {
    controller.textDocumentProxy.insertText("\n") 
  }
}

