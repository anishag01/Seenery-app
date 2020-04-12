//
//  SecondViewController.swift
//  Seenery
//
//  Created by Krish Malik on 4/11/20.
//  Copyright © 2020 Krish Malik. All rights reserved.
//


import UIKit
import AVKit

class ShoppingViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

  let speaker = Speaker()
  
  var captureSession: AVCaptureSession?
  var videoPreviewLayer: AVCaptureVideoPreviewLayer?

  var frameDelegate: CameraFrameHandler? = nil
  
  var enable = false
  
  @IBOutlet weak var viewFinder: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    print("Camera loaded")
    
//    let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
//    tap.numberOfTapsRequired = 1
//    viewFinder.addGestureRecognizer(tap)
    
    askForCameraPermissions { [unowned self] granted in
      if !granted {
        print("No camera permission")
        return
      }
      
      self.frameDelegate = CameraFrameHandler(responseDelegate: self)
      self.setupCaptureSession()
    }
  }
  
  @objc func doubleTapped(gesture: UITapGestureRecognizer) {
    enable = true
  }
  
  func askForCameraPermissions(_ completion: @escaping (Bool) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized: // The user has previously granted access to the camera.
      print("OK")
      completion(true)
      
    case .notDetermined: // The user has not yet been asked for camera access.
      AVCaptureDevice.requestAccess(for: .video) { granted in
        completion(granted)
      }
      
    case .denied: // The user has previously denied access.
      print("Denied")
      completion(false)

    case .restricted: // The user can't grant access due to restrictions.
      print("Restriction problems")
      completion(false)
    }
  }
  
  func setupCaptureSession() {
    // Setup camera
    let captureDevice = AVCaptureDevice.default(for: .video)
    
    let input: AVCaptureDeviceInput?
    do {
      input = try AVCaptureDeviceInput(device: captureDevice!)
    } catch {
      input = nil
      print(error)
    }
    
    guard let cameraInput = input else {
      // Error
      return
    }
    
    captureSession = AVCaptureSession()
    
    captureSession?.sessionPreset = AVCaptureSession.Preset.photo
    
    captureSession?.addInput(cameraInput)
    
//    configureVideoOrientation()
    
    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
    videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    videoPreviewLayer?.frame = view.layer.bounds

    if let connection = videoPreviewLayer?.connection {
      connection.videoOrientation = .portrait
    } else {
      print("Error: orientation")
    }

    viewFinder.layer.addSublayer(videoPreviewLayer!)
    
    // Add delegate
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
    videoOutput.setSampleBufferDelegate(frameDelegate, queue: DispatchQueue(label: "frame buffer"))
    
//    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .default))
   
    captureSession?.addOutput(videoOutput)
    
    print(videoOutput.connections.count)
    
    if let connection = videoOutput.connection(with: .video) {
      connection.videoOrientation = .portrait
    } else {
      print("Error orientation")
    }
    
    
    captureSession?.startRunning()
  }
  
//  private func configureVideoOrientation() {
//    if let preview = self.videoPreviewLayer,
//      let connection = preview.connection {
//      let orientation = UIDevice.current.orientation
//
//      if connection.isVideoOrientationSupported {
//        var videoOrientation: AVCaptureVideoOrientation
//        switch orientation {
//        case .portrait:
//          videoOrientation = .portrait
//        case .portraitUpsideDown:
//          videoOrientation = .portraitUpsideDown
//        case .landscapeLeft:
//          videoOrientation = .landscapeRight
//        case .landscapeRight:
//          videoOrientation = .landscapeLeft
//        default:
//          videoOrientation = .portrait
//        }
//        preview.frame = self.view.bounds
//        connection.videoOrientation = videoOrientation
//      }
//    }
//  }
  

  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    if !enable {
      return
    }
    
    let img = imageFromSampleBuffer(sampleBuffer: sampleBuffer)
    guard let unwrapped = img else {
      print("Cannot recognise image")
      enable = false
      return
    }
    
    DispatchQueue.main.sync { [unowned self] in
      let imgView = UIImageView(image: unwrapped)
      self.viewFinder.addSubview(imgView)
      self.enable = false
    }
    
    
//    view.addSubview(imageview)
    
    
  }
  
  private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
    let context = CIContext()
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
    return UIImage(cgImage: cgImage)
  }
  

}

extension ShoppingViewController: ResponseDataHandler {
  func reportExchange(objectLabel: String, localCurrency: String, localValue: Float, homeValue: Float) {
    
    if disabledMode {
      // Vibrate device
      AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { [unowned self] in
        // Make speech
        self.speaker.textToSpeech("Detected: \(objectLabel)")
        self.speaker.textToSpeech("It costs \(localValue) \(currencyToString[localCurrency]!).")
        self.speaker.textToSpeech("This is approximately \(homeValue) \(currencyToString[homeCurrency]!)")
      }
    } else {
      
      // Show UIAlert
      
      captureSession?.stopRunning()
      
      let alert = UIAlertController(title: "Detected: \(objectLabel)", message: "Local: \(localCurrency)\(localValue) \n Home: \(homeCurrency)\(homeValue)", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
        self.captureSession?.startRunning()
      })
      
      present(alert, animated: true, completion: nil)
    }
    
    
  }
}
