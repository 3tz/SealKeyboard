//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by tz on 6/12/21.
//

import UIKit

class KeyboardViewController: UIInputViewController {
  
  var keyboardView: UIView!
  @IBOutlet var decryptedMsg: UILabel!
  @IBOutlet var nextKeyboardButton: UIButton!
  
  override func updateViewConstraints() {
    super.updateViewConstraints()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Use xib as view
    view = UINib(
      nibName: "KeyboardView",
      bundle: nil
    ).instantiate(withOwner: self, options: nil)[0] as? UIView
    
    // Actually make the globe button switch keyboard
    nextKeyboardButton.addTarget(
      self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
    decryptedMsg.text = ""
  }
  
  override func viewWillLayoutSubviews() {
    self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
    super.viewWillLayoutSubviews()
  }
  
  override func textWillChange(_ textInput: UITextInput?) {
    // The app is about to change the document's contents. Perform any preparation here.
  }
  
  override func textDidChange(_ textInput: UITextInput?) {
    // The app has just changed the document's contents, the document context has been updated.

    var textColor: UIColor
    let proxy = self.textDocumentProxy
    if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
      textColor = UIColor.white
    } else {
      textColor = UIColor.black
    }
    self.nextKeyboardButton.setTitleColor(textColor, for: [])
  }

  @IBAction func requestButtonPressed(_ sender: Any) {
    // TODO: finish
    var msg: String!
    msg = "req_aes|my_public_key"
    
    clearInputText()
    
    textDocumentProxy.insertText(msg)
    decryptedMsg.text = "request pressed"
  }
  
  @IBAction func decryptButtonPressed(_ sender: Any) {
    // TODO: finish
    decryptedMsg.text = "decrypt pressed"
  }
  
  @IBAction func encryptButtonPressed(_ sender: Any) {
    // TODO: finish
    decryptedMsg.text = "encrypt pressed"
  }
  
  
  /// Clear the input text field if it's not empty.
  func clearInputText() {
    if textDocumentProxy.hasText {
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
}
