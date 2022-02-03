//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Vladyslav Taranenko on 03.02.2022.
//

import UIKit

class CategoryViewController: UITableViewController {

    var categories: [Category] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
