//
//  GameDisplayTableVC.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 1/6/18.
//  Copyright © 2018 Micah DeLaurentis. All rights reserved.
//

import Foundation
import UIKit

class GameDisplayTableVC: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var gameBoardViews = [Game]()
    
    var backBtn: UIButton = {
        let bb = UIButton()
        bb.frame = CGRect(origin: CGPoint(x: 10, y: 30), size: CGSize(width: 70, height: 30))
        bb.backgroundColor = .yellow
        bb.setTitle("🔙", for: .normal)
        
        return bb
    }()
    
    override func viewDidLoad() {
     tableView = UITableView()
     tableView.backgroundColor = .blue
     tableView.dataSource = self
     tableView.delegate = self
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}
