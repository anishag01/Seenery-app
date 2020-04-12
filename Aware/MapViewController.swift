//
//  FirstViewController.swift
//  Seenery
//
//  Created by Krish Malik on 4/11/20.
//  Copyright © 2020 Krish Malik. All rights reserved.
//


import UIKit
import MapKit
import AudioToolbox

class MapViewController: UIViewController, MKMapViewDelegate {

  @IBOutlet weak var mapView: MKMapView!
  
  let speaker = Speaker()
  
  var coordFrom: CLLocationCoordinate2D? = nil
  var navigateTo: Merchant? = nil
  var directionInstructions: [String] = []
  var directionCount: Int = 1
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    print("Map did load!")
    
    self.mapView.delegate = self
    computeDirections()
  }
  
  func computeDirections() {
    // Error handling for undefined values
//    guard var from = coordFrom else {
//      print("FROM coordinate is nil")
//      return
//    }
    
    guard let merchant = navigateTo else {
      print("MERCHANT is nil")
      return
    }
    
    if disabledMode { speaker.textToSpeech("Computing directions to \(merchant.name).") }
    
    // Setup request
    let request  = MKDirections.Request()
    
//    let testFrom = CLLocationCoordinate2D(latitude: 51.4944, longitude: -0.1827)
//    let testTo = CLLocationCoordinate2D(latitude: 51.4988, longitude: -0.1749)
    
    let from = getLocationService().getCurrentLocation()
    let to = merchant.coord
    
    print(from)
    print(merchant.coord)
    
    request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
    
//    request.transportType = .walking
    request.transportType = .walking
    
    let directions = MKDirections(request: request)
    
    directions.calculate { [unowned self] response, error in
      guard let unwrappedResponse = response else {
        print(error)
        return
      }
      
      // Update route directions
      self.directionInstructions = []
      self.directionCount = 0
    
      unwrappedResponse.routes.forEach { route in
        route.steps.forEach { step in
          let instruction = step.instructions
          print(instruction)
          
          self.directionInstructions.append(instruction)
        }
      }
      
      for route in unwrappedResponse.routes {
        self.mapView.addOverlay(route.polyline)
        self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
      }
      
      if disabledMode { self.speaker.textToSpeech("I will now take you to \(merchant.name). Shake your device for further instructions.") }
    }
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
    renderer.strokeColor = UIColor.blue
    return renderer
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if !disabledMode { return }
    
    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { [unowned self] in
      if self.directionCount == self.directionInstructions.count {
        self.speaker.textToSpeech("You have arrived. Start shopping.")
      
        DispatchQueue.main.sync {
          self.tabBarController?.selectedIndex = 2
        }
      
        return
      }

      self.speaker.textToSpeech(self.directionInstructions[self.directionCount])
      self.directionCount += 1
    }
  }


}

