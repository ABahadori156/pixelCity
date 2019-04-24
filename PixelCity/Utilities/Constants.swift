//
//  Constants.swift
//  PixelCity
//
//  Created by Pasha Bahadori on 4/23/19.
//  Copyright © 2019 Shane Bersiek. All rights reserved.
//

import Foundation

let droppablePin = "droppablePin"
let photoCell = "photoCell"
let apiKey = "1f89efd5646a68bdd4c7b7951439cb12"


func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}
