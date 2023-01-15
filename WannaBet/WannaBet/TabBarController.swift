//
//  TabBarController.swift
//  WannaBet
//
//  Created by Patrick Becker II on 5/2/21.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseEmailAuthUI

class TabBarController: UITabBarController{
    
    @IBOutlet weak var LoginButton: UIBarButtonItem!
    
    struct UserVariables {
        static var uid = ""
    }
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func LoginButtonTapped(_ sender: Any) {
        if (UserVariables.uid == "") {
            let authUI = FUIAuth.defaultAuthUI()
            authUI?.delegate = self
            let providers:[FUIAuthProvider] = [FUIEmailAuth()]
            authUI?.providers = providers
            let authViewController = authUI?.authViewController()
            present(authViewController!, animated: true, completion: nil)
        }
    }
    
    func reloadTabBar(amount : Double){
        LoginButton.title = "$" + String(amount)
    }
    
}

extension TabBarController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        // Check if there was an error
        guard error == nil else {
            // Log error
            return
        }
        
        UserVariables.uid = authDataResult?.user.uid ?? ""
        
        let currentUser = Auth.auth().currentUser
        var currentBalance = 0;
        
        let existingUser = db.collection("user").whereField("userID", isEqualTo: TabBarController.UserVariables.uid)
        existingUser.getDocuments() { [self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else if ((querySnapshot?.documents.count)!>0) {
                    print("Already has user field - skip")
                    existingUser.getDocuments{ (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else if (querySnapshot?.documents.count)!>1 || (querySnapshot?.documents.count)!==0 {
                            print("Invalid number of documents")
                        } else {
                            for document in querySnapshot!.documents {
                                let data = document.data()
                                print("Getting balance...")
                                if let balance = data["balance"] as? Int{
                                    print("got balance " + String(balance))
                                    //currentBalance = balance
                                    self.LoginButton.title = "$" + String(balance)
                                }
                            }
                        }
                    }
                } else {
                    print("Needs a user field")
                    currentBalance = 500
                
                    // Insert into user db
                    var ref: DocumentReference? = nil
                    ref = db.collection("user").addDocument(data: [
                        "userID": TabBarController.UserVariables.uid,
                        "balance": 500,
                        "myBets": [],
                        "email": (currentUser?.email)! as String,
                        "name": (currentUser?.displayName)! as String,
                        "myFriends": [],
                        "wins": 0,
                        "losses": 0
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
                }
        }
        
        if TabBarController.UserVariables.uid != "" {
            LoginButton.title = "$" + String(currentBalance)
        }
    }
}

/*
 //
 //  LoginViewController.swift
 //  WannaBet
 //
 //  Created by Patrick Becker II on 5/2/21.
 //
 import UIKit
 import FirebaseUI

 class LoginViewController: UIViewController {

     override func viewDidLoad() {
         super.viewDidLoad()
         // Do any additional setup after loading the view.
     }
     
     @IBAction func login() {
         //Get default AuthUI object
         let authUI = FUIAuth.defaultAuthUI();
         
         guard authUI != nil else {
             return
         }
         //set ourselves as the delegate
         authUI?.delegate = self;
         
         //get reference to the auth ui view controller
         let authViewController = authUI!.authViewController();
         
         //show it
         present(authViewController, animated: true, completion: nil);
         //dismiss(animated: true, completion: nil)
     }
     
 }

 extension LoginViewController: FUIAuthDelegate {
     func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {a
         // Check if there was an error
         guard error == nil else {
             // Log error
             return
         }
         
         //authDataResult?.user.uid;
         
         //performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
     }
 }

 
 */
