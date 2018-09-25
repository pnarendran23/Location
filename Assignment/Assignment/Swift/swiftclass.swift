//
//  swiftclass.swift
//  Assignment
//
//  Created by Group X on 25/09/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit
import MapKit

class swiftclass: UIViewController {
    var Tasks = tasks() //Created a global object; ARC doesn't wait until the Location manager's delegate methods are called in the Framework.
    var progress = 0
    var plugged = ""
    var t = Timer(); // To make some incremental effect in the progress view
    //Battery view outlets
    @IBOutlet weak var batteryprogressView: UIProgressView!
    @IBOutlet weak var batteryprogressLabel: UILabel!
    @IBOutlet weak var levelindication: UIImageView!
    @IBOutlet weak var pluggedstatusLabel: UILabel!
    @IBOutlet weak var pluggedstatus: UIImageView!
    @IBOutlet weak var batteryview: UIView!
    
    //spinner - to show during the network call
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //Separate view for mapView to load precised marker on the Map view
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationView: UIView! //Container for the Map view. Added a title called "Current Location" to let the user know what's that marker is for.
    
    @IBOutlet weak var resultLabel: UILabel! // Label that simply shows the weather data
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.isHidden = true
        self.locationView.isHidden = true
        self.batteryview.isHidden = true
        self.resultLabel.isHidden = true
        
        //Post notification is used to send data from the NSObject class. Delegates can also be used to pass data
        NotificationCenter.default.addObserver(self, selector: #selector(receivedCurrentLocation(notification:)), name: NSNotification.Name(rawValue: "currentLocation"), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(receivedWeather(notification:)), name: NSNotification.Name(rawValue: "currentweather"), object: nil);
        
        // Do any additional setup after loading the view.
    }
    
    func receivedCurrentLocation(notification : Notification){
        //This method will be called when a framework receives current location from the delegate method (Post notification)
        let latitude = Double((notification.userInfo!["latitude"] as! String))!
        let longitude = Double((notification.userInfo!["longitude"] as! String))!
        
        let currentLocation = CLLocation.init(latitude: latitude, longitude: longitude)
        
        let marker = MKPointAnnotation()
        marker.coordinate = currentLocation.coordinate
        marker.title = "Current Location";
        marker.subtitle = "Latitude : \(notification.userInfo!["latitude"] as! String) Longitude : \(notification.userInfo!["latitude"] as! String)"
        self.mapView.addAnnotation(marker) // Adds a marker
        
        //Below lines are used to set the zoom level appropriate to the current location
        let viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 500, 500)
        let FittingRegion = self.mapView.regionThatFits(viewRegion)
        self.mapView.setRegion(FittingRegion, animated: true)
        
        
    }
    
    func receivedWeather(notification : Notification){
        //This method will be called when a framework receives current weather information from the network call (Post notification)
        resultLabel.text = "\(notification.userInfo!["weather"] as! String)"
        spinner.isHidden = true
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        //Restores all the views to default.
        spinner.isHidden = true
        self.locationView.isHidden = true
        self.batteryview.isHidden = true
        self.resultLabel.isHidden = true
        t.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func location(_ sender: Any) {
        
        Tasks.setForLocation() //Disables a flag in the framework. So, some new method will not be called
        Tasks.getLocation()
        batteryview.isHidden = true
        locationView.isHidden = false
        resultLabel.isHidden = true
        
    }
    
    @IBAction func battery(_ sender: Any) {
        batteryview.isHidden = false
        resultLabel.isHidden = true
        locationView.isHidden = true
        
        t.invalidate()
        progress = 0;
        plugged = "";
        var  a = Tasks.getBattery()! //Returns Location coordinates in the form of Array objects
        //NSLog(@"%@",[c getBattery]);
        let temp = a[0] as! String;
        progress = Int(temp)!;
        plugged = a[1] as! String;
        
        //Below lines are to update the plugged in image used to represent the charging state of the device
        if(plugged.lowercased() == "charging" || plugged.lowercased() == "full"){
            pluggedstatus.image = UIImage.init(named: "plugged");
        }else{
            pluggedstatus.image = UIImage.init(named: "unplugged");
        }
        
        //Below lines are to update the string based on some conditions
        
        if(progress == 0){
            pluggedstatusLabel.text = "Battery is \(plugged) and charge level is empty"
        
        }else if(progress == 100 && (plugged.lowercased() == "charging" || plugged.lowercased() == "full")){
            pluggedstatusLabel.text = "Battery is full and connected to power"
        }else if(progress == 100 && !(plugged.lowercased() == "charging" || plugged.lowercased() == "full")){
            pluggedstatusLabel.text = "Battery is full and not connected to power"
        }else{
            pluggedstatusLabel.text = "Battery is \(plugged) and \(progress)% charge is left"
        }
        
        batteryprogressView.setProgress(0, animated: false)
        //Label is about to increment. So, resetted and appended a percentage at the end.
        batteryprogressLabel.text = "0%"
        t = Timer.scheduledTimer(timeInterval: 0.015, target: self, selector: #selector(progressupdate), userInfo: nil, repeats: true)
                
    }
    
    func progressupdate(){
        //It changes progress values, strings, and the color based on the progress range
        //Changing colors can also be done by addition assignment operator.
        //Dispatch timer can also be used over NSTimer
        
        if(Int(batteryprogressView.progress) < progress/100){
            let toIncrement = batteryprogressView.progress + 0.010
            batteryprogressView.setProgress(toIncrement, animated: true)
            let currentValue = Int(batteryprogressView.progress * 100);
            if(currentValue < 5){
                levelindication.image = UIImage.init(named: "level0")
                batteryprogressView.progressTintColor = UIColor.red
            }else if(currentValue >= 5 && currentValue <= 25 ){
                levelindication.image = UIImage.init(named: "level1")
                batteryprogressView.progressTintColor = UIColor.orange
            }else if(currentValue > 25 && currentValue <= 50){
                levelindication.image = UIImage.init(named: "level2")
                batteryprogressView.progressTintColor = UIColor.orange
            }else if(currentValue > 50 && currentValue <= 90){
                levelindication.image = UIImage.init(named: "level3")
                batteryprogressView.progressTintColor = UIColor.yellow
            }else if(currentValue > 90 && currentValue <= 100){
                levelindication.image = UIImage.init(named: "level4")
                batteryprogressView.progressTintColor = UIColor.green
            }
            batteryprogressLabel.text = "\(Int(batteryprogressView.progress * 100))%"
            
        }
        else{
            //Finally stops the timer
            t.invalidate()
            
        }
    }
    
    @IBAction func weather(_ sender: Any) {
        //Enables a flag in the framework. So, some new method will be called to get the weather information
        resultLabel.text = ""
        spinner.isHidden = false
        resultLabel.textAlignment = .center
        Tasks.setForWeather()
        Tasks.getLocation()
        batteryview.isHidden = true
        resultLabel.isHidden = false
        locationView.isHidden = true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
