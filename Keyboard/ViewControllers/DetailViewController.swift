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

  var globeButton: UIButton!
  var clearMessagesButton: UIButton!
  var requestButton: UIButton!
  var sealButton: UIButton!

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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let returnType = controller.textDocumentProxy.returnKeyType ?? .default
    if returnType == .send {
        sealButton.setTitle("seal & send", for: .normal)
    }
  }

  override func updateViewConstraints() {
    super.updateViewConstraints()
    let bottomBarButtonHeight = KeyboardSpecs.bottomBarViewHeight - KeyboardSpecs.verticalSpacing

    NSLayoutConstraint.activate([
      bottomBarView.heightAnchor.constraint(equalToConstant:  KeyboardSpecs.bottomBarViewHeight),
      bottomBarView.widthAnchor.constraint(equalTo: view.widthAnchor),

      chatViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
      globeButton.widthAnchor.constraint(equalTo: globeButton.heightAnchor),
      globeButton.heightAnchor.constraint(equalToConstant: bottomBarButtonHeight),
      clearMessagesButton.heightAnchor.constraint(equalToConstant: bottomBarButtonHeight),
      requestButton.heightAnchor.constraint(equalToConstant: bottomBarButtonHeight),
      sealButton.heightAnchor.constraint(equalToConstant: bottomBarButtonHeight),
    ])

    // Update switch key color
    let darkMode = traitCollection.userInterfaceStyle == .dark
    let backgroundColor = darkMode ? KeyboardSpecs.specialBackgroundDark : KeyboardSpecs.specialBackgroundLight
    let tintColor = darkMode ? KeyboardSpecs.specialTitleDark : KeyboardSpecs.specialTitleLight

    globeButton.backgroundColor = backgroundColor
    globeButton.tintColor = tintColor
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    // Update switch key color
    let darkMode = traitCollection.userInterfaceStyle == .dark
    let backgroundColor = darkMode ? KeyboardSpecs.specialBackgroundDark : KeyboardSpecs.specialBackgroundLight
    let tintColor = darkMode ? KeyboardSpecs.specialTitleDark : KeyboardSpecs.specialTitleLight

    globeButton.backgroundColor = backgroundColor
    globeButton.tintColor = tintColor
  }

  private func addBottomBarViewToView() {
    globeButton = UIButton(type: .custom)
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

    clearMessagesButton = UIButton(type: .system)
    clearMessagesButton.setTitle("clear", for: .normal)
    clearMessagesButton.sizeToFit()
    clearMessagesButton.backgroundColor = .systemRed
    clearMessagesButton.setTitleColor(.white, for: [])
    clearMessagesButton.translatesAutoresizingMaskIntoConstraints = false
    clearMessagesButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    clearMessagesButton.addTarget(self, action: #selector(deleteChatButtonPressed(_:)), for: .touchUpInside)

    requestButton = UIButton(type: .system)
    requestButton.setTitle("request", for: .normal)
    requestButton.sizeToFit()
    requestButton.backgroundColor = .systemBlue
    requestButton.setTitleColor(.white, for: [])
    requestButton.translatesAutoresizingMaskIntoConstraints = false
    requestButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    requestButton.addTarget(self, action: #selector(requestButtonPressed(_:)), for: .touchUpInside)

    sealButton = UIButton(type: .system)
    sealButton.setTitle("seal", for: .normal)
    sealButton.sizeToFit()
    sealButton.backgroundColor = .systemBlue
    sealButton.setTitleColor(.white, for: [])
    sealButton.translatesAutoresizingMaskIntoConstraints = false
    sealButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    sealButton.addTarget(self, action: #selector(sealButtonPressed(_:)), for: .touchUpInside)

    // Add them to a horizontal stackview
    let spacerView1 = UIView(),
        spacerView2 = UIView()
    spacerView1.widthAnchor.constraint(equalToConstant: 0).isActive = true
    spacerView2.widthAnchor.constraint(equalToConstant: 0).isActive = true
    bottomBarView = UIStackView(
      arrangedSubviews: [spacerView1, globeButton, clearMessagesButton, requestButton, sealButton, spacerView2]
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

  @objc func deleteChatButtonPressed(_ sender: UIButton) {
    let popover = ClearMessagesPopoverViewController(parentController: controller)
    popover.modalPresentationStyle = .popover
    popover.preferredContentSize = CGSize(width: KeyboardSpecs.cryptoButtonsViewHeight * 3, height: KeyboardSpecs.cryptoButtonsViewHeight * 0.75)
    let popoverController = popover.popoverPresentationController
    popoverController?.delegate = self
    popoverController?.sourceView = sender
    popoverController?.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.midY - 15, width: 0, height: 0)

    popoverController?.permittedArrowDirections = .down
    present(popover, animated: true, completion: nil)
  }

  @objc func requestButtonPressed(_ sender: UIButton) {
    let popover = ECDH0PopoverViewController(parentController: controller)
    popover.modalPresentationStyle = .popover
    popover.preferredContentSize = CGSize(width: KeyboardSpecs.cryptoButtonsViewHeight * 3, height: KeyboardSpecs.cryptoButtonsViewHeight * 0.75)
    let popoverController = popover.popoverPresentationController
    popoverController?.delegate = self
    popoverController?.sourceView = sender
    popoverController?.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.midY - 15, width: 0, height: 0)

    popoverController?.permittedArrowDirections = .down
    present(popover, animated: true, completion: nil)
  }

  @objc func unsealButtonPressed(_ sender: Any) {
    controller.unsealCopiedText()
  }

  @objc func sealButtonPressed(_ sender: Any) {
    // if .send, it's "Seal & Send" button; otherwise, it's just "Seal"
    let returnKeyType = controller.textDocumentProxy.returnKeyType ?? .default
    switch returnKeyType {
      case .send:
        if !controller.textDocumentProxy.hasText { break }
        controller.sealMessageBox(andSend: true)
      default:
        controller.sealMessageBox()
    }
  }

}

extension DetailViewController: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    return .none
  }
}
