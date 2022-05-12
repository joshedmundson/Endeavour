//
//  NewMessageScreen.swift
//  Endeavour
//
//  Created by Josh Edmundson on 04/02/2020.
//  Copyright © 2020 Josh Edmundson. All rights reserved.
//

import UIKit
import Firebase

class NewMessageScreen: UITableViewController {
    
    let cellID = "cellID"
    
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Adds the cancel button to the navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        
        //Changes the title of the view controller
        title = "New Message"
        
        //Registers our custom cell class. 
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        //Fetch the users from Firebase
        fetchUsers()
        
    }
    
    
    //When run, fetches users from firebase
    func fetchUsers() {
        
        //Create a Firebase reference
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            
            //Creates a variable "dictionary" and stores the values contained within the snapshot as a
            //key-value pair within the dictionary data structure.
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //Creates an instance of User
                let user = User()
                
                //Gives the attributes of user values
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.id = snapshot.key
                
                //Adds the new user to the list.
                self.users.append(user)
                
                self.tableView.reloadData()
            }
            
            
        }, withCancel: nil)
        
    }
    
    
    //Dismisses the screen when the user presses the cancel button.
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }

   
    //Overides the tableView function from the UITableViewController parent class and sets
    //the number of rows to be displayed with information to the number of users.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    //A custom cell for each row we are displaying and displays each user's name and email on the relevant cell.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        return cell
    }
    
    
    //Makes the cells a bit taller
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    //Create an instance of chat screen so we can access the function displayChatLogController
    var chatScreen: ChatScreen?
    
    //Instruct the app to call displayChatLogController() when a cell is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: {
            //Sets the constant user equal to the user selected from the contacts list.
            let user = self.users[indexPath.row]
            //Calls displayChatLogControllerForUser() for the current selected user
            self.chatScreen?.displayChatLogControllerForUser(user: user)
        })
    }

}
