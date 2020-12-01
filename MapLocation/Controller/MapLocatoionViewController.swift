//
//  MapLocatoionViewController.swift
//  MapLocation
//
//  Created by Pawan  on 01/12/2020.
//

import UIKit
import MapKit
import CoreLocation

class customPin: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D) {
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
    }
}
class MapLocatoionViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet weak var streetName: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    //MARK: - Variable
    var latitude21 = 0.00
    var longitutde21 = 0.00
    var long = String()
    var lait = String()
    let anntation = MKPointAnnotation()
    let locationmanager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       viewSetup()
        
    }

    //MARK: - setupView
    func viewSetup() {
        
        checkLocationServices()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        gestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
        map.addGestureRecognizer(gestureRecognizer)
        
//        let cordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(33.6676337538241, 73.05847315695542)
//        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        let region = MKCoordinateRegion(center: cordinate, span: span)
//        self.map.setRegion(region, animated: true)
    }

    //MARK: - Methods
    func setupLocationManager(){
        locationmanager.delegate = self as? CLLocationManagerDelegate
        locationmanager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }else{
            print("not enabled")
        }
    }
    
    //MARK: - Search Button
    @IBAction func Searchbtn(_ sender: UIButton) {
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let activityIndicator = UIActivityIndicatorView()
        
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start {
            (response, Error) in
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil {
                var refreshAlert = UIAlertController(title: "Internet Issue", message: "Please Connect Your Device with Internet", preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in }))
                self.present(refreshAlert, animated: true, completion: nil)
            } else {
                
                let latitude =  response!.boundingRegion.center.latitude
                let longitude = response!.boundingRegion.center.longitude
                
                self.longitutde21 = longitude
                self.latitude21 = latitude
                
                let annotaion = MKPointAnnotation()
                annotaion.title = searchBar.text
                
                annotaion.coordinate =  CLLocationCoordinate2DMake(latitude, longitude)
                self.map.addAnnotation(annotaion)
                
                let cordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: cordinate, span: span)
                self.map.setRegion(region, animated: true)
            }
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus(){
        case .notDetermined:
            locationmanager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //Show an alert the app is restricted
            break
        case .denied:
            //Show an alert instruction them how to turn on permissions
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            map.showsUserLocation = true
            //Do ma stuff
            break
        }
    }
    
    @objc func handleTap(_ gestureReconizer: UILongPressGestureRecognizer) {
        self.long.removeAll()
        self.lait.removeAll()
        
        let touchlocation = gestureReconizer.location(in: map)
        let touchcooords = map.convert(touchlocation, toCoordinateFrom: map)
        
        anntation.title = "Your Location"
        anntation.coordinate = touchcooords
        map.addAnnotation(anntation)
        latitude21 = touchcooords.latitude
        longitutde21 = touchcooords.longitude
        print(latitude21)
        print(longitutde21)
        guard let coordinate = locationmanager.location?.coordinate else { return }
        getCurrentLocationDetail(latitude21: touchcooords.latitude, longitude21: touchcooords.longitude)
        
        let sourceLocation = CLLocationCoordinate2D(latitude:39.173209 , longitude: -94.593933)
        let destinationLocation = CLLocationCoordinate2D(latitude:touchcooords.latitude , longitude: touchcooords.longitude)
        
        
        
    }
    func getCurrentLocationDetail(latitude21: CLLocationDegrees, longitude21: CLLocationDegrees) {
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude21, longitude: longitude21)
        geoCoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error -> Void in
            let placemarksDict = placemarks! as [CLPlacemark]
            
            if placemarksDict.count > 0 {
                let placemarksDict = placemarks![0]
                self.streetName.text = placemarksDict.thoroughfare
                self.cityName.text = placemarksDict.locality
                self.countryName.text = placemarksDict.country
            }
        })
    }
}
//MARK: - CLLocationManagerDelegate
extension MapLocatoionViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) { }
}
