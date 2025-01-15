//
//  CameraSession+Focus.swift
//  VisionCamera
//
//  Created by Marc Rousavy on 11.10.23.
//  Copyright © 2023 mrousavy. All rights reserved.
//

import AVFoundation
import Foundation

extension CameraSession {
  /**
   Focuses the Camera to the specified point. The point must be in the Camera coordinate system, so {0...1} on both axis.
   */
    func focus(point: CGPoint) throws -> NSDictionary {
    guard let device = videoDeviceInput?.device else {
      throw CameraError.session(SessionError.cameraNotReady)
    }
    if !device.isFocusPointOfInterestSupported {
      throw CameraError.device(DeviceError.focusNotSupported)
    }

    VisionLogger.log(level: .info, message: "Focusing (\(point.x), \(point.y))...")

    do {
      try device.lockForConfiguration()
      defer {
        device.unlockForConfiguration()
      }
        
      // Set Focus
        if device.isFocusPointOfInterestSupported {
        device.focusPointOfInterest = point
        device.focusMode = .autoFocus
      }

      // Set Exposure
      if device.isExposurePointOfInterestSupported {
        device.exposurePointOfInterest = point
        device.exposureMode = .autoExpose
      }
        
        
      // Remove any existing listeners
      NotificationCenter.default.removeObserver(self,
                                                name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                                object: nil)

        let shouldRefocus = configuration?.focusMode.toAVCaptureDeviceFocusMode() == .continuousAutoFocus
        let shouldReExpose = configuration?.exposureMode.toAVCaptureDeviceExposureMode() == .continuousAutoExposure
        
        if shouldRefocus || shouldReExpose {
          // Listen for focus completion
        device.isSubjectAreaChangeMonitoringEnabled = true
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(subjectAreaDidChange),
                                             name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                             object: nil)
        }
        
        let focusResult: NSDictionary = [
            "exposureTargetOffset": device.exposureTargetOffset,
            "iso": device.iso
        ]
        
        return focusResult
    } catch {
      throw CameraError.device(DeviceError.configureError)
    }
  }

  @objc
  func subjectAreaDidChange(notification _: NSNotification) {
    guard let device = videoDeviceInput?.device else {
      return
    }

    try? device.lockForConfiguration()
    defer {
      device.unlockForConfiguration()
    }
      
    let shouldRefocus = configuration?.focusMode.toAVCaptureDeviceFocusMode() == .continuousAutoFocus
    let shouldReExpose = configuration?.exposureMode.toAVCaptureDeviceExposureMode() == .continuousAutoExposure

    // Reset Focus to continuous/auto
    if shouldRefocus && device.isFocusPointOfInterestSupported {
      device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
      device.focusMode = configuration?.focusMode.toAVCaptureDeviceFocusMode() ?? .continuousAutoFocus
    }

    // Reset Exposure to continuous/auto
    if shouldReExpose && device.isExposurePointOfInterestSupported {
      device.exposurePointOfInterest = CGPoint(x: 0.5, y: 0.5)
      device.exposureMode = configuration?.exposureMode.toAVCaptureDeviceExposureMode() ?? .continuousAutoExposure
    }

    // Disable listeners
    device.isSubjectAreaChangeMonitoringEnabled = false
    // Remove any existing listeners
    NotificationCenter.default.removeObserver(self,
                                              name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                              object: nil)
  }
}
