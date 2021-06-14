//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by tz on 6/12/21.
//

import UIKit
import CryptoSwift

class KeyboardViewController: UIInputViewController {
  
  var keyboardView: UIView!
  @IBOutlet var decryptedMsg: UILabel!
  @IBOutlet var nextKeyboardButton: UIButton!

  var aes = "aes_key" // TODO: eventually should be an actual aes key
  
  override func updateViewConstraints() {
    super.updateViewConstraints()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // TODO: eventually, key pairs should be read from Seal instead of generating every time
    generateRSAPairs()
    
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
    decryptedMsg.text = "request pressed"

    let msg = "req_aes|rsa_pk"

    clearInputText()
    
    textDocumentProxy.insertText(msg)
    
  }
  
  @IBAction func decryptButtonPressed(_ sender: Any) throws {
    // TODO: finish
    guard let copiedText = UIPasteboard.general.string else {
      decryptedMsg.text = "No copied text found."
      return
    }
    
    let tokens = copiedText.components(separatedBy: "|")
  
    switch tokens[0]{
    case "req_aes":
      // Request to generate AES key.
      // Expected format: "req_aes|{sender's RSA public key}"
      if tokens.count != 2 {
        fallthrough
      }

    case "enc_aes":
      break
    case "ciphertext":
      break
    default:
      decryptedMsg.text = "Unknown type of message copied."
      break
    }
    
    
    
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
  
  func generateRSAPairs() {
    // TODO: currently stores as class attributes. Might need to change later
  }
  
  func generateAES() {
//    SecKeyAlgorithm.rsaEncryptionOAEPSHA512AESGCM
    
//    SecKeyCreateEncryptedData(
  }
  
}
