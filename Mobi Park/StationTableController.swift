//
//  FirstViewController.swift
//  Mobi Park
//
//  Created by Nic Waller on 2018-09-11.
//  Copyright © 2018 Nic Waller. All rights reserved.
//

import UIKit

class StationTableController: UIViewController {

    @IBOutlet weak var stationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStations()
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
        }
        task.resume()
    }


}

