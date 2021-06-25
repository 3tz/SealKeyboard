//
//  CryptoButtons.swift
//  Keyboard
//
//  Created by tz on 6/22/21.
//

import Foundation
import UIKit

class CryptoBar {
  var controller: KeyboardViewController!

  var mainStackView: UIStackView!

  var textView: UITextView!
  var buttonsView: UIStackView!

  var keys: Keys!

  init (controller: KeyboardViewController) {
    self.controller = controller
    self.keys = Keys()

    mainStackView = getView()
    textView.text = ""
  }

  func getView() -> UIStackView {
    if mainStackView != nil { return mainStackView }

    createTextView()
    createButtonsView()

    mainStackView = UIStackView(arrangedSubviews: [textView, buttonsView])
    mainStackView.axis = .vertical
    mainStackView.spacing = KeyboardSpecs.horizontalSpacing
//    mainStackView.distribution = .fillProportionally

    return mainStackView
  }

  func createTextView() {
    textView = UITextView()
    textView.isEditable = false
    textView.isSelectable = false
    textView.text = """
      line 1
      line 2
      line 3
      line 4
      """
  }

  func createButtonsView() {
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

    let unsealButton = UIButton(type: .system)
    unsealButton.setTitle("Unseal Copied Text", for: .normal)
    unsealButton.sizeToFit()
    unsealButton.backgroundColor = .systemBlue
    unsealButton.setTitleColor(.white, for: [])
    unsealButton.translatesAutoresizingMaskIntoConstraints = false
    unsealButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    unsealButton.addTarget(
        self,
        action: #selector(unsealButtonPressed(_:)),
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

    buttonsView = UIStackView(arrangedSubviews: [requestButton, unsealButton, sealButton])
    buttonsView.axis = .horizontal
    buttonsView.spacing = KeyboardSpecs.horizontalSpacing
    buttonsView.distribution = .fillProportionally
  }

  /// Request button pressed, so perform key exchange process by placing our encryption public key in the input text field.
  @objc func requestButtonPressed(_ sender: Any) {
    textView.text = "request pressed" // TODO: placeholder
    let msg = MessageType.ECDH0.rawValue + "|" +
      asString(keys.encryptionPublicKey.rawRepresentation)
    controller.clearInputText()
    controller.textDocumentProxy.insertText(msg)
  }

  @objc func unsealButtonPressed(_ sender: Any) {
    // TODO: finish
    guard let copiedText = UIPasteboard.general.string else {
      textView.text = "No copied text found." // TODO: placeholder
      return
    }

    let tokens = copiedText.components(separatedBy: "|")
    NSLog("Tokens read: \(tokens)")

    switch MessageType(rawValue: tokens[0]){
    case .ECDH0:
      // Request to initiate ECDH, i.e., to generate a symmetric key.
      // Generate a symmetric key and send it over.
      // Expected format: "{.ECDH0}|{sender's public key}"
      if tokens.count != 2 { fallthrough }

      let theirEncryptionPublicKeyString = tokens[1]

      var ephemeralPublicKeyString, signatureString, signingPublicKeyString: String!
      // Start ECDH, store the symmetric key, and send them the public key
      do {
        (ephemeralPublicKeyString, signatureString, signingPublicKeyString) =
                try keys.ECDHKeyExchange(with: theirEncryptionPublicKeyString)
      } catch {
        NSLog(".ECDH0 error caught:\n\(error)")
        fallthrough
      }

      let msg = [
        MessageType.ECDH1.rawValue,
        ephemeralPublicKeyString,
        signatureString,
        signingPublicKeyString
      ].joined(separator: "|")

      controller.clearInputText()
      controller.textDocumentProxy.insertText(msg)

      // TODO: placeholder
      textView.text = "Request to generate symmetric key received."

    case .ECDH1:
      // Reposne to request to ECDH. Expect to receive ephemeral public key.
      // Verify signature, compute and save symmetric key.
      // Expected format: "{.ECDH1}|{ephemeralPublicKey}|{signature}|{signingPublicKey}"
      if tokens.count != 4 { fallthrough }

      do {
        try keys.verifyECDHKeyExchangeResponse(
          ephemeralPublicKeyString: tokens[1],
          signatureString: tokens[2],
          theirSigningPublicKeyString: tokens[3]
        )
      } catch {
        NSLog(".ECDH1 error caught:\n\(error)")
        fallthrough
      }


      // TODO: placeholder
      textView.text = "Symmetric key generated"

    case .ciphertext:
      // Ciphertext received. Verify signature and decrypt using symmetric key.
      if tokens.count != 4 { fallthrough }
      var plaintext: String

      do {
        plaintext = try keys.decrypt((tokens[1], tokens[2]), from: tokens[3])
      } catch {
          NSLog(".ciphertext error caught:\n\(error)")
          fallthrough
      }

      // TODO: placeholder
      textView.text = "Decrypted Message:\n\(plaintext)"

    default:
      textView.text = "Unknown type of message copied."
    }


  }

  @objc func sealButtonPressed(_ sender: Any) {
    // TODO: finish
    sealMessageBox()
    textView.text = "Text encrypted! Ready to be sent."

  }

  func sealAndSend() {
    sealMessageBox()
    textView.text = "Text encrypted and sent."
    // Apps with ReturnType of .send look for a single "\n" upon text change.
    // Thus change the text to ciphertext first, and insert one "\n" under textDidChange.
    controller.stageToSendText = true

  }

  func sealMessageBox() {
    let textInput = (controller.textDocumentProxy.documentContextBeforeInput ?? "") +
      (controller.textDocumentProxy.selectedText ?? "") +
      (controller.textDocumentProxy.documentContextAfterInput ?? "")

    if textInput.isEmpty {
      textView.text = "Unable to seal message because input text field is empty."
      return
    }

    var ciphertextString, signatureString, signingPublicKeyString: String!

    do {
      (ciphertextString, signatureString, signingPublicKeyString) = try keys.encrypt(textInput)
    } catch {
      NSLog("encryptButtonPressed error caught:\n\(error)")
      textView.text = "Something went wrong. Unable to encrypt. Try again later."
      return
    }
    let msg = [
      MessageType.ciphertext.rawValue,
      ciphertextString,
      signatureString,
      signingPublicKeyString
    ].joined(separator: "|")

    controller.clearInputText()
    controller.textDocumentProxy.insertText(msg)
  }

}
