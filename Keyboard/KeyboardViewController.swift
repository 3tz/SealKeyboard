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
  let seal = Seal()

  // TODO: placeholder
  var currentLayout: KeyboardLayout! = .detailView // .typingView

  var textView: UITextView!
  var topBarView: UIStackView!
  var typingViewController: TypingViewController!
  var detailViewController: DetailViewController!
  var bottomBarView: UIStackView!

  var stageToSendText = false

  var pasteboardChangeCountTimer: Timer!

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
    createTopBarView()

    switch currentLayout {
      case .typingView:
        loadTypingViewLayout()
      case .detailView:
        loadChatViewLayout()
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

  func loadTypingViewLayout() {
    typingViewController = TypingViewController(parentController: self)
    addChild(typingViewController)
    (view as! UIStackView).addArrangedSubview(typingViewController.view)

  }

  func loadChatViewLayout() {
    detailViewController = DetailViewController(keyboardViewController: self)
    addChild(detailViewController)
    (view as! UIStackView).addArrangedSubview(detailViewController.view)
    (view as! UIStackView).sendSubviewToBack(detailViewController.view)
  }

  func createTopBarView() {
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
    NSLayoutConstraint.activate([
      layoutButton.widthAnchor.constraint(equalToConstant: KeyboardSpecs.cryptoButtonsViewHeight),
      layoutButton.heightAnchor.constraint(equalTo: layoutButton.widthAnchor)
    ])

    // Create the status / decryption text view
    textView = UITextView()
    textView.isEditable = true
    textView.isSelectable = false
    textView.text = "Ready!"
    textView.backgroundColor = .clear
    textView.translatesAutoresizingMaskIntoConstraints = false

    topBarView = UIStackView(arrangedSubviews: [layoutButton, textView])
    topBarView.axis = .horizontal
    topBarView.spacing = KeyboardSpecs.horizontalSpacing
    topBarView.backgroundColor = KeyboardSpecs.topBarViewBackgroundColor

    mainStackView.addArrangedSubview(topBarView)
  }

  // MARK: @objc #selector methods

  @objc func layoutButtonPressed(_ sender: UIButton) {
    switch currentLayout {
      case .detailView:
        detailViewController.view.removeFromSuperview()
        detailViewController.removeFromParent()
        loadTypingViewLayout()
        currentLayout = .typingView
        (topBarView.arrangedSubviews[0] as! UIButton).setImage(
          UIImage(systemName: "message.fill"), for: .normal)
      case .typingView:
        typingViewController.view.removeFromSuperview()
        typingViewController.removeFromParent()
        loadChatViewLayout()
        currentLayout = .detailView
        (topBarView.arrangedSubviews[0] as! UIButton).setImage(
          UIImage(systemName: "keyboard"), for: .normal)
      default:
        fatalError()
    }
  }

  // MARK: Sealing/unsealing/ECDH methods

  func ECDHRequestStringToMessageBox() {
    textView.text =  StatusText.ECDHInitialized // TODO: placeholder
    let message = seal.initiateECDHRequest()
    clearInputText()
    textDocumentProxy.insertText(message)
  }

  func sealAndSend() {
    sealMessageBox()
    textView.text = StatusText.sealSuccessAndSent
    // Apps with ReturnType of .send look for a single "\n" upon text change.
    // Thus, change the text to ciphertext first, and insert one "\n" under textDidChange.
    stageToSendText = true
  }

  func sealMessageBox() {
    let textInput = (textDocumentProxy.documentContextBeforeInput ?? "") +
      (textDocumentProxy.selectedText ?? "") +
      (textDocumentProxy.documentContextAfterInput ?? "")

    if textInput.isEmpty {
      textView.text = StatusText.sealFailureEmpty
      return
    }

    let message: String

    do {
      message = try seal.seal(string: textInput)
    } catch {
      NSLog("sealMessageBox error caught:\n\(error)")
      textView.text = StatusText.sealFailureSymmetricAlgo
      return
    }

    clearInputText()
    textDocumentProxy.insertText(message)
    textView.text = StatusText.sealSuccessButNotSent
  }

  func unsealCopiedText() {
    guard let copiedText = UIPasteboard.general.string else {
      textView.text = StatusText.unsealFailureEmpty // TODO: placeholder
      return
    }

    let messageType: SealMessageType, message: String?

    do {
      (messageType, message) = try seal.unseal(string: copiedText)
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
        textView.text = "\(StatusText.unsealSuccessReceivedCiphertext):\n\(message!)"
    }
  }


  // MARK: helper methods

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
      NSLog("Pasteboard counter checked")
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
