//
//  LeaderboardViewController.swift
//  WannaBet
//
//  Created by Jaime Becker on 8/30/21.
//

import UIKit
import Firebase

class LeaderboardViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leaderLabel: UILabel!
    
    let db = Firestore.firestore()
    var users : [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        
        
        loadLeaderboard()
    }
    
    func loadLeaderboard(){
        let users = db.collection("user").order(by: "wins", descending: true)
        var count = 0;
        
        users.addSnapshotListener { (querySnapshot, error) in
            count = 0
            var leader = ""
                if let err = error {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let userID = data["userID"] as? String,
                           let balance = data["balance"] as? Int,
                           let name = data["name"] as? String,
                           let email = data["email"] as? String,
                           let myBets = data["myBets"] as? [String],
                           let myFriends = data["myFriends"] as? [String],
                           let wins = data["wins"] as? Int,
                           let losses = data["losses"] as? Int{
                            
                            let user = User(balance: balance, email: email, myBets: myBets, myFriends: myFriends, userID: userID, wins: wins, losses: losses, name: name)
                            self.users.append(user)
                            if count == 0 {
                                leader = user.name
                            }
                            count += 1
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.leaderLabel.text = leader
                        self.tableView.reloadData()
                    }
                }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Give cell for table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        // Give it the bet title name
        cell.nameLabel.text = users[indexPath.row].name
        cell.winsLabel.text = String(users[indexPath.row].wins)

        return cell
    }
    
}
