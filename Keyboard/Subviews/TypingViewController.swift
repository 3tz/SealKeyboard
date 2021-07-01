//
//  TypingViewController.swift
//  Keyboard
//
//  Created by tz on 6/22/21.
//

import Foundation
import UIKit

extension String {
  var isSingleAlphabet: Bool {
    return self.rangeOfCharacter(from: CharacterSet.letters.inverted) == nil &&
      !self.isEmpty &&
      self.count == 1
  }
  var isLowercasedAlphabet: Bool {
    return self.rangeOfCharacter(from: CharacterSet.lowercaseLetters.inverted) == nil &&
      !self.isEmpty
  }
  var isUppercasedAlphabet: Bool {
    return self.rangeOfCharacter(from: CharacterSet.uppercaseLetters.inverted) == nil &&
      !self.isEmpty
  }
}

enum KeyboardMode: String {
  case alphabets
  case numbers
  case symbols
}

enum ShiftState: Int {
  case off
  case on
  case locked
}

class TypingViewController : UIViewController {
  var darkMode: Bool!
  var mode: KeyboardMode!
  var shiftState: ShiftState!
  var shiftDoubleTapped: Bool = false

  var buttonLookup: [String: KeyboardButton] = [:]
  var spacebarConstraints: [NSLayoutConstraint] = []

  weak var controller: KeyboardViewController!

  var backspaceHeldTimer: Timer!

  convenience init(parentController: KeyboardViewController) {
    self.init()
    controller = parentController
  }

  override func loadView() {
    mode = .alphabets
    shiftState = .off

    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 0

    view = stackView
    reloadButtonsToView()
    darkMode = traitCollection.userInterfaceStyle == .dark

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateReturnKey()
  }

  override func updateViewConstraints() {
    super.updateViewConstraints()
    // All normal buttons have the same size, so choose one of them and set constraints of
    //  other normal buttons based on that.
    let firstRow = (view as! UIStackView).arrangedSubviews[0] as! UIStackView
    let buttonWithStandardSize = firstRow.arrangedSubviews[0]

    // Same idea for spacers: spacers of the same row have the same width
    var spacerView: UIView? = nil
    var spacer2View: UIView? = nil

    // Add constraints to buttons
    for rowStackView in (view as! UIStackView).arrangedSubviews {
      for subView in (rowStackView as! UIStackView).arrangedSubviews {
        let keyname = subView.accessibilityIdentifier!

        guard let button = subView as? KeyboardButton else {
          // It's a spacer UIView
          // spacers of the same row have the same width
          switch keyname {
            case "spacer_1":
              if spacerView == nil {
                spacerView = subView
              }
              subView.widthAnchor.constraint(equalTo: spacerView!.widthAnchor).isActive = true
            case "spacer_2":
              if spacer2View == nil {
                spacer2View = subView
              }
              subView.widthAnchor.constraint(equalTo: spacer2View!.widthAnchor).isActive = true
            default:
              fatalError()
          }
          subView.heightAnchor.constraint(
            equalTo: buttonWithStandardSize.heightAnchor).isActive = true
          continue
        }

        // all buttons have the same height
        button.heightAnchor.constraint(
          equalTo: buttonWithStandardSize.heightAnchor).isActive = true

        // Calculate width of keys
        // Letters = Symbols \ {.,?!'}
        // Spacers_of_row_i = Spacers_of_row_i
        // Space = 5 * Letter + 4 * HorizonalSpacing
        // 123 = ABC = switch = Shift = Backspace = Numbers = #+=
        //     = [(10-5) * Letter + (9-6-2) * HorizontalSpacing] / 4
        //     = 1.25 * Letter + 0.25 * horizontal Spacing
        switch keyname {
          case "123", "ABC", "switch", "shift", "backspace", "#+=", ".", ",", "?", "!", "'":
            button.widthAnchor.constraint(
                equalTo: buttonWithStandardSize.widthAnchor,
                multiplier: 1.25
              ).isActive = true
          case keyname where keyname.count == 1:
            button.widthAnchor.constraint(
              equalTo: buttonWithStandardSize.widthAnchor).isActive = true
          case "space":
            let constraint = button.widthAnchor.constraint(
              equalTo: buttonWithStandardSize.widthAnchor,
              multiplier: 4
            )
            constraint.isActive = true
            spacebarConstraints.append(constraint)
          case "seal":
            let constraint = button.widthAnchor.constraint(
              equalTo: buttonLookup["return"]!.widthAnchor
            )
            constraint.isActive = true
            spacebarConstraints.append(constraint)
          default:
            break
        }
      }
    }

    // Update button colors
    for rowStackView in (view as! UIStackView).arrangedSubviews {
      for subView in (rowStackView as! UIStackView).arrangedSubviews {
        guard let button = subView as? KeyboardButton else {
          // It's a spacer UIView
          continue
        }
        button.setDarkModeState(darkMode)
      }
    }
    updateReturnKey()
  }

  // MARK: private methods for loading subviews

