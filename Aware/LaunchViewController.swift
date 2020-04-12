//
//  LaunchViewController.swift
//  Seenery
//
//  Created by Krish Malik on 4/11/20.
//  Copyright © 2020 Krish Malik. All rights reserved.
//


import Foundation
import UIKit

class LaunchViewController: UIViewController, UIGestureRecognizerDelegate {
  @IBOutlet weak var toMoney: UIView!
  @IBOutlet weak var toMerchants: UIView!
  @IBOutlet weak var toAbout: UIView!
  @IBOutlet weak var toSettings: UIView!
  
  let speaker = Speaker()
  var segueTabNumber = -1
  var activeMode = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.isHidden = true
    
    // Setup double tap gesture
    
    // Setup segue ontap handlers
    toMoney.isOpaque = false
    toMoney.backgroundColor = UIColor.clear
    
    let moneyGesture = UITapGestureRecognizer(target: self, action: #selector(goToMoney))
    moneyGesture.delegate = self
    toMoney.addGestureRecognizer(moneyGesture)
    
    toMerchants.isOpaque = false
    toMerchants.backgroundColor = UIColor.clear
    
    let merchantGesture = UITapGestureRecognizer(target: self, action: #selector(goToMerchants))
    merchantGesture.delegate = self
    toMerchants.addGestureRecognizer(merchantGesture)

    toAbout.isOpaque = false
    toAbout.backgroundColor = UIColor.clear
    
    let aboutGesture = UITapGestureRecognizer(target: self, action: #selector(goToAbout))
    aboutGesture.delegate = self
    toAbout.addGestureRecognizer(aboutGesture)
    
    toSettings.isOpaque = false
    toSettings.backgroundColor = UIColor.clear
    
    let settingGesture = UITapGestureRecognizer(target: self, action: #selector(settingAlert))
    settingGesture.delegate = self
    toSettings.addGestureRecognizer(settingGesture)
    
    // Double tap gesture recogniser
    let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    tap.numberOfTapsRequired = 2
    view.addGestureRecognizer(tap)
  }
  
  @objc func doubleTapped(gesture: UITapGestureRecognizer) {
    if !disabledMode || !activeMode { return }
    
    performSegue(withIdentifier: "segueToTab", sender: nil)
  }
  
  @objc func settingAlert() {
    let alert = UIAlertController(title: "Set Home Locale", message: "You previously set your home location is: \"London, United Kingdom\".", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Yes, that's correct.", style: .default, handler: nil))
    
    alert.addAction(UIAlertAction(title: "No, use my current location.", style: .destructive, handler: nil))
    
    present(alert, animated: true)
  }
  
  @objc func goToMoney() {
    if disabledMode {
      activeMode = true
      segueTabNumber = 2
      speaker.textToSpeech("Double tap to confirm your choice to the currency calculator.")
      return
    }
    
    segueTabNumber = 2
    performSegue(withIdentifier: "segueToTab", sender: nil)
  }
  
  @objc func goToAbout() {
    performSegue(withIdentifier: "toAbout", sender: nil)
  }
  
  @objc func goToMerchants() {
    if disabledMode {
      activeMode = true
      segueTabNumber = 0
      speaker.textToSpeech("Double tap to confirm your choice to find nearby supermarkets.")
      return
    }
    
    segueTabNumber = 0
    performSegue(withIdentifier: "segueToTab", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier! == "segueToTab" else {
      return
    }
    
    let tabController = segue.destination as! MainTabBarController
    
    tabController.goToSegue = segueTabNumber
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    disabledMode = true
    
    speaker.textToSpeech("Welcome to \(currentCity).")
    speaker.textToSpeech("Press the top left for your travel currency calculator.")
    speaker.textToSpeech("Press the top right to find nearby supermarkets.")
    
    activeMode = true
    
  }
  
}
