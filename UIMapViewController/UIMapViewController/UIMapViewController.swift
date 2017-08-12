//
//  UIMapViewController.swift
//  UIMapViewController
//
//  Copyright © 2017 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 8/12/17.
//

import UIKit
import MapKit
import CoreLocation

open class UIMapViewController: UIViewController {
    
    open var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsCompass = true
        mapView.showsUserLocation = true
        mapView.showsBuildings = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isPitchEnabled = true
        return mapView
    }()
    
    open var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    // MARK: - Initialization
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// Called during initialization
    fileprivate func setup() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        _ = [
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor)
        ].map { $0.isActive = true }
    }
    
    // MARK: - Standard Methods
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
}

extension UIMapViewController: MKMapViewDelegate {
    
    // MARK: - MKMapViewDelegate
    
    open func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let reuseIdentifier = "PIN"
        
        var view: MapAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            as? MapAnnotationView {
            dequeuedView.annotation = annotation
            dequeuedView.object = (annotation as? MapAnnotation)?.object
            view = dequeuedView
        } else {
            view = MapAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            view.canShowCallout = true
            //view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
        }
        return view
    }
}

extension UIMapViewController: CLLocationManagerDelegate {
    
    // MARK: - CLLocationManagerDelegate
    
    open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        guard let latitude = location?.coordinate.latitude, let longitude = location?.coordinate.longitude else {
            return
        }
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        _ = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        //        mapView.setRegion(region, animated: true)
    }
    
    open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            // Location services are authorised, track the user.
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            print("Location use authorized")
            
        case .denied, .restricted:
            // Location services not authorised, stop tracking the user.
            locationManager.stopUpdatingLocation()
            mapView.showsUserLocation = false
            print("Location use NOT authorized")
            
        default:
            // Location services pending authorisation.
            // Alert requesting access is visible at this point.
            break
        }
    }
    
    open func centerMapToUser(animated: Bool = true) {
        guard let coordinate = currentLocation() else {
            return
        }
        let latDelta: CLLocationDegrees = 0.02
        let lonDelta: CLLocationDegrees = 0.02
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        mapView.setRegion(region, animated: animated)
    }
    
    open func currentLocation() -> CLLocationCoordinate2D? {
        guard let location = locationManager.location else {
            print("Failed to get the users current location. Was auth given?")
            return nil
        }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        return coordinate
    }

}

open class MapAnnotationView: MKPinAnnotationView {
    
    open weak var object: AnyObject?
    
    // MARK: - Initialization
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        if let object = (annotation as? MapAnnotation)?.object {
            self.object = object
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class MapAnnotation: NSObject, MKAnnotation {
    
    open weak var object: AnyObject?
    open var title: String?
    open var subtitle: String?
    open var coordinate: CLLocationCoordinate2D
    
    // MARK: - Initialization
    
    public required init(coordinate location: CLLocationCoordinate2D) {
        coordinate = location
        super.init()
    }
    
    public convenience init(title: String?, subtitle: String?, object: AnyObject?, coordinate: CLLocationCoordinate2D) {
        self.init(coordinate: coordinate)
        self.title = title
        self.subtitle = subtitle
        self.object = object
    }
}

