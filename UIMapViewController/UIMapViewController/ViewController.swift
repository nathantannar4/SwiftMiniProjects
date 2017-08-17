//
//  ViewController.swift
//  UIMapViewController
//
//  Created by Nathan Tannar on 8/12/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIMapViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longHoldGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPin(_:)))
        mapView.addGestureRecognizer(longHoldGesture)
    }

    func addPin(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        let mapAnnotation = MapAnnotation(title: "Title", subtitle: "Subtitle", object: mapView.annotations.count as AnyObject, coordinate: coordinate)
        mapView.addAnnotation(mapAnnotation)
    }
    
    override func mapView(_ mapView: MKMapView, didSelectDetailDisclosureFor view: MapAnnotationView) {
        let alert = UIAlertController(title: "Object Value", message: String(describing: view.object), preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Dismiss", style: .destructive, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}

