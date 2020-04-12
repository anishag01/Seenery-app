//
//  MerchantViewController.swift
//  Seenery
//
//  Created by Krish Malik on 4/11/20.
//  Copyright © 2020 Krish Malik. All rights reserved.
//


import Foundation
import UIKit

class MerchantViewController: UIViewController {
  
  let speaker = Speaker()
  var nearbyMerchants: [Merchant] = []
  var handleTapResonse = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    // Update merchants
    nearbyMerchants = getMerchants()
    
    // Double tap gesture recogniser
    let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    tap.numberOfTapsRequired = 2
    view.addGestureRecognizer(tap)
  }
  
  @objc func doubleTapped(gesture: UITapGestureRecognizer) {
    
    
    
    
    if !handleTapResonse { return }
    
    speaker.textToSpeech("You double tapped!") { [unowned self] in
      
      // Pass data to map
      let mapVC = self.tabBarController?.viewControllers![1] as! MapViewController
      
      mapVC.navigateTo = self.nearbyMerchants[0]
      
      self.tabBarController?.selectedIndex += 1
    }
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    disabledMode = true
    
    let merchantCount = self.nearbyMerchants.count
    if merchantCount == 0 {
      self.speaker.textToSpeech("There are no nearby merchants.")
    } else {
      self.speaker.textToSpeech("There are \(merchantCount) nearby merchants.")
      for merchant in self.nearbyMerchants {
        self.speaker.textToSpeech(merchant.toSpokenString())
      }
      
      self.speaker.textToSpeech("To get directions to your nearest merchant, double tap.") { [unowned self] in
        self.handleTapResonse = true
      }
    }
  
    
  }
  
}
