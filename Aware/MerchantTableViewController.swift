//
//  MerchantTableViewController.swift
//  Seenery
//
//  Created by Krish Malik on 4/11/20.
//  Copyright © 2020 Krish Malik. All rights reserved.
//


import Foundation
import UIKit

class MerchantTableViewController: UITableViewController {
  
  let speaker = Speaker()
  var merchants: [Merchant] = []
  var handleTapResonse = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Get the latest merchants
    merchants = getMerchants()
    
    // Double tap gesture recogniser
    let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    tap.numberOfTapsRequired = 2
    view.addGestureRecognizer(tap)
    
    if disabledMode { helpSpeech() }
  }
  
  func helpSpeech() {
    let merchantCount = self.merchants.count
    if merchantCount == 0 {
      self.speaker.textToSpeech("There are no nearby supermarket.")
    } else {
      self.speaker.textToSpeech("There are \(merchantCount) nearby supermarket.")
      for merchant in self.merchants {
        self.speaker.textToSpeech(merchant.toSpokenString())
      }
      
      self.speaker.textToSpeech("To get directions to your nearest supermarket, double tap.") { [unowned self] in
        self.handleTapResonse = true
      }
    }
  }
  
  @objc func doubleTapped(gesture: UITapGestureRecognizer) {
    if !handleTapResonse { return }
    
    speaker.textToSpeech("Proceeding to your nearest supermarket.") { [unowned self] in
      self.goToMap(self.merchants[0])
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return merchants.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MerchantCell
    
    let merchant = merchants[indexPath.row]
    cell.tableViewController = self
    cell.merchant = merchant
    
    cell.minuteLabel.text = "\(merchant.walkMinutes)"
    cell.detailLabel.text = merchant.name
    cell.addressLabel.text = merchant.address
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let merchant = merchants[indexPath.row]
    
    goToMap(merchant)
  }
  
  
  func goToMap(_ merchant: Merchant) {
    // Pass data to map
    let mapVC = self.tabBarController?.viewControllers![1] as! MapViewController
    
    mapVC.navigateTo = merchant
    
    self.tabBarController?.selectedIndex += 1
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if disabledMode {
      helpSpeech()
    }
  }
  
}
