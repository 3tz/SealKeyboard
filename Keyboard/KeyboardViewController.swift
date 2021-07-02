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
  
  var keyboardView: UIView!
  @IBOutlet var textBox: UILabel!

  // TODO: placeholder
  var currentLayout: KeyboardLayout! = .typingView

  var layoutButton: UIButton!
  var textView: UITextView!
  var statusStackView: UIStackView!

  var cryptoBar: CryptoBar!
  var typingViewController: TypingViewController!

  var cryptoBarView: UIStackView!

  var stageToSendText = false

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
    cryptoBar.stopPasteboardChangeCountMonitor()
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
    cryptoBar = CryptoBar(controller: self)
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



}
