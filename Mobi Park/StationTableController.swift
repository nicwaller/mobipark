//
//  FirstViewController.swift
//  Mobi Park
//
//  Created by Nic Waller on 2018-09-11.
//  Copyright © 2018 Nic Waller. All rights reserved.
//

import UIKit

class StationTableController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var stationTableView: UITableView!
    
    var stationList: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadStations()
        setupTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadStations() {
        let url = URL(string: "https://vancouver-ca.smoove.pro/api-public/stations")!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                if let result = jsonResponse["result"] as? [[String: Any]] {
                    self.stationList = result
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
        return stationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stationTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let station: [String: Any] = stationList[indexPath.row] {
//            print(station)
            cell.textLabel?.text = station["name"] as? String
        } else {
            cell.textLabel?.text = String(indexPath.row) + " Error"
        }
        return cell
    }


}

