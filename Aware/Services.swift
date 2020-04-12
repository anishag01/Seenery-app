//
//  File.swift
//  Seenery
//
//  Created by Krish Malik on 4/11/20.
//  Copyright © 2020 Krish Malik. All rights reserved.
//


import Foundation
import MapKit

enum POI_TYPES {
  case CONVENIENT_STORE
  case COFFEE_SHOP
}

protocol Spoken {
  func toSpokenString() -> String
}

let currencyToRate: [String:Float] = [
  "$": 0.78,
  "£": 1,
  "¥": 0.01,
  "€": 0.89
]

//let currencyToRate: [String:Float] = [
//  "$": 1,
//  "£": 10.08
//]

func getHomePrice(currency: String, value: Float) -> Float? {
  if let rate = currencyToRate[currency] {
    return round(value * rate * 100) / 100
  }
  
  return nil
}

func getMerchants() -> [Merchant] {
return [
    Merchant(name: "Whole Foot Market", address: "1765 California Street, CA 94109", walkMinutes: 22, coordinate: CLLocationCoordinate2D(latitude: 37.7899512, longitude: -122.4231006)),

    Merchant(name: "Mollie Stone's Markets", address: "2435 California Street, CA 94115", walkMinutes: 33, coordinate: CLLocationCoordinate2D(latitude: 37.7887, longitude: -122.4345)),

    Merchant(name: "Lucky", address: "1750 Fulton Street, CA 944117", walkMinutes: 34, coordinate: CLLocationCoordinate2D(latitude: 37.7762, longitude: -122.4458))
  
//    Merchant(name: "Tesco", address: "50 Old Brompton Rd, SW7 3DY", walkMinutes: 10, coordinate: CLLocationCoordinate2D(latitude: 51.4933, longitude: -0.1764)),
//    
//    Merchant(name: "Waitrose", address: "Gloucester Road Mall, SW7 4SS", walkMinutes: 15, coordinate: CLLocationCoordinate2D(latitude: 51.4943, longitude: -0.1823)),
//    
//    Merchant(name: "Sainsbury", address: "158A Cromwell Rd, SW7 4EJ", walkMinutes: 19, coordinate: CLLocationCoordinate2D(latitude: 51.4956, longitude: -0.1881))
  ]
}

struct Merchant: Spoken {
  
  let name: String
  let address: String
  let queueMinutes: Int
  let coord: CLLocationCoordinate2D
  
  var walkMinutes: Int
  
  init(name: String, address: String, queueMinutes: Int = 0, walkMinutes: Int = 0, coordinate: CLLocationCoordinate2D) {
    self.name = name
    self.address = address
    self.walkMinutes = walkMinutes
    self.queueMinutes = queueMinutes
    self.coord = coordinate 
  }
  
  func toSpokenString() -> String {
    return "\(self.name) is \(self.walkMinutes) minutes away from you."
  }
  
}