  private func reloadButtonsToView() {
    for subview in view.subviews {
      subview.removeFromSuperview()
    }
    // Create the buttons
    for row in KeyboardSpecs.buttonLayout[mode.rawValue]! {
      var rowOfButtons: [UIView] = []
      for keyname in row {

        // spacers use empty UIView instead of buttons
        if keyname == "spacer_1" || keyname == "spacer_2" {
          let spacer = UIView()
          spacer.translatesAutoresizingMaskIntoConstraints = false
          spacer.accessibilityIdentifier = keyname
          rowOfButtons.append(spacer)
          continue
        }

        // Now build each button
        let button = KeyboardButton(keyname: keyname)
        buttonLookup[keyname] = button

        // Assign display char
        // Special symbols: ⇧ ⇪  ⌫
        switch keyname {
          case "shift":
            button.setTitle("⇧", for: .normal)
          case "backspace":
            button.setTitle("⌫", for: .normal)
          case "switch":
            button.setImage(UIImage(systemName: "globe"), for: .normal)
          case "return":
            // don't set title for return because it depends on UIReturnKeyType
            rowOfButtons.append(KeyboardButton(keyname: "seal"))
            buttonLookup["seal"] = (rowOfButtons.last! as! KeyboardButton)
          default:
            button.setTitle(keyname, for: .normal)
        }

        // Assign the target actions
        // Shift & backspace have their own special selector funcs
        // All special keys minus space & return perform their actions upon touchdown
        // all normal keys and space & return perform actions upon touchup inside
        switch keyname {
          case "switch":
            button.addTarget(
              controller,
              action: #selector(controller.handleInputModeList(from:with:)),
              for: .allTouchEvents
            )
          case "shift":
            button.addTarget(
              self,
              action: #selector(shiftMutipleTouch(_:event:)),
              for: .touchDownRepeat
            )
          case "backspace":
            button.addGestureRecognizer(
              UILongPressGestureRecognizer(target: self, action: #selector(backspaceHeld(_:)))
            )
          case keyname where KeyboardSpecs.specialKeyNames.contains(keyname) &&
                keyname != "space" && keyname != "return" && keyname != "seal":
            break
          default:
            button.addTarget(self, action: #selector(keyTouchUpInside(_:event:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(keyDragEnter(_:event:)), for:
                              [.touchDragEnter, .touchDragInside])
        }

        button.addTarget(self, action: #selector(keyTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(keyUntouched(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(keyUntouched(_:event:)), for: .touchDragInside)

        rowOfButtons.append(button)
      }

      // Create a stackview for current row
      let rowStackView = UIStackView(arrangedSubviews: rowOfButtons)
      rowStackView.axis = .horizontal
      rowStackView.spacing = 0
      rowStackView.alignment = .fill

      (view as! UIStackView).addArrangedSubview(rowStackView)
    }

  }

  private func toggleLettersCases(to newState: ShiftState) {
    if shiftState == newState { return }
    NSLog("Letter cases toggled from \(shiftState!) to \(newState)")
    shiftState = newState

    for rowStackView in (view as! UIStackView).arrangedSubviews {
      for subView in (rowStackView as! UIStackView).arrangedSubviews {
        guard let button = subView as? KeyboardButton else { continue }
        var keyname = button.accessibilityIdentifier!

        switch keyname {
          case "shift":
            switch shiftState {
              case .off:
                button.setBackgroundColor(darkMode ? .darkGray : .lightGray)
                button.setTitleColor(darkMode ? .white : .black, for: [])
                button.setTitle("⇧", for: .normal)
              case .on:
                button.setBackgroundColor(.white)
                button.setTitleColor(.black, for: [])
                button.setTitle("⇧", for: .normal)
              case .locked:
                button.setBackgroundColor(.white)
                button.setTitleColor(.black, for: [])
                button.setTitle("⇪", for: .normal)
              default:
                fatalError()
            }
          case keyname where keyname.isSingleAlphabet:
            keyname = shiftState == .on || shiftState == .locked
              ? keyname.uppercased() : keyname.lowercased()
            button.accessibilityIdentifier = keyname
            button.setTitle(keyname, for: .normal)
          default:
            break
        }
      }
    }
  }

  private func updateReturnKey() {
    // Update return key type
    let returnType = controller.textDocumentProxy.returnKeyType ?? .default
    switch returnType {
      case .send:
        for constraint in spacebarConstraints {
          constraint.isActive = false
        }
        spacebarConstraints.removeAll()
        let firstRow = (view as! UIStackView).arrangedSubviews[0] as! UIStackView
        let buttonWithStandardSize = firstRow.arrangedSubviews[0]
        let constraint = buttonLookup["space"]!.widthAnchor.constraint(
          equalTo: buttonWithStandardSize.widthAnchor,
          multiplier: 5
        )
        constraint.isActive = true
        spacebarConstraints.append(constraint)

        buttonLookup["return"]!.removeFromSuperview()
        buttonLookup["seal"]!.setTitle("Seal & Send", for: .normal)
      case .default:
        buttonLookup["seal"]!.setTitle("Seal", for: .normal)
        buttonLookup["return"]!.setTitle("return", for: .normal)
      default:
        buttonLookup["seal"]!.setTitle("Seal", for: .normal)
        buttonLookup["return"]!.setTitle(
          KeyboardSpecs.returnKeyTypeToString[returnType, default: "return"],
          for: .normal)
    }
  }

  // MARK: button trigger methods. To future self, sorry.

  /// Reset key color back to unpressed.
  @objc private func keyUntouched(_ sender: KeyboardButton) {
    if sender.accessibilityIdentifier == "shift" { return }

    sender.setKeyColor(pressed: false, darkMode: darkMode)
  }

  /// Reset key color back to unpressed if touch is dragged to exterior of its bounds.
  @objc private func keyUntouched(_ sender: KeyboardButton, event: UIEvent) {
    if sender.accessibilityIdentifier == "shift" { return }

    // if a touch is actually still inside the button, don't make it be unpressed
    let touch = event.touches(for: sender)!.first!
    if sender.bounds.contains(touch.location(in: sender)) { return }

    sender.setKeyColor(pressed: false, darkMode: darkMode)
  }

  @objc private func keyDragEnter(_ sender: KeyboardButton, event: UIEvent) {
    let touch = event.touches(for: sender)!.first!
    if sender.bounds.contains(touch.location(in: sender)) {
      sender.setKeyColor(pressed: true, darkMode: darkMode)
    }
  }

  /// Only normal keys and space & return should call this method for .touchUpInside
  /// Perform actions of @sender correspondingly.
  @objc private func keyTouchUpInside(_ sender: KeyboardButton, event: UIEvent) {
    let keyname = sender.accessibilityIdentifier!

    // if touch is not actually inside, ignore
    let touch = event.touches(for: sender)!.first!
    if !sender.bounds.contains(touch.location(in: sender)) { return }

    // Clicking any key key while shift is on but not locked toggles shift back to off
    if shiftState == .on && keyname != "shift" {
      toggleLettersCases(to: .off)
      shiftDoubleTapped = false
    }

    switch keyname {
      case "space":
        controller.textDocumentProxy.insertText(" ")
      case "return":
        let returnKeyType = controller.textDocumentProxy.returnKeyType ?? .default

        switch returnKeyType {
          case .send:
            if !controller.textDocumentProxy.hasText { break }
            controller.cryptoBar.sealAndSend()
          default:
            controller.textDocumentProxy.insertText("\n")
        }
      default:
        controller.textDocumentProxy.insertText(keyname)
    }
  }

  @objc private func shiftMutipleTouch(_ sender: KeyboardButton, event: UIEvent) {
    if event.allTouches!.first!.tapCount % 2 != 0 { return }
    // Let touchUpInside know that the touch up action this time is from doubletaps
    shiftDoubleTapped = true
    toggleLettersCases(to: .locked)
    shiftDoubleTapped = false
  }

  @objc private func keyTouchDown(_ sender:KeyboardButton) {
    let keyname = sender.accessibilityIdentifier

    switch keyname {
      case "123":
        mode = .numbers
        reloadButtonsToView()
      case "ABC":
        mode = .alphabets
        reloadButtonsToView()
        toggleLettersCases(to: .off)
      case "#+=":
        mode = .symbols
        reloadButtonsToView()
      case "backspace":
        sender.setKeyColor(pressed: true, darkMode: darkMode)
        controller.textDocumentProxy.deleteBackward()
      case "shift":
        if !shiftDoubleTapped {
          switch shiftState {
            case .on:
              toggleLettersCases(to: .off)
            case .off:
              toggleLettersCases(to: .on)
            case .locked:
              toggleLettersCases(to: .off)
            default:
              fatalError()
          }
        }
        shiftDoubleTapped = false
      default:
        sender.setKeyColor(pressed: true, darkMode: darkMode)
    }

  }

  @objc private func backspaceHeld(_ sender: UIGestureRecognizer) {
    var count = 0
    if sender.state == .began {
      backspaceHeldTimer = Timer.scheduledTimer(
        withTimeInterval: KeyboardSpecs.backspaceHeldDeleteInterval, repeats: true) { timer in
        count += 1
        self.controller.textDocumentProxy.deleteBackward()

        // Delete faster
        if count > 15 {
          self.backspaceHeldTimer.invalidate()
          self.backspaceHeldTimer =  Timer.scheduledTimer(
            withTimeInterval: KeyboardSpecs.backspaceHeldDeleteInterval * 2, repeats: true) { timer in
            for _ in 0..<20 {
              self.controller.textDocumentProxy.deleteBackward()
            }
          }
        }
      }
    }
    else if sender.state == .ended {
      backspaceHeldTimer.invalidate()
      (sender.view as! KeyboardButton).setKeyColor(pressed: false, darkMode: darkMode)
    }
  }
}
