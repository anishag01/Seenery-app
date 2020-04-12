//
//  MerchantCell.swift
//  Seenery
//
//  Created by Krish Malik on 4/11/20.
//  Copyright © 2020 Krish Malik. All rights reserved.
//

import Foundation
import UIKit

class MerchantCell: UITableViewCell {
  
  @IBOutlet weak var view: UIView!
  @IBOutlet weak var minuteLabel: UILabel!
  @IBOutlet weak var mapButton: UIButton!
  @IBOutlet weak var detailLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
    
  var merchant: Merchant? = nil
  var tableViewController: MerchantTableViewController? = nil
  
  @IBAction func onButtonClick(_ sender: Any) {
    tableViewController!.goToMap(merchant!)
  }
  
}
