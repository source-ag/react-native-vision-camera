//
//  FocusMode.swift
//  Pods
//
//  Created by Milan Barande on 14/01/2025.
//

import AVFoundation
import Foundation

@frozen
enum FocusMode: String, JSUnionValue {
  case auto
  case locked
  case continuousAuto

  init(jsValue: String) throws {
    if let parsed = FocusMode(rawValue: jsValue) {
      self = parsed
    } else {
      throw CameraError.parameter(.invalid(unionName: "focusMode", receivedValue: jsValue))
    }
  }

  init(from mode: AVCaptureDevice.FocusMode) {
    switch mode {
    case .locked:
      self = .locked
    case .autoFocus:
      self = .auto
    default:
      self = .continuousAuto
    }
  }

    func toAVCaptureDeviceFocusMode() -> AVCaptureDevice.FocusMode {
        switch self {
        case .locked:
            return .locked
        case .auto:
            return .autoFocus
        case .continuousAuto:
            return .continuousAutoFocus
        }
    }

  var jsValue: String {
    return rawValue
  }
}
