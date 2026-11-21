import CoreLocation
import MapKit
import UIKit

final class CampusMapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var distanceLabel: UILabel!

    private let locationManager = CLLocationManager()
    private let campusCoordinate = CLLocationCoordinate2D(latitude: 14.6044, longitude: 120.9889)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Map"
        configureCampusPin()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    private func configureCampusPin() {
        let region = MKCoordinateRegion(
            center: campusCoordinate,
            latitudinalMeters: 1_200,
            longitudinalMeters: 1_200
        )
        mapView.setRegion(region, animated: false)

        let annotation = MKPointAnnotation()
        annotation.coordinate = campusCoordinate
        annotation.title = "FEU Manila"
        mapView.addAnnotation(annotation)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            distanceLabel.text = "Finding your distance from campus…"
            manager.requestLocation()
        case .denied, .restricted:
            distanceLabel.text = "Location access is unavailable. Enable it in Settings to calculate distance."
        case .notDetermined:
            break
        @unknown default:
            distanceLabel.text = "Location status is unavailable."
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        let campusLocation = CLLocation(latitude: campusCoordinate.latitude, longitude: campusCoordinate.longitude)
        let distance = currentLocation.distance(from: campusLocation)
        distanceLabel.text = String(format: "You are approximately %.0f meters from FEU Manila.", distance)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        distanceLabel.text = "Your location could not be determined. Please try again."
        print("Location request failed: \(error.localizedDescription)")
    }
}
