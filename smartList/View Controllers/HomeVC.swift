//
//  HomeVC.swift
//  smartList
//
//  Created by Steven Dito on 8/3/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit


class HomeVC: UIViewController {
    let listsForTesting: [List] = [
        List(name: "List 1", stores: ["Trader Joe's", "Whole Foods"], categories: ["Sweets", "Baking", "Fruit"], people: ["Steven"], items: nil),
        List(name: "Sunday List", stores: ["Target", "Safeway", "Trader Joe's"], categories: ["Dairy", "Veggies", "Grains", "Fruit", "Other"], people: ["Nicole", "Steven", "Anthony"], items: nil),
        List(name: "Steven's List", stores: [ "Safeway", "Trader Joe's"], categories: ["Dairy", "Veggies", "Grains", "Fruit", "Other"], people: ["Nicole", "Steven", "Anthony"], items: nil),
        List(name: "Other List", stores: ["Target", "Safeway", "Trader Joe's"], categories: ["Dairy", "Veggies", "Grains", "Fruit", "Other"], people: ["Nicole", "Steven", "Anthony"], items: nil),
        List(name: "Last List", stores: ["Target", "Safeway", "Trader Joe's"], categories: ["Dairy", "Veggies", "Grains", "Fruit"], people: ["Nicole", "Anthony"], items: nil)
    ]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        print(SharedValues.shared.userID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

}



extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listsForTesting.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = listsForTesting[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! ListCell
        cell.setUI(list: item)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(listsForTesting[indexPath.row].name)
    }
}
