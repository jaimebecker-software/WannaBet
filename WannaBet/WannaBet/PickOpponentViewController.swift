//
//  PickOpponentViewController.swift
//  WannaBet
//
//  Created by Jaime Becker on 8/12/21.
//

import UIKit
import Firebase

protocol MyDataSendingDelegateProtocol {
    func sendSelectedUserToAddBetController(myData: User)
}

class PickOpponentViewController: UITableViewController{
    
    var delegate: MyDataSendingDelegateProtocol? = nil
    
    let db = Firestore.firestore()
    
    var friends : [User] = []
    var friendIds : [String] = []
    
    var selectedUser : User?
    var selectedRow : Int?
    
    var userToSend : User?
    
    var searchedFriend : [User] = []
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // TODO: implement search bar functionality
    
    override func viewDidAppear(_ animated: Bool) {
        if TabBarController.UserVariables.uid != "" {
            loadMyFriendIds() {
                self.loadMyFriends()
            }
        }
    }
    
    func loadMyFriendIds(completion: @escaping () -> Void){
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
                                let user = User(balance: balance, email: email, myBets: myBets, myFriends: myFriends, userID: userID, wins: wins, losses: losses,name: name)
                                self.friends.append(user)
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
        //return friends.count
        if searching {
            return searchedFriend.count
        }else{
            return friends.count
        }
    }
    
    /* What each row has in table*/
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Give cell for table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Give it the bet title name
        //cell.textLabel?.text = friends[indexPath.row].email
        if searching {
            cell.textLabel?.text = searchedFriend[indexPath.row].email
        } else {
            cell.textLabel?.text = friends[indexPath.row].email
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        if searching {
            self.selectedUser = searchedFriend[selectedRow!]
        }else{
            self.selectedUser = friends[selectedRow!]
        }
//        self.selectedRow = indexPath.row
//        self.selectedUser = friends[selectedRow!]
        
        if self.delegate != nil && self.selectedUser != nil {
            let dataToBeSent = self.selectedUser
            self.delegate?.sendSelectedUserToAddBetController(myData: dataToBeSent!)
            dismiss(animated: true, completion: nil)
        }
    }
}

extension PickOpponentViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedFriend = friends.filter {
            $0.email.lowercased().prefix(searchText.count) == searchText.lowercased()
        }
        searching = true
        tableView.reloadData()
    }
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
}
