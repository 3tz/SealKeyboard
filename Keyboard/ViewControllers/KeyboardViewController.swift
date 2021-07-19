//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by tz on 6/12/21.
//

import UIKit

enum KeyboardLayout {
  case typingView
  case detailView
}

class KeyboardViewController: UIInputViewController {
  // TODO: placeholder
  var currentLayout: KeyboardLayout! = .detailView // .typingView

  var textView: UITextView!

  var chatSelectionButton: UIButton!
  var topBarView: UIStackView!
  var typingViewController: TypingViewController!
  var detailViewController: DetailViewController!
  var bottomBarView: UIStackView!

  var stageToSendText = false

  var pasteboardChangeCountTimer: Timer!

  var taskRunning = false

  // MARK: view overrides

  override func loadView() {
    // Use stackview as the main view
    let mainStackView = UIStackView()

    mainStackView.axis = .vertical
    mainStackView.spacing = KeyboardSpecs.superViewSpacing
    mainStackView.alignment = .center
    mainStackView.translatesAutoresizingMaskIntoConstraints = false

    view = mainStackView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    loadTopBarView()

    switch currentLayout {
      case .typingView:
        loadTypingView()
      case .detailView:
        loadChatView()
      default:
        fatalError()
    }

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    startPasteboardChangeCountMonitor()
    pasteboardChangeCountTimer.fire()
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
  }

  override func updateViewConstraints() {
    super.updateViewConstraints()

    guard let mainStackView = view as? UIStackView else {
      fatalError()
    }
    NSLayoutConstraint.activate([
      mainStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width),
      mainStackView.heightAnchor.constraint(equalToConstant: KeyboardSpecs.superViewHeight),
      topBarView.widthAnchor.constraint(equalToConstant:  UIScreen.main.bounds.size.width),
    ])

