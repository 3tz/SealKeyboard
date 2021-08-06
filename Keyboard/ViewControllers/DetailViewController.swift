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

      chatViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
      buttonLookup["globeButton"]!.widthAnchor.constraint(equalTo: buttonLookup["globeButton"]!.heightAnchor),
      buttonLookup["globeButton"]!.heightAnchor.constraint(equalToConstant: bottomBarButtonHeight),
      buttonLookup["clearMessagesButton"]!.heightAnchor.constraint(equalToConstant: bottomBarButtonHeight),
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

    let clearMessagesButton = UIButton(type: .system)
    clearMessagesButton.setTitle("clear", for: .normal)
    clearMessagesButton.sizeToFit()
    clearMessagesButton.backgroundColor = .systemRed
    clearMessagesButton.setTitleColor(.white, for: [])
    clearMessagesButton.translatesAutoresizingMaskIntoConstraints = false
    clearMessagesButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    clearMessagesButton.addTarget(self, action: #selector(deleteChatButtonPressed(_:)), for: .touchUpInside)

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
    buttonLookup["clearMessagesButton"] = clearMessagesButton
    buttonLookup["request"] = requestButton
    buttonLookup["seal"] = sealButton
    buttonLookup["return"] = returnButton


    // Add them to a horizontal stackview
    let spacerView1 = UIView(),
        spacerView2 = UIView()
    spacerView1.widthAnchor.constraint(equalToConstant: 0).isActive = true
    spacerView2.widthAnchor.constraint(equalToConstant: 0).isActive = true
    bottomBarView = UIStackView(
      arrangedSubviews: [spacerView1, globeButton, clearMessagesButton, requestButton, sealButton, returnButton, spacerView2]
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

extension DetailViewController: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    return .none
  }
}
