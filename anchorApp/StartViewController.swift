import UIKit
import MapKit
import CoreLocation
import CoreData


class StartViewController:UIViewController{
 
    @IBOutlet var regionButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var radiusLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var minusButton: UIButton!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var quitButton: UIButton!
    @IBOutlet var saveQuitButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var circleImage: UIImageView!
    @IBOutlet var openButton: UIButton!
    @IBOutlet var myView: UIView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    
    
    let tableView = UITableView()
    let locationManager = CLLocationManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var showMenu = false
    var userLatitute = Double()
    var userLongitute = Double()
    var time = Timer()
    var date : String = ""
    var hour : String = ""
    var pinDate : String = ""
    var pinHour : String = ""

    var timer : Timer?
    var counter : Int = 1
    
    override func viewDidLoad()
    {
        saveQuitButton.isEnabled = false
        saveQuitButton.isHidden = true
        quitButton.isEnabled = false
        quitButton.isHidden = true
        stopButton.isEnabled = false
        stopButton.isHidden = true
        startButton.isEnabled = false
        myView.isHidden = true
        closeButton.isEnabled = false
        closeButton.isHidden = true
        plusButton.isEnabled = false
        minusButton.isEnabled = false
        addCustomPin()
        
        let radiusValue = Int(radiusLabel.text!)!
        UserDefaults.standard.set(radiusValue, forKey: "radius")
        radiusLabel.text = String(radiusValue)
        
        time = Timer.scheduledTimer(timeInterval: 1, target: self, selector: Selector("timeUpload"), userInfo: nil, repeats: true)
      
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in }
        showUserLocation()
        //addCustomPin()
       
    }
    
    @objc func timeUpload(){
        let dateFormat = DateFormatter()
        let hourFormat = DateFormatter()
        
        dateFormat.dateStyle = .long
        hourFormat.dateStyle = .long
        
       // date = dateFormat.string(from: Date())
       // hour = hourFormat.string(from: Date())
    }
    
    func saveTime() {
        let dateData = date
        let hourData = hour
     
        let entity = NSEntityDescription.entity(forEntityName: "Time", in: context)!
        let time = NSManagedObject(entity: entity, insertInto: context)
        time.setValue(dateData, forKey: "date")
        time.setValue(hourData, forKey: "hour")
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        saveData()
    }
    
    func getTime(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Time")
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let date = result.value(forKey: "date") as? String {
                        pinDate = date
                        
                        if let hour = result.value(forKey: "hour") as? String{
                            pinHour = hour
                             
                        }
                    }
                }
            }
        }catch{
            print("error")
        }
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
        getTime()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLocation")
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let latitude = result.value(forKey: "latitude") as? Double {
                        userLatitute = latitude
                        
                        if let longitude = result.value(forKey: "longitude") as? Double{
                            userLongitute = longitude
                            
                            let annotation = MKPointAnnotation()
                            annotation.title = pinDate
                            annotation.subtitle = "tıklandı"
                            let coordinate = CLLocationCoordinate2D(latitude: userLatitute, longitude: userLongitute)
                            annotation.coordinate = coordinate
                            mapView.addAnnotation(annotation)
                            
                        }
                    }
                }
            }
        }catch{
            print("error")
        }
       
    }
    
    
    func makeRegion()
    {
        let latitude = mapView.userLocation.coordinate.latitude
        let longitude = mapView.userLocation.coordinate.longitude
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude )
        
        let userDefaults = UserDefaults()
        let radius = userDefaults.object(forKey: "radius")
        let region = CLCircularRegion(center: coordinate, radius: radius as! CLLocationDistance, identifier: "geofence")
        mapView.removeOverlays(mapView.overlays)
        locationManager.startMonitoring(for: region)
        let circle = MKCircle(center: coordinate, radius: region.radius)
        mapView.addOverlay(circle)
        
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)), animated: false)
        mapView.delegate = self
        
    }
    
    func deleteRegion(){
        let latitude = mapView.userLocation.coordinate.latitude
        let longitude = mapView.userLocation.coordinate.longitude
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude )
        
        let userDefaults = UserDefaults()
        let radius = userDefaults.object(forKey: "radius")
        let region = CLCircularRegion(center: coordinate, radius: radius as! CLLocationDistance, identifier: "geofence")
        mapView.removeOverlays(mapView.overlays)
        locationManager.stopMonitoring(for: region)
        let circle = MKCircle(center: coordinate, radius: 0)
        mapView.addOverlay(circle)
        
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)), animated: false)
        mapView.delegate = self
    }
  
    func saveLocation()
    {
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
    func goToBeginning(){
        stopButton.isEnabled = false
        stopButton.isHidden = true
        saveQuitButton.isEnabled = false
        saveQuitButton.isHidden = true
        quitButton.isEnabled = false
        quitButton.isHidden = true
        circleImage.isHidden = false
        startButton.isEnabled = true
        startButton.isHidden = false
        radiusLabel.isHidden = false
        radiusLabel.text = "20"
        plusButton.isEnabled = false
        plusButton.isHidden = false
        minusButton.isEnabled = false
        minusButton.isHidden = false
        regionButton.isEnabled = true
        regionButton.isHidden = false
        
        deleteRegion()
    }
    func goToSaveQuit(){
        stopButton.isEnabled = false
        stopButton.isHidden = true
        saveQuitButton.isEnabled = true
        saveQuitButton.isHidden = false
        quitButton.isEnabled = true
        quitButton.isHidden = false
        circleImage.isHidden = true
        
        deleteRegion()
    }
    @IBAction func regionButton(_ sender: Any)
    {
        makeRegion()
        startButton.isEnabled = true
        regionButton.isHidden = true
        regionButton.isEnabled = false
        plusButton.isEnabled = true
        minusButton.isEnabled = true
    }
  
    @IBAction func startButtonClicked(_ sender: Any)
    {
        startButton.isEnabled = false
        startButton.isHidden = true
        stopButton.isEnabled = true
        stopButton.isHidden = false
        plusButton.isEnabled = false
        plusButton.isHidden = true
        minusButton.isEnabled = false
        minusButton.isHidden = true
        radiusLabel.isHidden = true
        
        saveLocation()
        
    }
    
    @IBAction func plusButtonClicked(_ sender: Any)
    {
        makeRegion()
        var radiusValue = Int(radiusLabel.text!)!
        radiusValue = radiusValue + 1
        UserDefaults.standard.set(radiusValue, forKey: "radius")
        radiusLabel.text = String(radiusValue)
    }
    
    
    @IBAction func minusButtonClicked(_ sender: Any) {
        makeRegion()
        var radiusValue = Int(radiusLabel.text!)!
        if radiusValue > 0{
            radiusValue = radiusValue - 1
            UserDefaults.standard.set(radiusValue, forKey: "radius")
            radiusLabel.text = String(radiusValue)
        }
       
    }
   
    @IBAction func stopButtonClicked(_ sender: Any) {
        stopButton.isEnabled = false
        stopButton.isHidden = true
        saveQuitButton.isEnabled = true
        saveQuitButton.isHidden = false
        quitButton.isEnabled = true
        quitButton.isHidden = false
        circleImage.isHidden = true
    }
    @IBAction func saveQuitButtonClicked(_ sender: Any) {
        saveLocation()
        goToBeginning()
        addCustomPin()
        saveTime()
        
    }
    
    @IBAction func quitButtonClicked(_ sender: Any) {
        goToBeginning()
    }
    
    
    @IBAction func openButtonClicked(_ sender: Any) {
       
        if (!showMenu){
            
            openButton.isEnabled = false
            openButton.isHidden = true
            closeButton.isEnabled = true
            closeButton.isHidden = false
            
            myView.isHidden = false
            myView.layer.cornerRadius = 10
           
        }
        showMenu = !showMenu
   
        getWeatherData()
    }
    @IBAction func closeButtonClicked(_ sender: Any) {
            
            if (showMenu){
                closeButton.isEnabled = false
                closeButton.isHidden = true
                openButton.isEnabled = true
                openButton.isHidden = false
                myView.isHidden = true
                
            }
       
           showMenu = !showMenu
        }
    
    func getWeatherData(){
        let latitude = mapView.userLocation.coordinate.latitude
        let longitude = mapView.userLocation.coordinate.longitude
            
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=af0b2d706c74365c3ec361454ba15cd9")
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { data, response, error in
            if error != nil{
                print("error")
                
            }else{
                if data != nil{
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any]
                      
                        DispatchQueue.main.async {
                            if let main = jsonResponse!["main"] as? [String:Any]{
                                if let temp = main["temp"] as? Double{
                                    self.tempLabel.text = String(Int(temp-272.15)) + " C"
                                }
                                
                            }
                            
                            if let wind = jsonResponse!["wind"] as? [String:Any]{
                                if let speed = wind["speed"] as? Double{
                                    self.speedLabel.text = String(Int(speed)) + " knot"
                                }
                            }
                            
                            if let wind = jsonResponse!["wind"] as? [String:Any]{
                                if let deg = wind["deg"] as? Double{
                                    var result:String
                                    if 0<deg && deg<10{
                                        result = "N"
                                    }
                                    else if 11<deg && deg<79{
                                        result = "NE"
                                    }
                                    else if 80<deg && deg<100{
                                        result = "E"
                                    }
                                    else if 101<deg && deg<169{
                                        result = "SE"
                                    }
                                    else if 170<deg && deg<190{
                                        result = "S"
                                    }
                                    else if 191<deg && deg<259{
                                        result = "SW"
                                    }
                                    else if 260<deg && deg<280{
                                        result = "W"
                                    }
                                    else if 281<deg && deg<349{
                                        result = "NW"
                                    }
                                    else {
                                        result = "N"
                                    }
                                    
                                self.directionLabel.text = result
                                   }
                                    
                                }
                            }
                        
                    }catch{
                    
                    }
                }
            }
    }
        task.resume()
}


   
    func showAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let finishAction = UIAlertAction(title: "Finish", style: .default) { UIAlertAction in
            self.goToSaveQuit()
        }
        let delayAction = UIAlertAction(title: "Delay", style: .default) { UIAlertAction in
            self.Delay()
        }
        
        alert.addAction(finishAction)
        alert.addAction(delayAction)
        present(alert, animated: true, completion: nil)
    }
    func Delay(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Counter), userInfo: nil, repeats: true)
    }
    
    @objc func Counter(){
        counter = counter+1
        //300 sn
        if counter > 6{
            print("Time is over.")
            showAlert(title: "Alert", message: "You Left the Region")
            timer?.invalidate()
        
        }
        
    }
    func showNotification(title: String, message: String)
    {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.badge = 1
        content.sound = .default
        let request = UNNotificationRequest(identifier: "notif", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = .init(named: "navyBlue")
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

extension StartViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation:CLLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        let field = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
        let region = MKCoordinateRegion(center: field, span: span)
        mapView.setRegion(region, animated: true)
    }
 
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)
    {
        let title = "Alert"
        let message = "You Left the Region"
        showAlert(title: title, message: message)
        showNotification(title: title, message: message)
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        timer?.invalidate()
    }
}

