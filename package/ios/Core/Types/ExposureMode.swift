//
//  ExposureMode.swift
//  Pods
//
//  Created by Milan Barande on 14/01/2025.
//

import AVFoundation
import Foundation

@frozen
enum ExposureMode: String, JSUnionValue {
  case auto
  case locked
  case continuousAuto
  case custom

  init(jsValue: String) throws {
    if let parsed = ExposureMode(rawValue: jsValue) {
      self = parsed
    } else {
      throw CameraError.parameter(.invalid(unionName: "exposureMode", receivedValue: jsValue))
    }
  }

    init(from mode: AVCaptureDevice.ExposureMode) {
      switch mode {
      case .locked:
        self = .locked
      case .autoExpose:
        self = .auto
      case .custom:
        self = .custom
      default:
        self = .continuousAuto
      }
    }

    func toAVCaptureDeviceExposureMode() -> AVCaptureDevice.ExposureMode {
        switch self {
        case .locked:
            return .locked
        case .auto:
            return .autoExpose
        case .continuousAuto:
            return .continuousAutoExposure
        case .custom:
            return .custom
        }
    }

    var jsValue: String {
      return rawValue
    }
  }
