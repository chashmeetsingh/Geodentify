//
//  MapViewController.swift
//  Geodentify
//
//  Created by Y50-70 on 13/09/16.
//  Copyright © 2016 Chashmeet Singh. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var signoutButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addPin: UIBarButtonItem!

    var location: CLLocation!
    let locationManager = CLLocationManager()
    var appDelegate: AppDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        askForLocationPermission()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchUsersList()
        hidesBottomBarWhenPushed = true
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeAllAnnotations()
        hidesBottomBarWhenPushed = false
    }

    func removeAllAnnotations() {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
    }

    private func askForLocationPermission() {
        self.locationManager.delegate = self
        self.mapView.delegate = self

        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        self.locationManager.requestWhenInUseAuthorization()

        self.locationManager.startUpdatingLocation()
    }

    private func fetchUsersList() {
        toggle()
        activityIndicator.startAnimating()
        UdacityClient.sharedInstance().fetchUsersList(self, completionHandlerForUserList: { (userList, error) in
            performUIUpdatesOnMain({
                if let userList = userList {
                    SaveStudent.sharedInstance().setStudentData(userList)
                    self.dropPins(userList)
                    self.getCurrentUserData()
                } else {
                    let alert = UIAlertController(title: "Error downloading user data", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
                self.toggle()
                self.activityIndicator.stopAnimating()
            })
        })
    }

    func dropPins(users: [UdacityUser]) {
        for user in users {
            let coordinates = CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = user.firstName
            annotation.subtitle = user.mediaURL
            mapView.addAnnotation(annotation)
        }
    }

    @IBAction func signoutUser(sender: AnyObject) {
        toggle()
        activityIndicator.startAnimating()
        UdacityClient.sharedInstance().logOutUser(self, completionHandlerForUserSignOut: { (success, error) in
            performUIUpdatesOnMain({
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.activityIndicator.stopAnimating()
                    self.toggle()
                } else {
                    let alert = UIAlertController(title: "Parse Network Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            })
        })
    }

    func getCurrentUserData() {
        UdacityClient.sharedInstance().getCurrentUserData(self, completionHandlerForCurrentUser: { (success, error, user) in
            if success {
                self.appDelegate.currentUser = user
            } else {
                let alert = UIAlertController(title: "Error downloading data", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        })
    }

    func toggle() {
        mapView.userInteractionEnabled = !mapView.userInteractionEnabled
        signoutButton.enabled = !signoutButton.enabled
        addPin.enabled = !addPin.enabled
    }

    @IBAction func reloadData(sender: AnyObject) {

        getCurrentUserData()
    }
}

extension MapViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last

        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)

        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100))

        self.mapView.setRegion(region, animated: true)

        self.locationManager.stopUpdatingLocation()

    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .AuthorizedAlways)
    }
}

extension MapViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is MKUserLocation {
            return nil
        }

        let reuseId = "pin"
        let  pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView.canShowCallout = true
        let detailBtn = UIButton(type: .DetailDisclosure)
        pinView.rightCalloutAccessoryView = detailBtn
        return pinView
    }

    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let view = view.annotation {
            UIApplication.sharedApplication().openURL(NSURL(string: view.subtitle!!)!)
        }
    }
}
