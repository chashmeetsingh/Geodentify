
//
//  InfoPostViewController.swift
//  Geodentify
//
//  Created by Y50-70 on 16/09/16.
//  Copyright © 2016 Chashmeet Singh. All rights reserved.
//

import UIKit
import MapKit

class InfoPostViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    let geocoder: CLGeocoder = CLGeocoder()
    var location: CLLocation!
    var appDelegate: AppDelegate!
    var locationString: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.hidden = true
        textField.delegate = self

        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.hidden = false
    }

    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func findOnMap(sender: AnyObject) {
        getLocation()
    }

    func getLocation() {
        start(true)
        dispatch_async(dispatch_get_main_queue(), {
            self.locationString = self.textField.text
            self.geocoder.geocodeAddressString(self.locationString!,completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if (placemarks?.count > 0) {
                    let topResult: CLPlacemark = (placemarks?[0])!
                    let placemark: MKPlacemark = MKPlacemark(placemark: topResult)
                    var region: MKCoordinateRegion = self.mapView.region

                    region.center.latitude = (placemark.location?.coordinate.latitude)!
                    region.center.longitude = (placemark.location?.coordinate.longitude)!

                    region.span = MKCoordinateSpanMake(0.5, 0.5)

                    self.mapView.setRegion(region, animated: true)
                    self.location = placemark.location
                    
                    self.start(false)
                    self.getLinkToShare()
                }
            })
        })
    }

    func getLinkToShare() {
        self.textField.text = ""
        self.titleLabel.text = "Enter link to share"

        findOnMapButton.removeFromSuperview()
        submitButton.addTarget(self, action: #selector(submit), forControlEvents: .TouchUpInside)
    }

    func submit() {
        start(true)
        dispatch_async(dispatch_get_main_queue(), {
            let latitude = self.location.coordinate.latitude
            let longitude = self.location.coordinate.longitude
            var json = "{\"uniqueKey\": \"" + self.appDelegate.currentUser.id + "\", \"firstName\": \"" + self.appDelegate.currentUser.firstName + "\", \"lastName\": \""
            json += self.appDelegate.currentUser.lastName + "\",\"mapString\": \"" + self.locationString + "\", \"mediaURL\": \"" + self.textField.text!
            json += "\",\"latitude\": \(latitude)," + " \"longitude\": \(longitude)}"

            UdacityClient.sharedInstance().postPin(json, hostViewController: self, completionHandlerForPostPin: { (success, error) in
                if success {
                    print("Successfully posted")
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    print(error)
                }
                self.start(false)
            })
        })
    }

    func start(status: Bool){
        self.activityIndicator.isAnimating() ? self.activityIndicator.stopAnimating() : self.activityIndicator.startAnimating()
        textField.enabled = !status
        if let button = findOnMapButton {
            button.enabled = !status
        }
        submitButton.enabled = !status
    }

}

extension InfoPostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
