//
//  DroppablePin.swift
//  PixelCity
//
//  Created by Shane Bersiek on 4/22/19.
//  Copyright © 2019 Shane Bersiek. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
      init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
