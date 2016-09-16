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
        fetchUsersList()
    }

    private func askForLocationPermission() {
        self.locationManager.delegate = self
        self.mapView.delegate = self

        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        self.locationManager.requestWhenInUseAuthorization()

        self.locationManager.startUpdatingLocation()
    }

    private func fetchUsersList() {
        UdacityClient.sharedInstance().fetchUsersList(self, completionHandlerForUserList: { (userList, error) in
            performUIUpdatesOnMain({
                if let userList = userList {
                    self.appDelegate.users = userList
                    self.dropPins(userList)
                    self.getCurrentUserData()
                } else {
                    print(error)
                }
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
                    print(error)
                }
            })
        })
    }

    func getCurrentUserData() {
        UdacityClient.sharedInstance().getCurrentUserData(self, completionHandlerForCurrentUser: { (success, error, user) in
            if success {
                self.appDelegate.currentUser = user
            }
        })
    }

    func toggle() {
        mapView.userInteractionEnabled = false
        signoutButton.enabled = false
        addPin.enabled = false
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
        pinView.animatesDrop = true
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
