//
//  FirstViewController.swift
//  Mobi Park
//
//  Created by Nic Waller on 2018-09-11.
//  Copyright © 2018 Nic Waller. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class StationTableController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var stationTableView: UITableView!
    
//    Raw data downloaded from API
    var stationList: [[String: Any]] = []
    
//    Clean, structured, ordered data refreshed periodically
    var nearbyStationList: [NearbyStation] = []
    struct NearbyStation {
        var name: String
        var location: CLLocation
        var distance: CLLocationDistance // recalculated from location
        var total_slots: Int
        var free_slots: Int
        var available_bikes: Int
        var operative: Bool
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStations()
        setupTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let f: MKDistanceFormatter = MKDistanceFormatter()
    
    func recalculateDistances() {
        let myLocation: CLLocation = CLLocation(latitude: 49.28292, longitude: -123.1154539)
        //        what is my current location actually? TODO: remove this
        
        for (var element) in nearbyStationList {
            element.distance = element.location.distance(from: myLocation)
        }
        nearbyStationList.sort(by: { $0.distance < $1.distance })
    }
    
    func loadStations() {
        let url = URL(string: "https://vancouver-ca.smoove.pro/api-public/stations")!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                if let result = jsonResponse["result"] as? [[String: Any]] {
//                    self.stationList = result
                    let downtown: CLLocation = CLLocation(latitude: 49.28292, longitude: -123.1154539)
                    for (element) in result {
                        let name: String = element["name"] as! String
                        let coordinates: String = element["coordinates"] as! String
                        let coord_parts: [String] = coordinates.components(separatedBy: ",")
                        let latitude: Double? = Double(coord_parts[0].trimmingCharacters(in: .whitespacesAndNewlines))
                        let longitude: Double? = Double(coord_parts[1].trimmingCharacters(in: .whitespacesAndNewlines))
                        let location: CLLocation = CLLocation(latitude: latitude!, longitude: longitude!)
                        let distance: CLLocationDistance = location.distance(from: downtown)
                        let total_slots: Int = element["total_slots"] as! Int
                        let free_slots: Int = element["free_slots"] as! Int
                        let available_bikes: Int = element["avl_bikes"] as! Int
                        let operative: Bool = element["operative"] as! Bool

                        let station = NearbyStation(name: name, location: location, distance: distance, total_slots: total_slots, free_slots: free_slots, available_bikes: available_bikes, operative: operative)
                        
                        // If the station is more than 1 km away, that's too far
                        if distance > CLLocationDistance(1000) {
                            continue
                        }
                        self.nearbyStationList.append(station)
                    }
                    self.recalculateDistances()
                    DispatchQueue.main.async {
                        self.stationTableView.reloadData()
                    }
                }
            } catch {
                
            }
        }
        task.resume()
    }
    
    func setupTable() {
        stationTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nearby Stations"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyStationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stationTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let station = nearbyStationList[indexPath.row]
        cell.textLabel?.text = station.name + " -- " + f.string(fromDistance: station.distance)
        return cell
    }


}

