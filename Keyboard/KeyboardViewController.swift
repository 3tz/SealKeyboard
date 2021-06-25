//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by tz on 6/12/21.
//

import UIKit

class KeyboardViewController: UIInputViewController {
  
  var keyboardView: UIView!
  @IBOutlet var textBox: UILabel!

  var cryptoBar: CryptoBar!
  var keyboard: Keyboard!

  
  var spacerView: UIView = UIView()

  var cryptoBarView: UIStackView!
  var keyboardButtonsView: UIStackView!

  var darkMode: Bool!

  // Encryption and Signing Keys
  var keys: Keys!

  override func loadView() {
    // Use stackview as the main view
    let mainStackView = UIStackView()

    mainStackView.axis = .vertical
    mainStackView.spacing = KeyboardSpecs.superViewSpacing
    mainStackView.alignment = .center
    mainStackView.translatesAutoresizingMaskIntoConstraints = false

    view = mainStackView
  }

  override func updateViewConstraints() {
    super.updateViewConstraints()

    guard let mainStackView = view as? UIStackView else {
      fatalError()
    }

    NSLayoutConstraint.activate([
      mainStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width),
      mainStackView.heightAnchor.constraint(equalToConstant: KeyboardSpecs.superViewHeight),
      spacerView.heightAnchor.constraint(equalToConstant:  0),
      cryptoBarView.widthAnchor.constraint(
        equalToConstant:  UIScreen.main.bounds.size.width * 0.98),
      keyboardButtonsView.heightAnchor.constraint(
        equalToConstant:  KeyboardSpecs.keyboardButtonsViewHeight),
      keyboardButtonsView.widthAnchor.constraint(
        equalToConstant:  UIScreen.main.bounds.size.width * 0.98),
    ])

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }


  override func viewDidLoad() {
    super.viewDidLoad()
    let mainStackView = view as! UIStackView
    // Determine dark mode
    darkMode = textDocumentProxy.keyboardAppearance == UIKeyboardAppearance.dark
    keys = Keys()
    // Add a spacer on top
    mainStackView.addArrangedSubview(spacerView)
    // Initialize crypto buttons and keyboard buttons views
    cryptoBar = CryptoBar(controller: self)
    cryptoBarView = cryptoBar.getView()
    mainStackView.addArrangedSubview(cryptoBarView)

    keyboard = Keyboard(controller: self, darkMode: darkMode)
    keyboardButtonsView = keyboard.getButtonsView()
    mainStackView.addArrangedSubview(keyboardButtonsView)

  }

  override func viewWillLayoutSubviews() {
//    self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
    super.viewWillLayoutSubviews()
  }
  
  override func textDidChange(_ textInput: UITextInput?) {
    super.textDidChange(textInput)
    keyboard.updateColors(
      darkModeOn: textDocumentProxy.keyboardAppearance == UIKeyboardAppearance.dark
    )
    keyboard.updateReturnKeyType()
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

  
}
