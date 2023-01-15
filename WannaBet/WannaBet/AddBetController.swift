//
//  AddBetController.swift
//  WannaBet
//
//  Created by Jaime Becker on 5/23/21.
//

import UIKit
import Firebase

class AddBetController: UIViewController, MyDataSendingDelegateProtocol {
    
    @IBOutlet weak var promptTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var selectedOpponentLabel: UILabel!
    
    var selectedOpponent : User?
    
    let db = Firestore.firestore()

    @IBOutlet weak var LoginInfo: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func sendSelectedUserToAddBetController(myData: User) {
        self.selectedOpponent = myData
        self.selectedOpponentLabel.text = myData.email
    }

    @IBAction func doneButtonPressed(_ sender: UIButton) {
        let prompt = promptTextField.text
        let amount = amountTextField.text
        let opponent = selectedOpponent
        
        let betId = UUID().uuidString
        
        var ref: DocumentReference? = nil
        ref = db.collection("bets").addDocument(data: [
            "creator": TabBarController.UserVariables.uid,
            "betID": betId,
            "prompt": prompt ?? "no prompt entered",
            "opponent": opponent?.userID ?? "no opponent entered",
            "amount": Double(amount!) ?? 0.0,
            "winner": ""
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
        if TabBarController.UserVariables.uid != "" {
            let correspondingUser = db.collection("user").whereField("userID", isEqualTo: TabBarController.UserVariables.uid)
            correspondingUser.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else if (querySnapshot?.documents.count)!>1 || (querySnapshot?.documents.count)!==0 {
                        print("Invalid number of documents")
                    } else {
                        for document in querySnapshot!.documents {
                            document.reference.updateData([
                                "myBets" : FieldValue.arrayUnion([betId])
                            ])
                        }
                    }
            }
        }
        
        if TabBarController.UserVariables.uid != "" {
            let correspondingOpponent = db.collection("user").whereField("userID", isEqualTo: selectedOpponent?.userID ?? 0)
            correspondingOpponent.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else if (querySnapshot?.documents.count)!>1 || (querySnapshot?.documents.count)!==0 {
                        print("Invalid number of documents")
                    } else {
                        for document in querySnapshot!.documents {
                            document.reference.updateData([
                                "myBets" : FieldValue.arrayUnion([betId])
                            ])
                        }
                    }
            }
        }
        
        
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addBetToPickOpponent" {
            let secondVC: PickOpponentViewController = segue.destination as! PickOpponentViewController
            secondVC.delegate = self
        }
    }
    
    //TODO maybe try unwind segue https://matteomanferdini.com/unwind-segue/

}
