//
//  AccountPageController.swift
//  WannaBet
//
//  Created by Jaime Becker on 5/23/21.
//

import UIKit
import Firebase

class AccountPageController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var LoginInfo: UILabel!
    @IBOutlet weak var betCounterLabel: UILabel!
    @IBOutlet weak var lossesCounterLabel: UILabel!
    @IBOutlet weak var winsCounterLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myFriendsLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    
    let db = Firestore.firestore()
    
    var friends : [User] = []
    var friendIds : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if TabBarController.UserVariables.uid != "" {
            LoginInfo.isHidden = true
            tableView.isHidden = false
            loadInformation()
            usernameLabel.isHidden = false
            myFriendsLabel.isHidden = false
            addFriendButton.isHidden = false
            
            loadMyFriendIds() {
                self.loadMyFriends()
            }
            
        }else{
            LoginInfo.isHidden = false
            tableView.isHidden = true
            usernameLabel.isHidden = true
            myFriendsLabel.isHidden = true
            addFriendButton.isHidden = true
        }
    }
    
    func loadInformation(){
        if TabBarController.UserVariables.uid != "" {
            let myBets = db.collection("user").whereField("userID", isEqualTo: TabBarController.UserVariables.uid)
            
            myBets.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        var myBetCount = 0
                        var myWinsCount = 0
                        var myLossesCount = 0
                        var myUsername = ""
                        
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            if let myBets = data["myBets"] as? [String], let wins = data["wins"] as? Int, let losses = data["losses"] as? Int, let name = data["name"] as? String{
                                myBetCount = myBets.count
                                myWinsCount = wins
                                myLossesCount = losses
                                myUsername = name
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.betCounterLabel.text = String(myBetCount)
                            self.winsCounterLabel.text = String(myWinsCount)
                            self.lossesCounterLabel.text = String(myLossesCount)
                            self.usernameLabel.text = String(myUsername)
                        }
                    }
            }
        }
    }
    
    func loadMyFriendIds(completion: @escaping () -> Void){
        let user = db.collection("user").whereField("userID", isEqualTo: TabBarController.UserVariables.uid)
        
            user.getDocuments() { (querySnapshot, err) in
                self.friendIds = []
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else if (querySnapshot?.documents.count)!>1 || (querySnapshot?.documents.count)!==0 {
                        print("Invalid number of documents")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            if let myFriends = data["myFriends"] as? [String]{
                                for friend in myFriends{
                                    self.friendIds.append(friend)
                                }
                            }
                        }
                    }
                completion()
            }
    }
    
    func loadMyFriends(){
        let friends = db.collection("user")
        
        friends.getDocuments() { (querySnapshot, error) in
            self.friends = []
            if let e = error {
                print("ERROR: Issue retrieving from data store: \(e)")
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    // Iterate through data in db
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        if let userID = data["userID"] as? String,
                            let balance = data["balance"] as? Int,
                            let name = data["name"] as? String,
                            let email = data["email"] as? String,
                            let myBets = data["myBets"] as? [String],
                            let myFriends = data["myFriends"] as? [String],
                            let wins = data["wins"] as? Int,
                            let losses = data["losses"] as? Int{

                            if userID != TabBarController.UserVariables.uid {
                                let user = User(balance: balance, email: email, myBets: myBets, myFriends: myFriends, userID: userID, wins: wins, losses: losses, name: name)
                                if self.friendIds.contains(user.userID){
                                    self.friends.append(user)
                                }
                            }
        
                            // Need to add the DispatchQueue part when updating UI in a closure
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Give cell for table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Give it the bet title name
        cell.textLabel?.text = friends[indexPath.row].email

        return cell
    }
}
