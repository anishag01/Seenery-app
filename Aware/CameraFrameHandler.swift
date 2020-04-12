//
//  CameraFrameHandler.swift
//  Seenery
//
//  Created by Krish Malik on 4/11/20.
//  Copyright © 2020 Krish Malik. All rights reserved.
//


import Foundation
import AVKit
import FirebaseMLVision

protocol ResponseDataHandler {
  // Pass in object and price?
  // Pass in the relevant things required for the camera view controller to render or speak
  
  func reportExchange(objectLabel: String, localCurrency: String, localValue: Float, homeValue: Float)
  
}

class CameraFrameHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
  
  let responseDelegate: ResponseDataHandler
  private lazy var vision = Vision.vision()
  private lazy var textRecognizer = vision.onDeviceTextRecognizer()
  private lazy var labeler = vision.onDeviceImageLabeler()
  
  let rulebasedBlacklist = Set(["Musical instrument", "Desk", "Space", "Room", "Tableware"])
  
  var lastSeen: Float = 0
  var isProcessing = false
  
  init(responseDelegate: ResponseDataHandler) {
    self.responseDelegate = responseDelegate
    super.init()
  }
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    if isProcessing {
      return
    }
    
    isProcessing = true
    if let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer) {
      runTextRecognition(with: image)
    } else {
      isProcessing = false
    }
    
  }
  
  
  private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
    let context = CIContext()
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
    return UIImage(cgImage: cgImage)
  }
  
  func runTextRecognition(with image: UIImage) {
    let visionImage = VisionImage(image: image)

    DispatchQueue.global(qos: .background).sync { [unowned self] in
      self.textRecognizer.process(visionImage) { features, error in
        self.processResult(visionImage, from: features, error: error)
        self.isProcessing = false
      }
    }
  }
  
  func processResult(_ visionImage: VisionImage, from text: VisionText?, error: Error?) {
    // Extract all detected text
    guard let text = text else { return }
    
    let detectedTexts = text.blocks.map { $0.text }
    
    // Check whether there are money records
    let moneyTexts = detectedTexts.filter { isMoney($0) }
    
    // Make sure only 1 (if more than one, the user is not close enough)
    if moneyTexts.count != 1 { return }
    
    // Extract monetary value
    let moneyValue = getMoneyValue(moneyTexts[0])
    
    guard let (currency, value) = moneyValue else {
      return
    }
    
    // Check photo for object
    DispatchQueue.global(qos: .background).sync { [unowned self] in
      self.labeler.process(visionImage) { labels, error in
        guard error == nil, let labels = labels else { return }
      
        var objectLabel = ""
        var maxConfidence: NSNumber = 0
        
        for label in labels {
          
          if self.rulebasedBlacklist.contains(label.text) {
            continue
          }
          
          print("\(label.text) :: \(label.confidence!)")
          if let localConfidence = label.confidence {
            if localConfidence.compare(maxConfidence) == ComparisonResult.orderedDescending {
              objectLabel = label.text
              maxConfidence = localConfidence
            }
          }
        }
        
        if objectLabel == "" {
          return
        }
        
//         If previously seen, ignore
        if self.lastSeen == value && disabledMode {
          return
        }
        
        // Convert to home value
        let homePrice = getHomePrice(currency: currency, value: value)
        
        guard let homeValue = homePrice else {
          return
        }
        
        // Update last seen
        self.lastSeen = value
        
        self.responseDelegate.reportExchange(objectLabel: objectLabel, localCurrency: currency, localValue: value, homeValue: homeValue)
      }
      
    }
    
    
  }
  
  private func isMoney(_ text: String) -> Bool {
    let source = text
    let linkRegexPattern = "[$£¥][0-9]+(\\.[0-9]+)?"
    let linkRegex = try! NSRegularExpression(pattern: linkRegexPattern,
                                             options: .caseInsensitive)
    let matches = linkRegex.matches(in: source,
                                    range: NSMakeRange(0, source.utf16.count))
    
    return matches.count == 1
  }
  
  private func getMoneyValue(_ text: String) -> (String, Float)? {
    print(text)
    let end = text.count
    
    guard let value = Float(text[1..<end]) else {
      return nil
    }
    
    return (text[0...0], value)
  }
  
}


/*
 //
 //  ImageRecognition.swift
 //  TravelForAll
 //
 //  Created by Sharen Choi on 26/1/2019.
 //  Copyright © 2019 Anson Miu. All rights reserved.
 //
 
 import Foundation
 import UIKit
 import FirebaseMLVision
 class ViewController : UIViewController{
 
 private lazy var vision = Vision.vision()
 private lazy var textRecognizer = vision.onDeviceTextRecognizer()
 
 func runTextRecognition(with image: UIImage) {
 let visionImage = VisionImage(image: image)
 textRecognizer.process(visionImage) { features, error in
 self.processResult(from: features, error: error)
 }
 }
 func processResult(from text: VisionText?, error: Error?) {
 text?.blocks.forEach { block in
 print(block.text)
 }
 //        removeDetectionAnnotations()
 //        guard error == nil, let text = text else {
 //            let errorString = error?.localizedDescription ?? Constants.detectionNoResultsMessage
 //            print("Text recognizer failed with error: \(errorString)")
 //            return
 //        }
 //
 //        let transform = self.transformMatrix()
 //
 //        // Blocks.
 //        for block in text.blocks {
 //            drawFrame(block.frame, in: .purple, transform: transform)
 //
 //            // Lines.
 //            for line in block.lines {
 //                drawFrame(line.frame, in: .orange, transform: transform)
 //
 //                // Elements.
 //                for element in line.elements {
 //                    drawFrame(element.frame, in: .green, transform: transform)
 //
 //                    let transformedRect = element.frame.applying(transform)
 //                    let label = UILabel(frame: transformedRect)
 //                    label.text = element.text
 //                    label.adjustsFontSizeToFitWidth = true
 //                    self.annotationOverlayView.addSubview(label)
 //                }
 //            }
 //        }
 }
 
 }
 */
