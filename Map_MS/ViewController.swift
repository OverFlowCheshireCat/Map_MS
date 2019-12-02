import UIKit
import MapKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    //public static var data =
    
    var titles = Array<String>()
    var addresses = Array<String>()
    
    /*@IBAction func oneMap(sender: UITableViewCell) {
        self.performSegue(withIdentifier: "oneMap", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "oneMap" {
            let oneMap = segue.destination as! OneMapViewController
            
            oneMap.intentTitle =
        }
    }*/
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Start Of Data"
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "End Of Data"
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Re", for: indexPath)
        let row = indexPath.row
        
        cell.textLabel?.text = titles[row]
        cell.detailTextLabel?.text = addresses[row]
        cell.imageView?.image = UIImage(named: titles[row])
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        OneMapViewController.intentTitle = cell?.textLabel?.text ?? "동의과학대교교"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        var annotation = Array<MKAnnotation>()
        
        let datas = NSArray(contentsOfFile: Bundle.main.path(forResource: "data", ofType: "plist")!)
        
        if let dataList = datas {
            for data in dataList {
                let title = (data as AnyObject).value(forKey: "title") as! String
                let address = (data as AnyObject).value(forKey: "address") as! String
                
                titles.append(title)
                addresses.append(address)
                
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
                                let country = placemarkListR.first?.country ?? "Empty"
                                let administrativeArea = placemarkListR.first?.administrativeArea ?? "Empty"
                                let locality = placemarkListR.first?.locality ?? "Empty"
                                let name = placemarkListR.first?.name ?? "Empty"
                                
                                let subtitle = address + " (" + country + " " + administrativeArea + " " + locality + " " + name + ")"
                                
                                let viewPoint = ViewPoint(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), title: title, subtitle: subtitle)
                                
                                annotation.append(viewPoint)
                                
                                /*if (annotation.count == dataList.count) {
                                 self.mapView.showAnnotations(annotation, animated: true)
                                 
                                 self.mapView.mapType = MKMapType.hybrid
                                 self.setEnables(hybrid: false, standard: true, satellite: true)
                                 }*/
                            }
                        })
                    } else {
                        return
                    }
                })
            }
        }
    }
}
