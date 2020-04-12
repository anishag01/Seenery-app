//
//  ListeningScreen.swift
//  Seenery
//
//  Created by Krish Malik on 4/11/20.
//  Copyright © 2020 Krish Malik. All rights reserved.
//

import UIKit
import Speech


class ListeningScreen: UIViewController, SFSpeechRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    var textViewString = ""
    var obj = "Object"
    var street = "Food"
    var store = "Store"
    var groceries = "Groceries"
    
     private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
         
         private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
         private var recognitionTask: SFSpeechRecognitionTask?
         private let audioEngine = AVAudioEngine()
    

         override func viewDidLoad() {
            
             super.viewDidLoad()

             microphoneButton.isEnabled = false
             
             speechRecognizer.delegate = self
             microphoneButton.isEnabled = false
             microphoneButton.frame = CGRect(x: 160, y: 100, width: 50, height: 50)
             microphoneButton.layer.cornerRadius = 0.5 * microphoneButton.bounds.size.width
             microphoneButton.clipsToBounds = true
             view.addSubview(microphoneButton)
    
             
             SFSpeechRecognizer.requestAuthorization { (authStatus) in
                 
                 var isButtonEnabled = false
                 
                 switch authStatus {
                 case .authorized:
                     isButtonEnabled = true
                     
                 case .denied:
                     isButtonEnabled = false
                     print("User denied access to speech recognition")
                     
                 case .restricted:
                     isButtonEnabled = false
                     print("Speech recognition restricted on this device")
                     
                 case .notDetermined:
                     isButtonEnabled = false
                     print("Speech recognition not yet authorized")
                 }
                 
                 OperationQueue.main.addOperation() {
                     self.microphoneButton.isEnabled = isButtonEnabled
                 }
             }
         }

         @IBAction func microphoneTapped(_ sender: UIButton) {
            microphoneButton.setTitle("Start Recording", for: .normal)
            let pulse = PulseAnimation(numberOfPulse: Float.infinity, radius: 150, postion: sender.center)
            pulse.animationDuration = 1.0
            pulse.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            self.view.layer.insertSublayer(pulse, below: self.view.layer)
             if audioEngine.isRunning {
                 audioEngine.stop()
                 recognitionRequest?.endAudio()
                if textView.text == obj {
                    performSegue(withIdentifier: "listeningToObject", sender: nil)
                    print("hi")
                }
                else if textView.text == groceries {
                    performSegue(withIdentifier: "listeningToGroceries", sender: nil)
                    print("heloleoleoleeelole")
                }
                else if textView.text == street {
                    performSegue(withIdentifier: "listeningToStreet", sender: nil)
                    print("hiiiiiiiiiiiiiiiii")
                }
                 
                
             } else {
                microphoneButton.setTitle("Stop Recording", for: .normal)
                 startRecording()
             }
         }
    

         func startRecording() {
             
             if recognitionTask != nil {  //1
                 recognitionTask?.cancel()
                 recognitionTask = nil
             }
             
             let audioSession = AVAudioSession.sharedInstance()  //2
             do {
                try audioSession.setCategory(AVAudioSession.Category.record)
                try audioSession.setMode(AVAudioSession.Mode.measurement)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
             } catch {
                 print("audioSession properties weren't set because of an error.")
             }
             
             recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
             
            let inputNode = audioEngine.inputNode
            inputNode.removeTap(onBus: 0)
             
             guard let recognitionRequest = recognitionRequest else {
                 fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
             } //5
             
             recognitionRequest.shouldReportPartialResults = true  //6
             
             recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
                 
                 var isFinal = false  //8
                 
                 if result != nil {
                     
                     self.textView.text = result?.bestTranscription.formattedString  //9
                     isFinal = (result?.isFinal)!
                 }
                 
                 if error != nil || isFinal {  //10
                     self.audioEngine.stop()
                     inputNode.removeTap(onBus: 0)
                     
                     self.recognitionRequest = nil
                     self.recognitionTask = nil
                     
                     self.microphoneButton.isEnabled = true
                 }
             })
            

             
             let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
             inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                 self.recognitionRequest?.append(buffer)
             }
             
             audioEngine.prepare()  //12
             
             do {
                 try audioEngine.start()
             } catch {
                 print("audioEngine couldn't start because of an error.")
             }
             
            textView.text = "Go ahead, I'm listening..."
             
         }
         
         func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
             if available {
                 microphoneButton.isEnabled = true
             } else {
                 microphoneButton.isEnabled = false
             }
         }
     }


