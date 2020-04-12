//
//  AboutController.swift
//  Seenery
//
//  Created by Krish Malik on 4/11/20.
//  Copyright © 2020 Krish Malik. All rights reserved.
//


import Foundation
import UIKit

class AboutController: UIViewController {
  
  
  @IBOutlet weak var paragraphs: UILabel!
  
  let speaker = Speaker()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    paragraphs.frame = CGRect(x: 0,y: 0,width: 300,height: 500);
    paragraphs.lineBreakMode = .byWordWrapping
    paragraphs.textAlignment = .center
    paragraphs.numberOfLines = 10
    paragraphs.text = "Eye Travel is a native iOS application that leverages on-device price and object recognition, making it possible for users to get real-time currency exchange calculation, simply by pointing the camera to the price tag. The app also makes uses of various VISA APIs, such as the Merchant Search API, and FirebaseML APIs.  iOS text to speech service and other interactive were used to make the app accessible by the visually impaired ones."
    

    
    }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    speaker.textToSpeech(paragraphs.text!)
  }

}
