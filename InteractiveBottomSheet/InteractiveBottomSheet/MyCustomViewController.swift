//
//  MyCustomViewController.swift
//  InteractiveBottomSheet
//
//  Created by Wanderson López on 8/04/22.
//
//  Contains a view with a white background, rounded
//  corners, and shadow

import UIKit

class MyCustomViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.layer.cornerRadius = 20
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOffset = .init(width: 0, height: -2)
        self.view.layer.shadowRadius = 20
        self.view.layer.shadowOpacity = 0.5
    }
}
