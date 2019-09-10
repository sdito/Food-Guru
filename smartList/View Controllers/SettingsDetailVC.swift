//
//  SettingsDetailVC.swift
//  smartList
//
//  Created by Steven Dito on 9/9/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit

class SettingsDetailVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var setting: Setting.SettingName?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .lightGray
    }
    func returnCells(setting: Setting.SettingName) -> [UITableViewCell] {
        switch setting {
        case .account:
            return [UITableViewCell()]
        case .about:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "settingBasicCell") as! SettingBasicCell
            cell1.setUI(str: "This is for the about cell")
            return [cell1]
        case .contact:
            return [UITableViewCell()]
        case .darkMode:
            return [UITableViewCell()]
        case .group:
            return [UITableViewCell()]
        case .textSize:
            return [UITableViewCell()]
        case .notifications:
            return [UITableViewCell()]
        case .licences:
            return [UITableViewCell()]
        }
    }
    

}

extension SettingsDetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return returnCells(setting: setting!).count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return returnCells(setting: setting!)[indexPath.row]
    }
    
}
