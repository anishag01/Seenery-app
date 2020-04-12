//
//  MockLocationService.swift
//  Seenery
//
//  Created by Krish Malik on 4/11/20.
//  Copyright © 2020 Krish Malik. All rights reserved.
//


import Foundation
import CoreLocation

class MockLocationService {
  
  func getCurrentLocation() -> CLLocationCoordinate2D {
    
    return CLLocationCoordinate2D(latitude: 37.7793, longitude: -122.4193)
//    return CLLocationCoordinate2D(latitude: 51.4981, longitude: -0.1773)
  }
  
}

fileprivate var mockLocationService: MockLocationService? = nil

func getLocationService() -> MockLocationService {
  if mockLocationService == nil {
    mockLocationService = MockLocationService()
  }
  
  return mockLocationService!
}

