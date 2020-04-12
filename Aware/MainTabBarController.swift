//
//  MainTabBarController.swift
//  Seenery
//
//  Created by Krish Malik on 4/11/20.
//  Copyright © 2020 Krish Malik. All rights reserved.
//


import Foundation
import UIKit

class MainTabBarController: UITabBarController {
  
  var goToSegue: Int? = nil
  
  override func viewDidLoad() {
    if let segueNumber = goToSegue {
      selectedIndex = segueNumber
    }
  }
  
}
