//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by tz on 6/12/21.
//

import UIKit

enum KeyboardLayout {
  case typingView
  case chatView
}

class KeyboardViewController: UIInputViewController {
  let seal = Seal()

  // TODO: placeholder
  var currentLayout: KeyboardLayout! = .chatView // .typingView

  var textView: UITextView!
  var barStackView: UIStackView!
  var typingViewController: TypingViewController!
  var chatViewController: ChatViewController!
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

    switch currentLayout {
      case .typingView:
        loadTypingViewLayout()
      case .chatView:
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

    switch currentLayout {
      case .typingView:
        NSLayoutConstraint.activate([
          mainStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width),
          mainStackView.heightAnchor.constraint(equalToConstant: KeyboardSpecs.superViewHeight),
    //      cryptoBarView.widthAnchor.constraint(
    //        equalToConstant:  UIScreen.main.bounds.size.width * 0.99),
          barStackView.widthAnchor.constraint(equalToConstant:  UIScreen.main.bounds.size.width * 0.99),
          typingViewController.view.heightAnchor.constraint(
            equalToConstant:  KeyboardSpecs.keyboardButtonsViewHeight),
          typingViewController.view.widthAnchor.constraint(
            equalToConstant:  UIScreen.main.bounds.size.width * 0.99),
        ])
      case .chatView:
        NSLayoutConstraint.activate([
          mainStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width),
          mainStackView.heightAnchor.constraint(equalToConstant: KeyboardSpecs.superViewHeight),
          chatViewController.view.widthAnchor.constraint(
            equalToConstant:  UIScreen.main.bounds.size.width * 0.99),
          barStackView.widthAnchor.constraint(equalToConstant:  UIScreen.main.bounds.size.width * 0.99),
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
    let mainStackView = view as! UIStackView

    // create the layout switch button
    let layoutButton = UIButton()
    layoutButton.translatesAutoresizingMaskIntoConstraints = false
    layoutButton.setImage(UIImage(systemName: "message.fill"), for: .normal)
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

    barStackView = UIStackView(arrangedSubviews: [layoutButton, textView])
    barStackView.axis = .horizontal
    barStackView.spacing = KeyboardSpecs.horizontalSpacing

    mainStackView.addArrangedSubview(barStackView)


    typingViewController = TypingViewController(parentController: self)

    self.addChild(typingViewController)
    mainStackView.addArrangedSubview(typingViewController.view)

  }

  func loadChatViewLayout() {
    let mainStackView = view as! UIStackView

    // create the layout switch button
    let layoutButton = UIButton()
    layoutButton.translatesAutoresizingMaskIntoConstraints = false
    layoutButton.setImage(UIImage(systemName: "keyboard"), for: .normal)
    layoutButton.backgroundColor = .systemBlue
    layoutButton.tintColor = .white
    layoutButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    layoutButton.addTarget(self, action: #selector(layoutButtonPressed(_:)), for: .touchUpInside)
    NSLayoutConstraint.activate([
      layoutButton.widthAnchor.constraint(equalToConstant: KeyboardSpecs.cryptoButtonsViewHeight),
      layoutButton.heightAnchor.constraint(equalTo: layoutButton.widthAnchor)
    ])

    // create the two button cryptobar
    let requestButton = UIButton(type: .system)
    requestButton.setTitle("Request", for: .normal)
    requestButton.sizeToFit()
    requestButton.backgroundColor = .systemBlue
    requestButton.setTitleColor(.white, for: [])
    requestButton.translatesAutoresizingMaskIntoConstraints = false
    requestButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    requestButton.addTarget(
      self,
      action: #selector(requestButtonPressed(_:)),
      for: .touchUpInside
    )

    let sealButton = UIButton(type: .system)
    sealButton.setTitle("Seal Message Field Text", for: .normal)
    sealButton.sizeToFit()
    sealButton.backgroundColor = .systemBlue
    sealButton.setTitleColor(.white, for: [])
    sealButton.translatesAutoresizingMaskIntoConstraints = false
    sealButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    sealButton.addTarget(
      self,
      action: #selector(sealButtonPressed(_:)),
      for: .touchUpInside
    )

    // Add them to a horizontal stackview
    barStackView = UIStackView(
      arrangedSubviews: [layoutButton, requestButton, sealButton]
    )
    barStackView.axis = .horizontal
    barStackView.spacing = KeyboardSpecs.horizontalSpacing
    mainStackView.addArrangedSubview(barStackView)

    // Create the status / decryption text view
    textView = UITextView()
    textView.isEditable = false
    textView.isSelectable = true
    textView.text = "Ready!"
    textView.backgroundColor = .clear
    textView.translatesAutoresizingMaskIntoConstraints = false

    chatViewController = ChatViewController()
    self.addChild(chatViewController)
    mainStackView.addArrangedSubview(chatViewController.view)

  }

  // MARK: @objc #selector methods

  @objc func layoutButtonPressed(_ sender: UIButton) {
    switch currentLayout {
      case .chatView:
        barStackView.removeFromSuperview()
        chatViewController.view.removeFromSuperview()
        chatViewController.removeFromParent()
        loadTypingViewLayout()
        currentLayout = .typingView
      case .typingView:
        barStackView.removeFromSuperview()
        typingViewController.view.removeFromSuperview()
        typingViewController.removeFromParent()
        loadChatViewLayout()
        currentLayout = .chatView
      default:
        fatalError()
    }
  }

  @objc func requestButtonPressed(_ sender: Any) { ECDHRequestStringToMessageBox() }

  @objc func unsealButtonPressed(_ sender: Any) { unsealCopiedText() }

  @objc func sealButtonPressed(_ sender: Any) { sealMessageBox() }


  // MARK: Sealing/unsealing/ECDH methods

  func ECDHRequestStringToMessageBox() {
    textView.text = "ECDH initiated." // TODO: placeholder
    let message = seal.initiateECDHRequest()
    clearInputText()
    textDocumentProxy.insertText(message)
  }

  func sealAndSend() {
    sealMessageBox()
    textView.text = "Text encrypted and sent."
    // Apps with ReturnType of .send look for a single "\n" upon text change.
    // Thus, change the text to ciphertext first, and insert one "\n" under textDidChange.
    stageToSendText = true
  }

  func sealMessageBox() {
    let textInput = (textDocumentProxy.documentContextBeforeInput ?? "") +
      (textDocumentProxy.selectedText ?? "") +
      (textDocumentProxy.documentContextAfterInput ?? "")

    if textInput.isEmpty {
      textView.text = "Unable to seal message because input text field is empty."
      return
    }

    let message: String

    do {
      message = try seal.seal(string: textInput)
    } catch {
      NSLog("sealMessageBox error caught:\n\(error)")
      textView.text = "Something went wrong. Unable to encrypt. Try again later."
      return
    }

    clearInputText()
    textDocumentProxy.insertText(message)
    textView.text = "Textfield sealed. Ready to send."
  }

  func unsealCopiedText() {
    guard let copiedText = UIPasteboard.general.string else {
      textView.text = "No copied text found." // TODO: placeholder
      return
    }

    let messageType: MessageType, message: String?

    do {
      (messageType, message) = try seal.unseal(string: copiedText)
    } catch DecryptionErrors.parsingError {
      textView.text = "Unknown type of message copied."
      return
    } catch DecryptionErrors.authenticationError {
      textView.text = "Message signature verification failed."
      return
    } catch {
      textView.text = "Unable to unseal. Unknown key or others."
      return
    }

    switch messageType {
      case .ECDH0:
        clearInputText()
        textDocumentProxy.insertText(message!)
        // TODO: placeholder
        textView.text = "Request to generate symmetric key received."
      case .ECDH1:
        textView.text = "Symmetric key generated"
      case .ciphertext:
        textView.text = "Decrypted Message:\n\(message!)"
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
