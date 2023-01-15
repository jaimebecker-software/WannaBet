//
//  ViewController.swift
//  WannaBet
//
//  Created by Patrick Becker II on 4/27/21.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        FirebaseApp.configure()
    }


}

