//
//  ViewController.swift
//  PixelCity
//
//  Created by Shane Bersiek on 4/22/19.
//  Copyright © 2019 Shane Bersiek. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import MapKit
import CoreLocation


class MapVC: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView? //needs UICollectionViewFlowLayOut too

    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    var screenSize = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        registerForPreviewing(with: self, sourceView: collectionView!)
        pullUpView.addSubview(collectionView!)
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    @objc func animateViewDown() {
        cancelAllSessions()
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        pullUpView.addSubview(spinner!)
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 100, y: 175, width: 200, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 14)
        progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
        
    }
    
    func removeProgressLbl() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }
    
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func centerMapBtnPressed(_ sender: UIButton) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }

    
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool)-> ()){
        Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            
            for photo in photosDictArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!).jpg"
                self.imageUrlArray.append(postUrl)
            }
            handler(true)
        }
    }
    
    func retrieveImages(handler: @escaping(_ status: Bool) -> ()) {
        for url in imageUrlArray {
            Alamofire.request(url).responseImage { (response) in
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true) //this is how we know we're done
                }
            }
        }
    }
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            // $0 is a placeholder. SessionDataTask is an array and we can use the $0 as a placeholder for the value. It's a closure that's doing a for-in loop
            downloadData.forEach({ $0.cancel()})
        }
    }
    
}

/*
 **
 EXTENSIONS
 ***
 */
extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = DroppablePin.init(coordinate: touchCoordinate, identifier: "droppablePin")
        
        removePin()
        removeSpinner()
        removeProgressLbl()
        cancelAllSessions()
        
        imageUrlArray = []
        imageArray = []
        
        collectionView?.reloadData()
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
      
        retrieveUrls(forAnnotation: annotation) { (finished) in
            if finished == true {
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        // reload the collectionView with all the images we just downloaded
                        self.collectionView?.reloadData()
                        
                    }
                })
            }
        }
    }
    
    
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}


/* ----------------------UI COLLECTION VIEW----------------------
----------------------------------------------------------------- */
extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // WE want to return the number of images in the array
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell() }
        // It starts at the index of 0 as it iterates over all the rows in the indexPath.
        let imageFromIndex = imageArray[indexPath.row]
        
        // We append imageFromIndex, then add that to our subview, then return that cell so it shows up in our collection view.
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        // Configure the cell
        return cell
    }
    
    // This method is called when one of the cells is tapped
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // We can access the index path - our cells are setup by pulling out the images at the indexPath for every row of our photos
        // We can get the specific photo we want by tapping on it and pulling it from our image array
        // 1. First we create an instance of popVC, then we call our initData() and pass it the image from our image array and then present it
        // And that all happens when you select an item from the index path
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopVC else { return }
        popVC.initData(forImage: imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
}

// Here we are conforming to the UIViewControllerPreviewingDelegate.
extension MapVC: UIViewControllerPreviewingDelegate {
    // These are part of previewing context and of course for 3D touch, it needs to know the context of what you're trying to present,
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Where we are pressing on our cell so that it knows where to animate from. create a context to hold the indexPath and a cell from that indexpath so we can access the photo value, the image from that cell
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
        
        //Create an instance of PopVC cause that will be showing up. When you tap all the way through, this will show
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopVC else { return nil }
        
        popVC.initData(forImage: imageArray[indexPath.row])
        
        // We're giong to setup the size that is previewed when e push on the view controller. The sourceRect is a rectangle that will zoom up as the preview
        previewingContext.sourceRect = cell.contentView.frame
        
        return popVC
    }
    
    // This is the peak part of the 3D touch function where you push a little bit and see a peek of what you're looking at.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        //Tell it which view controller for it to commit
        show(viewControllerToCommit, sender: self)
    }
}






