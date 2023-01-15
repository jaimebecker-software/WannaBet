//
//  AddFriendViewController.swift
//  WannaBet
//
//  Created by Jaime Becker on 8/10/21.
//

import UIKit
import Firebase

class AddFriendViewController: UITableViewController {
    
    let db = Firestore.firestore()
    
    var alreadyFriendedIds : [String] = []
    var nonFriends : [User] = []
    
    var selectedUser : User?
    var selectedRow : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // TODO: implement search bar functionality
    
    override func viewDidAppear(_ animated: Bool) {
        if TabBarController.UserVariables.uid != "" {
            loadMyFriends() {
                self.loadNonFriends()
                // TODO: it will not load friends you are already friends with, unless you
                // literally just added them (if you exit to account page and go back in the
                // friend will be gone from list) -- have to figure out how to make real-time
            }
        }
    }
    
    func loadMyFriends(completion: @escaping () -> Void){
        let user = db.collection("user").whereField("userID", isEqualTo: TabBarController.UserVariables.uid)
        
            user.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else if (querySnapshot?.documents.count)!>1 || (querySnapshot?.documents.count)!==0 {
                        print("Invalid number of documents")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            if let myFriends = data["myFriends"] as? [String]{
                                for friend in myFriends{
                                    print("Adding friend " + friend)
                                    self.alreadyFriendedIds.append(friend)
                                }
                            }
                        }
                    }
                completion()
            }
    }
    
    func loadNonFriends(){
        let friends = db.collection("user")
        
        friends.getDocuments() { (querySnapshot, error) in
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

                            if userID != TabBarController.UserVariables.uid && !self.alreadyFriendedIds.contains(userID){
                                let user = User(balance: balance, email: email, myBets: myBets, myFriends: myFriends, userID: userID, wins: wins, losses: losses, name: name)
                                self.nonFriends.append(user)
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nonFriends.count
    }
    
    /* What each row has in table*/
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Give cell for table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Give it the bet title name
        cell.textLabel?.text = nonFriends[indexPath.row].email
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        self.selectedUser = nonFriends[selectedRow!]
        performSegue(withIdentifier: "addFriendToFriendConfirmation", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addFriendToFriendConfirmation"{
            if let nextViewController = segue.destination as? AddFriendConfirmationViewController {
                nextViewController.newFriend = selectedUser ?? nil
            }
        }
    }
}

