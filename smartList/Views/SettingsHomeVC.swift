  
  //
  //  SettingsHomeVC.swift
  //  smartList
  //
  //  Created by Steven Dito on 9/5/19.
  //  Copyright © 2019 Steven Dito. All rights reserved.
  //
  import UIKit
  
  class SettingsHomeVC: UIViewController {
    private var sections: [String] = []
    private var cells: [[Setting]] = []
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        (sections, cells) = Setting.createSettings()
        tableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingDetail" {
            let destVC = segue.destination as! SettingsDetailVC
            destVC.setting = sender as? Setting.SettingName
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        tableView.visibleCells.forEach { (cell) in
            cell.isSelected = false
        }
    }
    
}
  
extension SettingsHomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = cells[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SettingCell
        cell.setUI(setting: setting)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = cells[indexPath.section][indexPath.row].settingName
        performSegue(withIdentifier: "settingDetail", sender: setting)
        
    }
    
}
