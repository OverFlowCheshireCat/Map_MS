import UIKit
import MapKit
import CoreLocation

class OneMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    public static var intentTitle = "동의과학대학교"
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        let datas = NSArray(contentsOfFile: Bundle.main.path(forResource: "data", ofType: "plist")!)
        
        if let dataList = datas {
            for data in dataList {
                let title = (data as AnyObject).value(forKey: "title") as! String
                let address = (data as AnyObject).value(forKey: "address") as! String
                
                let geoCoder = CLGeocoder()
                
                geoCoder.geocodeAddressString(address, completionHandler: { (placemarks: [CLPlacemark]?, error: Error?) in
                    if error != nil {
                        return
                    }
                    
                    if let placemarkList = placemarks {
                        let latitude = placemarkList.first?.location?.coordinate.latitude
                        let longitude = placemarkList.first?.location?.coordinate.longitude
                        
                        let geoCoderR = CLGeocoder()
                        
                        geoCoderR.reverseGeocodeLocation(CLLocation(latitude: latitude!, longitude: longitude!), completionHandler: { (placemarksR: [CLPlacemark]?, errorR: Error?) in
                            if errorR != nil {
                                return
                            }
                            
                            if let placemarkListR = placemarksR {
                                if (title != OneMapViewController.intentTitle) {
                                    return
                                }
                                
                                let country = placemarkListR.first?.country ?? "Empty"
                                let administrativeArea = placemarkListR.first?.administrativeArea ?? "Empty"
                                let locality = placemarkListR.first?.locality ?? "Empty"
                                let name = placemarkListR.first?.name ?? "Empty"
                                
                                let subtitle = address + " (" + country + " " + administrativeArea + " " + locality + " " + name + ")"
                                
                                let viewPoint = ViewPoint(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), title: title, subtitle: subtitle)
                                
                                self.mapView.addAnnotation(viewPoint)
                                    
                                self.mapView.mapType = MKMapType.standard
                                
                                return
                            }
                        })
                    } else {
                        return
                    }
                })
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation: CLLocation = locations[locations.count - 1]
        
        animateMap(lastLocation)
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Annotation"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            let title = annotation.title
            
            var imageData: String?
            var imageFrame: CGRect?
            
            if (title != "My Location") {
                if title == "동의과학대학교" {
                    imageData = "DIT.jpg"
                    imageFrame = CGRect(x: 0, y: 0, width: 120, height: 30)
                } else if title == "부산시민공원" {
                    imageData = "BCP.jpg"
                    imageFrame = CGRect(x: 0, y: 0, width: 100, height: 30)
                } else if title == "롯데호텔 부산본점" {
                    imageData = "BLH.jpg"
                    imageFrame = CGRect(x: 0, y: 0, width: 30, height: 30)
                }
                
                annotationView = makeAnnotationView(annotation, imageData: imageData!, imageFrame: imageFrame!, identifier: identifier) as? MKPinAnnotationView
            }
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control.state.rawValue == 1) {
            let alert = UIAlertController(title: view.annotation?.title!, message: view.annotation?.subtitle!, preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "확인", style: .destructive)
            
            alert.addAction(okAction)
            
            present(alert, animated: false, completion: nil)
        }
    }
    
    func animateMap(_ location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        
        mapView.setRegion(region, animated: true)
    }
    
    func makeAnnotationView(_ annotation: MKAnnotation, imageData: String, imageFrame: CGRect, identifier: String) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        let img = UIImageView(image: UIImage(named: imageData))
        
        img.frame = imageFrame
        
        annotationView.canShowCallout = true
        annotationView.animatesDrop = true
        annotationView.leftCalloutAccessoryView = img
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return annotationView
    }
}