    switch currentLayout {
      case .typingView:
        NSLayoutConstraint.activate([
          typingViewController.view.heightAnchor.constraint(
            equalToConstant:  KeyboardSpecs.keyboardButtonsViewHeight),
          typingViewController.view.widthAnchor.constraint(
            equalToConstant:  UIScreen.main.bounds.size.width),
        ])
      case .detailView:
        NSLayoutConstraint.activate([
          detailViewController.view.heightAnchor.constraint(
            equalToConstant:  KeyboardSpecs.keyboardButtonsViewHeight),
          detailViewController.view.widthAnchor.constraint(
            equalToConstant:  UIScreen.main.bounds.size.width),
        ])
      default:
        fatalError()
    }

  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopPasteboardChangeCountMonitor()
  }

  // MARK: UI Input overrides

  override func textDidChange(_ textInput: UITextInput?) {
    super.textDidChange(textInput)

    if stageToSendText == true {
      textDocumentProxy.insertText("\n")
      stageToSendText = false
    }

  }

  // MARK: view loading methods

  func loadTypingView() {
    typingViewController = TypingViewController(parentController: self)
    addChild(typingViewController)
    (view as! UIStackView).addArrangedSubview(typingViewController.view)

  }

  func loadChatView() {
    detailViewController = DetailViewController(keyboardViewController: self)
    addChild(detailViewController)
    (view as! UIStackView).addArrangedSubview(detailViewController.view)
    (view as! UIStackView).sendSubviewToBack(detailViewController.view)
  }

  func loadTopBarView() {
    let mainStackView = view as! UIStackView

    // create the layout switch button
    let layoutButton = UIButton()
    layoutButton.translatesAutoresizingMaskIntoConstraints = false
    let imageSystemName = currentLayout == .typingView ? "message.fill" : "keyboard"
    layoutButton.setImage(UIImage(systemName: imageSystemName), for: .normal)
    layoutButton.backgroundColor = .systemBlue
    layoutButton.tintColor = .white
    layoutButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    layoutButton.addTarget(self, action: #selector(layoutButtonPressed(_:)), for: .touchUpInside)

    // Create the status / decryption text view
    textView = UITextView()
    textView.isEditable = true
    textView.isSelectable = false
    textView.text = "Ready!"
    textView.backgroundColor = .clear
    textView.translatesAutoresizingMaskIntoConstraints = false

    // create chat selection button w/ a drop down list
    chatSelectionButton = UIButton()
    // TODO: placeholder
    chatSelectionButton.setTitle("▼ chat 1", for: .normal)
    chatSelectionButton.addTarget(
      self, action: #selector(chatSelectionButtonPressed), for: .touchUpInside)

    // add above views to a hori stackview
    topBarView = UIStackView(arrangedSubviews: [layoutButton, textView, chatSelectionButton])
    topBarView.axis = .horizontal
    topBarView.spacing = KeyboardSpecs.horizontalSpacing
    topBarView.backgroundColor = KeyboardSpecs.topBarViewBackgroundColor

    NSLayoutConstraint.activate([
      layoutButton.widthAnchor.constraint(equalToConstant: KeyboardSpecs.cryptoButtonsViewHeight),
      layoutButton.heightAnchor.constraint(equalTo: layoutButton.widthAnchor),
      chatSelectionButton.heightAnchor.constraint(equalTo: topBarView.heightAnchor),
      chatSelectionButton.widthAnchor.constraint(equalToConstant: KeyboardSpecs.cryptoButtonsViewHeight * 2),
    ])

    mainStackView.addArrangedSubview(topBarView)
  }

  // MARK: @objc #selector methods

  @objc func layoutButtonPressed(_ sender: UIButton) {
    switch currentLayout {
      case .detailView:
        detailViewController.view.removeFromSuperview()
        detailViewController.removeFromParent()
        loadTypingView()
        currentLayout = .typingView
        (topBarView.arrangedSubviews[0] as! UIButton).setImage(
          UIImage(systemName: "message.fill"), for: .normal)
      case .typingView:
        typingViewController.view.removeFromSuperview()
        typingViewController.removeFromParent()
        loadChatView()
        currentLayout = .detailView
        (topBarView.arrangedSubviews[0] as! UIButton).setImage(
          UIImage(systemName: "keyboard"), for: .normal)
      default:
        fatalError()
    }
  }

  @objc func chatSelectionButtonPressed(_ sender: UIButton) {
    let popover = ChatSelectionPopoverViewController()

    popover.modalPresentationStyle = .popover
    popover.preferredContentSize = CGSize(width: KeyboardSpecs.cryptoButtonsViewHeight * 2, height: KeyboardSpecs.cryptoButtonsViewHeight * 3)
    let popoverController = popover.popoverPresentationController
    popoverController?.delegate = self
    popoverController?.sourceView = sender
    popoverController?.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.midY, width: 0, height: 0)
    popoverController?.permittedArrowDirections = .up
    present(popover, animated: true, completion: nil)
  }

  // MARK: Sealing/unsealing/ECDH methods

  func ECDHRequestStringToMessageBox() {
    textView.text =  StatusText.ECDHInitialized // TODO: placeholder
    let message = Seal.initiateECDHRequest()
    clearInputText()
    textDocumentProxy.insertText(message)
  }

  func sealMessageBox(andSend: Bool = false) {
    if !taskRunning {
      taskRunning = true
      DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        guard let self = self else { return }

        let textInput = self.getFullDocumentContextString()

        DispatchQueue.main.sync { [weak self] in
          guard let self = self else { return }

          // Delete all text
          for _ in 0..<textInput.count {
            self.textDocumentProxy.deleteBackward()
          }

          if textInput.isEmpty {
            self.textView.text = StatusText.sealFailureEmpty
            return
          }

          let message: String

          do {
            message = try Seal.seal(string: textInput)
          } catch {
            NSLog("sealMessageBox error caught:\n\(error)")
            self.textView.text = StatusText.sealFailureSymmetricAlgo
            return
          }

          self.textDocumentProxy.insertText(message)
          self.textView.text = StatusText.sealSuccessButNotSent

          self.detailViewController.appendStringMessageToChatView(textInput, sender: ChatView.senderMe)
          if andSend {
            self.textView.text = StatusText.sealSuccessAndSent
            // Apps with ReturnType of .send look for a single "\n" upon text change.
            // Thus, change the text to ciphertext first, and insert one "\n" under textDidChange.
            self.stageToSendText = true
          }
          self.taskRunning = false
        } // DispatchQueue.main.sync
      }
    }
  }

  func unsealCopiedText() {
    guard let copiedText = UIPasteboard.general.string else {
      textView.text = StatusText.unsealFailureEmpty // TODO: placeholder
      return
    }

    let messageType: SealMessageType, message: String?

    do {
      (messageType, message) = try Seal.unseal(string: copiedText)
    } catch DecryptionErrors.parsingError {
      textView.text = StatusText.unsealFailureParsingError
      return
    } catch DecryptionErrors.authenticationError {
      textView.text = StatusText.unsealFailureAuthenticationError
      return
    } catch {
      textView.text = StatusText.unsealFailureOtherError
      return
    }

    switch messageType {
      case .ECDH0:
        clearInputText()
        textDocumentProxy.insertText(message!)
        // TODO: placeholder
        textView.text = StatusText.unsealSuccessReceivedECDH0
      case .ECDH1:
        textView.text = StatusText.unsealSuccessReceivedECDH1
      case .ciphertext:
        let statusText: String!
        switch currentLayout {
          case .detailView:
            statusText = "\(StatusText.unsealSuccessReceivedCiphertext). See below."
            detailViewController.appendStringMessageToChatView(
              message!,
              sender: NSMessageSender(senderId: "placeholder", displayName: "placeholder"))
          case .typingView:
             statusText = "\(StatusText.unsealSuccessReceivedCiphertext):\n\(message!)"
          default:
            fatalError()
        }
        textView.text = statusText
    }
  }


  // MARK: helper methods

  /// Modified from: https://stackoverflow.com/a/37956477/10693217
  /// Must be run on a non-main thread due to the nature of it checking while UI updating
  func getFullDocumentContextString() -> String {
    var totalOffset = 0,
        fullString = ""
    let sleepTimeInterval = 0.05

      // Move cursor to the end of the text
      // Note: For some reason, newlines cannot be parsed from contextAfterInput, which is
      //   why it only moves to the end instead of reading along the way.
      while let context = textDocumentProxy.documentContextAfterInput{
        textDocumentProxy.adjustTextPosition(byCharacterOffset: max(context.count, 1))
        Thread.sleep(forTimeInterval: sleepTimeInterval)
      }

      // Keep moving cursor backward until it's at the beginning & reading along the way
      while let context = textDocumentProxy.documentContextBeforeInput, !context.isEmpty {
        fullString = context + fullString
        textDocumentProxy.adjustTextPosition(byCharacterOffset: -context.count)
        totalOffset += context.count
        Thread.sleep(forTimeInterval: sleepTimeInterval)
      }

      // Teleport cursor to the end
      textDocumentProxy.adjustTextPosition(byCharacterOffset: totalOffset)
      Thread.sleep(forTimeInterval: sleepTimeInterval)

    return fullString
  }

  /// Clear the input text field if it's not empty.
  func clearInputText() {
    if !textDocumentProxy.hasText { return }

    let textBeforeInput = textDocumentProxy.documentContextBeforeInput ?? ""
    let textAfterInput = textDocumentProxy.documentContextAfterInput ?? ""
    let selectedText = textDocumentProxy.selectedText ?? ""

    // move cursor to the end of the text input
    textDocumentProxy.adjustTextPosition(byCharacterOffset: textAfterInput.count)

    // delete backward n times where n is the length of the text
    for _ in 0..<textAfterInput.count + textBeforeInput.count + selectedText.count {
      textDocumentProxy.deleteBackward()
    }
  }

  /// Check if pasteboard has changed every 1 second, and unseal if it has.
  func startPasteboardChangeCountMonitor() {
    pasteboardChangeCountTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
      timer in
      if self.pasteboardChanged() { self.unsealCopiedText() }
//      NSLog("Pasteboard counter checked")
    }
  }

  func stopPasteboardChangeCountMonitor() { pasteboardChangeCountTimer?.invalidate()}

  func pasteboardChanged() -> Bool {
    let oldChangeCount = UserDefaults.standard.integer(
      forKey: DefaultKeys.previousPasteboardChangeCount.rawValue)
    let currentChangeCount = UIPasteboard.general.changeCount
    UserDefaults.standard.setValue(
      currentChangeCount, forKey: DefaultKeys.previousPasteboardChangeCount.rawValue)
    if oldChangeCount == currentChangeCount { return false }

    return true
  }
}

extension KeyboardViewController: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
}
