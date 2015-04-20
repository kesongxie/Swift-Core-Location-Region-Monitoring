//
//  ViewController.swift
//  Location
//
//  Created by Xie kesong on 2/2/15.
//  Copyright (c) 2015 ___kesong___. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit //for the map to be displayed

class ViewController: UIViewController, CLLocationManagerDelegate {
    var manager: CLLocationManager?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var address: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CLLocationManager()
        manager?.delegate = self //Assign a custom object to the delegate property. This object must conform to the CLLocationManagerDelegate protocol
        manager?.desiredAccuracy = kCLLocationAccuracyBest
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //dispose of any resources that can be recreated
    }
    
    @IBAction func getLocation(sender: AnyObject){
        //let availabe  = CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)
        manager?.requestWhenInUseAuthorization()
    }
    
    @IBAction func regionMonitoring(sender: AnyObject){
        manager?.requestAlwaysAuthorization()
        let  curRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude:40.6105000, longitude: -73.9835900),radius:200, identifier:"home") //set a region
        manager?.startMonitoringForRegion(curRegion) //delegate method didEnterRegion or didExitRegion would fire based upon the current location
        
    }
    
    //whenever the authorzation status changes, this event would be fired
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println(status.rawValue)
        if status == .AuthorizedWhenInUse || status == .Authorized {
            manager?.startUpdatingLocation()
            NSLog("Authorized")
        }
        else{
            NSLog("Never trust this bastard")
        }
        
        switch CLLocationManager.authorizationStatus() {
        
        case .Authorized: //when they want to get the push notification in the background
            //region monitoring
            manager?.startUpdatingLocation()
        case .NotDetermined:
            manager.requestAlwaysAuthorization()
        case .AuthorizedWhenInUse, .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to be notified about adorable kittens near you, please open this app's settings and set location access to 'Always'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        manager.stopUpdatingLocation()
        let location = locations[0] as CLLocation
        let geoCoder = CLGeocoder()
        //convert cooridinate location to user friendly location
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (data, error) -> Void in
            let placeMarks = data as [CLPlacemark]
            let loc: CLPlacemark = placeMarks[0]
            
            self.mapView.centerCoordinate = location.coordinate
            let addr = loc.locality
            let postCode = loc.postalCode
            
            self.address.text = addr
            println(addr+" "+postCode)
            let reg = MKCoordinateRegionMakeWithDistance(location.coordinate, 50, 50)
            self.mapView.setRegion(reg, animated: true)
            self.mapView.showsUserLocation = true
        })
    }
   
    
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        NSLog("Entering region")
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        NSLog("Exit region")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("\(error)")
    }
    
    
    


}