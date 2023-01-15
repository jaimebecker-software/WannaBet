//
//  MyBetsController.swift
//  WannaBet
//
//  Created by Jaime Becker on 5/23/21.
//

import UIKit
import Firebase

class MyBetsController: UIViewController {
    
    let db = Firestore.firestore()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var bets: [Bet] = []
    var pressedBet : Bet?
    var selectedRow : Int?
    
    var openBets : [Bet] = []
    var closedBets : [Bet] = []

    var currentTableView : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        currentTableView = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if TabBarController.UserVariables.uid != "" {
            loadBets()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BetInformationController {
            let vc = segue.destination as? BetInformationController
            vc?.currentBet = pressedBet
            vc?.currentIndex = selectedRow
        }
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        currentTableView = sender.selectedSegmentIndex
        tableView.reloadData()
    }
    
    func loadBets(){
        let myBets = db.collection("bets")
        
        myBets.addSnapshotListener { (querySnapshot, error) in
            self.bets = []
            self.closedBets = []
            self.openBets = []
            if let e = error {
                print("ERROR: Issue retrieving from data store: \(e)")
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    // Iterate through data in db
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        if let prompt = data["prompt"] as? String, let amount = data["amount"] as? Double, let creator = data["creator"] as? String, let betID = data["betID"] as? String, let opponent = data["opponent"] as? String, let winner = data["winner"] as? String{
                            
                            if creator == TabBarController.UserVariables.uid || opponent == TabBarController.UserVariables.uid{
                                let bet = Bet(creator: creator, betID: betID, prompt: prompt, opponent: opponent, amount: amount, winner: winner)
                                if winner.isEmpty{
                                    self.openBets.append(bet)
                                }else{
                                    self.closedBets.append(bet)
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
    

}

extension MyBetsController: UITableViewDataSource{
    /* How many rows in table view*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return bets.count
        if currentTableView == 0{
            return openBets.count
        }else{
            return closedBets.count
        }
    }
    
    /* What each row has in table*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Give cell for table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "Reusable Cell", for: indexPath)
        cell.backgroundColor = UIColor.white
        // Give it the bet title name
        //cell.textLabel?.text = bets[indexPath.row].prompt
        if currentTableView == 0{
            cell.textLabel?.text = openBets[indexPath.row].prompt
        }else{
            cell.textLabel?.text = closedBets[indexPath.row].prompt
            if closedBets[indexPath.row].winner == closedBets[indexPath.row].creator {
                cell.backgroundColor = UIColor.green
            }else if closedBets[indexPath.row].winner == closedBets[indexPath.row].opponent{
                cell.backgroundColor = UIColor.red
            }
        }
        
        return cell
    }
}

extension MyBetsController: UITableViewDelegate{
    /* Method for later -- what happens when you select a row*/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        //self.pressedBet = bets[selectedRow!]
        if currentTableView == 0 {
            self.pressedBet = openBets[selectedRow!]
        }else{
            self.pressedBet = closedBets[selectedRow!]
        }
        performSegue(withIdentifier: "MyBetsToBetInfo", sender: self)
    }
}
