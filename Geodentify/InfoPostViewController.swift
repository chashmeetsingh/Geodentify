
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
        self.navigationController?.toolbar.hidden = true
        textField.delegate = self

        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.toolbar.hidden = false
    }

    @IBAction func cancel(sender: AnyObject) {
        print("cancel")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func findOnMap(sender: AnyObject) {
        getLocation()
    }

    func getLocation() {
        start(true)
        if textField.text!.isEmpty {
            let alert = UIAlertController(title: "Empty location error", message: "Please enter a location", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            start(false)
        } else {
            self.locationString = self.textField.text
            self.geocoder.geocodeAddressString(self.locationString!,completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if (placemarks?.count > 0) {
                    let topResult: CLPlacemark = (placemarks?[0])!
                    let placemark: MKPlacemark = MKPlacemark(placemark: topResult)
                    var region: MKCoordinateRegion = self.mapView.region

                    region.center.latitude = (placemark.location?.coordinate.latitude)!
                    region.center.longitude = (placemark.location?.coordinate.longitude)!

                    region.span = MKCoordinateSpanMake(0.5, 0.5)
                    performUIUpdatesOnMain({
                        self.mapView.setRegion(region, animated: true)

                        let coordinates = CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinates
                        annotation.title = self.locationString
                        self.mapView.addAnnotation(annotation)
                    })
                    self.location = placemark.location

                    self.getLinkToShare()
                } else {
                    let alert = UIAlertController(title: "Location not found error", message: "Please try a different location", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                self.start(false)
            })
        }
    }

    func getLinkToShare() {
        self.textField.text = ""
        self.titleLabel.text = "Enter your link here"
        self.textField.placeholder = "http://yourLink.here"

        findOnMapButton.removeFromSuperview()
        submitButton.addTarget(self, action: #selector(submit), forControlEvents: .TouchUpInside)
    }

    func submit() {
        start(true)
        if verifyUrl(textField.text) {
            let latitude = self.location.coordinate.latitude
            let longitude = self.location.coordinate.longitude
            var json = "{\"uniqueKey\": \"" + self.appDelegate.currentUser.id + "\", \"firstName\": \"" + self.appDelegate.currentUser.firstName + "\", \"lastName\": \""
            json += self.appDelegate.currentUser.lastName + "\",\"mapString\": \"" + self.locationString + "\", \"mediaURL\": \"" + self.textField.text!
            json += "\",\"latitude\": \(latitude)," + " \"longitude\": \(longitude)}"

            UdacityClient.sharedInstance().postPin(json, hostViewController: self, completionHandlerForPostPin: { (success, error) in
                performUIUpdatesOnMain({
                    if success {
                        print("Successfully posted")
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    } else {
                        let alert = UIAlertController(title: "Parse Network Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.start(false)
                    }
                })
            })
        } else {
            start(false)
            let alert = UIAlertController(title: "Incorrect URL", message: "Please Enter Correct URL", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) in
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func start(status: Bool){
        self.activityIndicator.isAnimating() ? self.activityIndicator.stopAnimating() : self.activityIndicator.startAnimating()
        textField.enabled = !status
        if let button = findOnMapButton {
            button.enabled = !status
        }
        submitButton.enabled = !status
    }

    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }

}

extension InfoPostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
