//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by tz on 6/12/21.
//

import UIKit

enum KeyboardLayout {
  case typingView
  case logView
}

class KeyboardViewController: UIInputViewController {
  let seal = Seal()

  // TODO: placeholder
  var currentLayout: KeyboardLayout! = .typingView

  var layoutButton: UIButton!
  var textView: UITextView!
  var statusStackView: UIStackView!

//  var cryptoBar: CryptoBar!
  var typingViewController: TypingViewController!

//  var cryptoBarView: UIStackView!

  var stageToSendText = false

  var pasteboardChangeCountMonitor: Timer!

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
      case .logView:
        loadLogViewLayout()
      default:
        fatalError()
    }

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    startPasteboardChangeCountMonitor()
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
//      cryptoBarView.widthAnchor.constraint(
//        equalToConstant:  UIScreen.main.bounds.size.width * 0.99),
      statusStackView.widthAnchor.constraint(equalToConstant:  UIScreen.main.bounds.size.width * 0.99),
      typingViewController.view.heightAnchor.constraint(
        equalToConstant:  KeyboardSpecs.keyboardButtonsViewHeight),
      typingViewController.view.widthAnchor.constraint(
        equalToConstant:  UIScreen.main.bounds.size.width * 0.99),
    ])

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
    layoutButton = UIButton()
    layoutButton.translatesAutoresizingMaskIntoConstraints = false
    layoutButton.setImage(UIImage(systemName: "message.fill"), for: .normal)
    layoutButton.backgroundColor = .systemBlue
    layoutButton.tintColor = .white
    layoutButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius

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

    statusStackView = UIStackView(arrangedSubviews: [layoutButton, textView])
    statusStackView.axis = .horizontal
    statusStackView.spacing = KeyboardSpecs.horizontalSpacing

    mainStackView.addArrangedSubview(statusStackView)


    typingViewController = TypingViewController(parentController: self)

    self.addChild(typingViewController)
    mainStackView.addArrangedSubview(typingViewController.view)

  }

  func loadLogViewLayout() {

  }


  // MARK: Sealing/unsealing/ECDH methods

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
      NSLog("sealMessageBox rror caught:\n\(error)")
      textView.text = "Something went wrong. Unable to encrypt. Try again later."
      return
    }

    clearInputText()
    textDocumentProxy.insertText(message)
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
    pasteboardChangeCountMonitor = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
      timer in
      if self.pasteboardChanged() { self.unsealCopiedText() }
      NSLog("Pasteboard counter checked")
    }
  }

  func stopPasteboardChangeCountMonitor() { pasteboardChangeCountMonitor?.invalidate()}

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
