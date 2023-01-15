//
//  CreateBetViewController.swift
//  WannaBet
//
//  Created by Patrick Becker II on 5/12/21.
//

import UIKit
import Firebase

class CreateBetViewController: UIViewController {

    
    @IBOutlet weak var LoginMessage: UILabel!
    @IBOutlet weak var createBetButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        if TabBarController.UserVariables.uid == "" {
            LoginMessage.isHidden = false
            createBetButton.isHidden = true
        } else {
            LoginMessage.isHidden = true
            createBetButton.isHidden = false;
        }
    }
    
    
}
