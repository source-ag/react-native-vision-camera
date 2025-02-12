//
//  WhiteBalanceGains.swift
//  Pods
//
//  Created by Milan Barande on 12/02/2025.
//

import AVFoundation
import Foundation

struct WhiteBalanceGains: Equatable {
  let red: Float
  let green: Float
  let blue: Float
    
    init(red: Float, green: Float, blue: Float) {
      self.red = red
      self.green = green
      self.blue = blue
    }
  
  init(jsValue: NSDictionary) throws {
    guard let red = jsValue["red"] as? NSNumber,
          let green = jsValue["green"] as? NSNumber,
          let blue = jsValue["blue"] as? NSNumber else {
      throw CameraError.parameter(.invalid(unionName: "whiteBalanceGains", receivedValue: jsValue.description))
    }
    
    self.red = red.floatValue
    self.green = green.floatValue
    self.blue = blue.floatValue
  }
  
  func toAVCaptureDeviceWhiteBalanceGains() -> AVCaptureDevice.WhiteBalanceGains {
    return AVCaptureDevice.WhiteBalanceGains(
      redGain: red,
      greenGain: green,
      blueGain: blue
    )
  }
  
  static func fromAVCaptureDeviceWhiteBalanceGains(_ gains: AVCaptureDevice.WhiteBalanceGains) -> WhiteBalanceGains {
    return WhiteBalanceGains(
      red: gains.redGain,
      green: gains.greenGain,
      blue: gains.blueGain
    )
  }
  
  func toJSValue() -> NSDictionary {
    return [
      "red": red,
      "green": green,
      "blue": blue
    ]
  }
}
