//
//  GoalTrackerScreen.swift
//  Endeavour
//
//  Created by Josh Edmundson on 25/01/2020.
//  Copyright © 2020 Josh Edmundson. All rights reserved.
//

import UIKit
import Firebase

class GoalTrackerScreen: UITableViewController {
    
    let cellID = "cellID"
    
    var goals = [Goal]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make the background colour white
        view.backgroundColor = .white
        
        title = "Goals"
        
        //Add a logout button to the left of the navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(displayLoginRegisterScreen))
        
        //Add a "+" button to the top right of the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(displayNewGoalScreen))
        
        //Register custom class "GoalCell" as the default cell class
        tableView.register(GoalCell.self, forCellReuseIdentifier: cellID)
        
        checkIfUserIsLoggedIn()
        observeUserGoals()
    }
    
    
    @objc func displayNewGoalScreen() {
        let newGoalScreen = NewGoalScreen()
        let navigationControllerNewGoalScreen = UINavigationController(rootViewController: newGoalScreen)
        present(navigationControllerNewGoalScreen, animated: true, completion: nil)
    }
    
    
    func checkIfUserIsLoggedIn() {
        //Checks to see if the user is logged in already
        if Auth.auth().currentUser?.uid == nil {
            //If the user is not logged in, display the login page
            displayLoginRegisterScreen()
        }
    }
    
    
    //This function can be used to display the login in/register screen
    @objc func displayLoginRegisterScreen() {
        //Log the user out of firebase
        logOutCurrentUser()
        
        //Instansiate LoginRegisterScreen
        let loginRegisterScreen = LoginRegisterScreen()
        
        //Set the display to fullscreen
        loginRegisterScreen.modalPresentationStyle = .fullScreen
        
        //Display the LoginRegisterScreen object
        present(loginRegisterScreen, animated: true, completion: nil)
    }
    
    
    //This logs the current user out of Firebase
    func logOutCurrentUser() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    
    //Retrieves all the user's current goals from Firebase
    func observeUserGoals() {
        
        //Checks the current user is logged in
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        //Sets up a reference to the user's personal node that extends "User-Goals"
        let ref = Database.database().reference().child("User-Goals").child(uid)
        
        //Observes all the goal IDs stored at that node.
        ref.observe(.childAdded, with: { (snapshot) in
            
            //Sets "goalID" equal to the unique ID of each goal stored at "User-Goals"->uid
            let goalID = snapshot.key
            
            //Sets up another database reference to each goal's ID but within "Goals"
            let goalReference = Database.database().reference().child("Goals").child(goalID)
            
            //Retrieves the data for each goal, stores it as an instance of "Goal", and then adds it
            //to "goals[]"
            goalReference.observe(.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                
                    let goal = Goal()
                    
                    goal.name = dictionary["name"] as? String
                    goal.startDate = dictionary["startDate"] as? String
                    goal.endDate = dictionary["endDate"] as? String
                    goal.accountabilityEmail = dictionary["accountabilityEmail"] as? String
                    goal.goalID = goalID
                    
                    self.checkGoalEndDate(goal: goal)
                    self.goals.append(goal)
                }
                
                //Refreshes the table view
                self.tableView.reloadData()
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }
    
    
    //This function will iterate throught the "goals" list and compare each goal's end date to today's
    func checkGoalEndDate(goal: Goal) {
        
        let currentDate = NSDate() as Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        guard let endDate = dateFormatter.date(from: goal.endDate!) else {
            return
        }
    
        //Compare dates
        if currentDate > endDate {
            
            //Set up a reference to "Users" in Firebase
            let ref = Database.database().reference().child("Users")
            
            //Observe all the values stored at the "Users" node
            ref.observe(.value, with: { (snapshot) in
                
                //Unwrapps the snapshot as a Dictionary
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    //Itterates through the dictionary
                    for item in dictionary {
                        
                        //Unwrapps the email attribute of the "goal" argument
                        guard let goalEmail = goal.accountabilityEmail else {
                            return
                        }
                        
                        //Unwraps the email retrieved from Firebase
                        guard let retrievedEmail = item.value["email"] as? String? else {
                            return
                        }
                        
                        //Checks to see if the email from Firebase matches the email stored as an attribute of "goal"
                        if goalEmail == retrievedEmail {
                
                            let message = "Hey, I've missed a deadline! Chase me up!"
                            let peerID = item.key
                            
                            //Sends a text to the goal's linked user if the goal has passed it's deadline.
                            self.sendMessage(messageText: message, recipientID: peerID)
                            
                        }
                        
                    }
                    
                }
                
            }, withCancel: nil)
            
        }
        
    }
    
    
    
    //Removes a goal from Firebase
    func removeGoal(withID goalID: String) {
        
        //Unwrap the optional userID
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        //Create references to Firebase, one to the goal in the "Goals" sub-tree and the other to the
        //goal in the "User-Goals" sub-tree
        let goalRef = Database.database().reference().child("Goals").child(goalID)
        let userGoalRef = Database.database().reference().child("User-Goals").child(userID).child(goalID)
        
        //Removes the value specified in the "goalRef" reference
        goalRef.removeValue { (error, _) in
            
            //Catches and prints any errors
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            
        }
        
        //Removes the value specified in the "userGoalRef" reference
        userGoalRef.removeValue { (error, _) in
            
            //Catches and prints any errors
            if error != nil {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    
    func sendMessage(messageText: String, recipientID: String) {
        
        //Creates a reference to a new node in firebase "Messages"
        let ref = Database.database().reference().child("Messages")
        //Creates a unique ID for this particular message node
        let childRef = ref.childByAutoId()
        //Uploads text and recipient from the text field to the database.
        let toID = recipientID
        let fromID = Auth.auth().currentUser!.uid
        let timeStap = NSDate().timeIntervalSince1970
        let values = ["text": messageText, "toID": toID, "fromID": fromID, "timeStamp": timeStap] as [String : Any]
        
        //Adds the  key-value pairs stored within the dictionary "values" to the "childByAutoId" node
        //If those values are successfully added, the completion block runs.
        childRef.updateChildValues(values) { (error, ref) in
            
            //Catches and prints any errors to the console
            if error != nil {
                print(error as Any)
            }
            
            guard let messageID = childRef.key else {
                return
            }
            
            //Sets up a reference to a node called "User-Messages" and creates a chid node
            //Based on the user's ID
            let userMessageRef = Database.database().reference().child("User-Messages").child(fromID)
            //Adds the message ID to user's ID node.
            userMessageRef.updateChildValues([messageID: true]) { (error, ref) in
                print("Inside userMessageRef")
                if error != nil{
                    print(error as Any)
                    return
                }
            }
            
            //Creates a node in "User-Messages" based on the recipients ID
            //Stores the message ID at that node.
            let recipientUserMessagesRef = Database.database().reference().child("User-Messages").child(toID)
            recipientUserMessagesRef.updateChildValues([messageID: true]) {(error, ref) in
                if error != nil {
                    print(error as Any)
                    return
                }
            }
            
        }
    }
    
    
    /* Setup and modify the table view */
    
    //Determine the number of rows in the "UITableView" equal to the number of goals in "Goals"
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    
    //Sets the information of each cell to match each goal
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Creates an instance of the GoalCell class for each value of indexPath
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! GoalCell
        
        //Gets each goal from the goals list where the index of the item fetched
        //matches the row number in the table
        let goal = goals[indexPath.row]
        //Sets the value of the "goal" attribute in "GoalCell" to the "goal" constant
        cell.goal = goal
        
        return cell
    }
    
    
    //Make the cells in the table bigger
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    /* "Swipe-to-delete" code: */
    
    //Allows the user to edit the table
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    //Configures the action taken when a use swipes a cell.
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //Creates a new contextual action and set's its basic attributes
        let deleteAction = UIContextualAction(style: .destructive, title: "Complete") { (_, _, complete) in
            
            //Retrieves the "goalID" of the goal to be removed and unwraps it.
            guard let goalID = self.goals[indexPath.row].goalID else {
                return
            }
            
            //When the action is called, the "goalCell" swiped is removed from the "goals" list, from the table, and from Firebase.
            self.goals.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.removeGoal(withID: goalID)
            
            complete(true)
        }
        
        
        //Changes the background colour of the delete button
        deleteAction.backgroundColor = UIColor(displayP3Red: 22/255, green: 160/255, blue: 133/255, alpha: 1.0)
        
        //Sets "deleteAction" as the action taken when a cell is swiped completely to the left or right.
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
    
}
