import UIKit
import MapKit
import CoreLocation
import CoreData


class StartViewController:UIViewController,CLLocationManagerDelegate{
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var radiusLabel: UILabel!
    let locationManager = CLLocationManager()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
 
   override func viewDidLoad()
    {
        showUserLocation()
        addCustomPin()
        makeRegion()
    }
    
    func showUserLocation()
    {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    func addCustomPin()
    {
        let latitude = mapView.userLocation.coordinate.latitude
        let longitude = mapView.userLocation.coordinate.longitude
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude )
        
        let pin = MKPointAnnotation()
        pin.title = "You are here"
        pin.subtitle = "Tap button to add area limit"
        pin.coordinate = coordinate
        self.mapView.addAnnotation(pin)
    }
    
    func makeRegion()
    {
        let latitude = mapView.userLocation.coordinate.latitude
        let longitude = mapView.userLocation.coordinate.longitude
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude )
        
        let userDefaults = UserDefaults()
        let radius = userDefaults.object(forKey: "radius")
        let region = CLCircularRegion(center: coordinate, radius: radius as! CLLocationDistance , identifier: "geofence")
        mapView.removeOverlays(mapView.overlays)
        locationManager.startMonitoring(for: region)
        let circle = MKCircle(center: coordinate, radius: region.radius)
        mapView.addOverlay(circle)
        
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: false)
        mapView.delegate = self
        
    }
    
    func saveLocation(){
        let latitude = mapView.userLocation.coordinate.latitude
        let longitude = mapView.userLocation.coordinate.longitude
     
        let entity = NSEntityDescription.entity(forEntityName: "UserLocation", in: context)!
        let location = NSManagedObject(entity: entity, insertInto: context)
        location.setValue(latitude, forKey: "latitude")
        location.setValue(longitude, forKey: "longitude")
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        saveData()
    }
    
    func saveData(){
        do{
            try self.context.save()
        }catch{
            print(error.localizedDescription)
        }
    }

    @IBAction func startButtonClicked(_ sender: Any) {
        saveLocation()
    }
    
    @IBAction func plusButtonClicked(_ sender: Any) {
      
        var radiusValue = Int(radiusLabel.text!)!
        radiusValue = radiusValue+10
      
        UserDefaults.standard.set(radiusValue, forKey: "radius")
        radiusLabel.text = String(radiusValue)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
   
        let userLocation:CLLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        let field = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
        let region = MKCoordinateRegion(center: field, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.badge = 1
        content.sound = .default
        let request = UNNotificationRequest(identifier: "notif", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = .red
        circleRenderer.fillColor = .blue
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
}
extension StartViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        annotationView?.image = UIImage(named: "ship")
        return annotationView
    }
    
}

