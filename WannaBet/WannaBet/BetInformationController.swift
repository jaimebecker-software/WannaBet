//
//  BetInformationController.swift
//  WannaBet
//
//  Created by Jaime Becker on 7/31/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class BetInformationController: UIViewController {
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var didYouWinLabel: UILabel!
    
    let db = Firestore.firestore()
    var currentBet : Bet?
    var currentIndex : Int?
    var creatorBalance : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        promptLabel.text = currentBet?.prompt
        amountLabel.text = String(currentBet!.amount as Double)
        getOpponentLabel()
        
        if currentBet?.winner == ""{
            yesButton.isHidden = false
            noButton.isHidden = false
            didYouWinLabel.isHidden = false
        }else{
            yesButton.isHidden = true
            noButton.isHidden = true
            didYouWinLabel.isHidden = true
        }
        
    }
    
    func getOpponentLabel()  {
        var opponent : Query?
        if currentBet!.creator == TabBarController.UserVariables.uid{
            // You are the creator so you want to see opponent as the opponent field
            opponent = db.collection("user").whereField("userID", isEqualTo: currentBet!.opponent as String)
        }else{
            // You are technically the opponent here (you did not create the bet)
            // so you want the creator in the opponent label
            opponent = db.collection("user").whereField("userID", isEqualTo: currentBet!.creator as String)
        }
        
        opponent!.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if (querySnapshot?.documents.count)!>1 || (querySnapshot?.documents.count)!==0 {
                print("Invalid number of documents")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let name = data["name"] as? String{
                        DispatchQueue.main.async {
                            self.opponentLabel.text = name
                        }
                    }
                }
            }
        }
    }

    @IBAction func yesButtonPressed(_ sender: UIButton) {
        // Update data
        updateBetWinner(winner: self.currentBet!.creator)
        updateBalanceWinsAndLossesForCreatorAndOpponent(creatorWon: true)
    
        // Go back to bets page
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func noButtonPressed(_ sender: Any) {
        // Update data
        updateBetWinner(winner: self.currentBet!.opponent)
        updateBalanceWinsAndLossesForCreatorAndOpponent(creatorWon: false)
        
        // Go back to bets page
        navigationController?.popViewController(animated: true)
    }
    
    func updateBetWinner(winner : String){
        let correspondingBet = db.collection("bets").whereField("betID", isEqualTo: currentBet?.betID ?? 0)
        correspondingBet.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else if (querySnapshot?.documents.count)!>1 || (querySnapshot?.documents.count)!==0 {
                    print(querySnapshot?.documents.count ?? -9)
                    print("Invalid number of documents")
                } else {
                    for document in querySnapshot!.documents {
                        document.reference.updateData([
                            "winner" : winner
                        ])
                    }
                }
        }
    }
    
    func updateBalanceWinsAndLossesForCreatorAndOpponent(creatorWon : Bool){
        let creator = db.collection("user").whereField("userID", isEqualTo: currentBet!.creator as String)
        
        creator.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else if (querySnapshot?.documents.count)!>1 || (querySnapshot?.documents.count)!==0 {
                    print("Invalid number of documents")
                } else {
                    for document in querySnapshot!.documents {
                        if creatorWon {
                            document.reference.updateData([
                                "wins" : FieldValue.increment(Int64(1)),
                                "balance" : FieldValue.increment(self.currentBet!.amount)
                            ])
                        } else {
                            document.reference.updateData([
                                "losses" : FieldValue.increment(Int64(1)),
                                "balance" : FieldValue.increment(self.currentBet!.amount * -1)
                            ])
                        }
                        
                        let data = document.data()
                        if let balance = data["balance"] as? Double{
                            self.creatorBalance = balance
                        }
                        
                    }
                }
        }
        
        let opponent = db.collection("user").whereField("userID", isEqualTo: currentBet!.opponent as String)
        
        opponent.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else if (querySnapshot?.documents.count)!>1 || (querySnapshot?.documents.count)!==0 {
                    print("Invalid number of documents")
                } else {
                    for document in querySnapshot!.documents {
                        if !creatorWon {
                            document.reference.updateData([
                                "wins" : FieldValue.increment(Int64(1)),
                                "balance" : FieldValue.increment(self.currentBet!.amount)
                            ])
                            
                        } else {
                            document.reference.updateData([
                                "losses" : FieldValue.increment(Int64(1)),
                                "balance" : FieldValue.increment(self.currentBet!.amount * -1)
                            ])
                        }
                    }
                }
        }
    }
}
