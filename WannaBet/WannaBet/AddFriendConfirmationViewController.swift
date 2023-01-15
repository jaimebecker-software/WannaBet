//
//  AddFriendConfirmationViewController.swift
//  WannaBet
//
//  Created by Jaime Becker on 8/10/21.
//

import UIKit
import Firebase

class AddFriendConfirmationViewController: UIViewController {

    
    @IBOutlet weak var LoginMessage: UILabel!
    @IBOutlet weak var createBetButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    var newFriend : User?
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        usernameLabel.text = newFriend?.name;
    }

    @IBAction func yesButtonPressed(_ sender: UIButton) {
        if TabBarController.UserVariables.uid != "" {
            let currentUser = db.collection("user").whereField("userID", isEqualTo: TabBarController.UserVariables.uid)
            
            currentUser.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        document.reference.updateData([
                            "myFriends": FieldValue.arrayUnion([self.newFriend!.userID])
                        ])
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func noButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
