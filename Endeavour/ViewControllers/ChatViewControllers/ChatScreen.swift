//
//  ChatScreen.swift
//  Endeavour
//
//  Created by Josh Edmundson on 25/01/2020.
//  Copyright © 2020 Josh Edmundson. All rights reserved.
//

import UIKit
import Firebase 

class ChatScreen: UITableViewController {
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    let cellID = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        title = "Chats"
        
        //Add a logout button to the left of the navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(displayLoginRegisterScreen))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))
        
        //Registers the custom cell type UserCell with the tableView.
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        observeUserMessages()
        
    }
    
    //Fetches the messages from Firebase, relevant to the current user, to be displayed.
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("User-Messages").child(uid)
        
        ref.observe(.childAdded, with: {(snapshot) in
            
            let messageID = snapshot.key
            let messagesReference = Database.database().reference().child("Messages").child(messageID)
            
            messagesReference.observe(.value, with: { (snapshot) in
                
                //Stores each message as a Message()
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    
                    message.fromID = dictionary["fromID"] as! String?
                    message.toID = dictionary["toID"] as! String?
                    message.text = dictionary["text"] as! String?
                    message.timeStamp = dictionary["timeStamp"] as! NSNumber?
                    
                    //Checks if the message has a toID attribute
                    //If it does, it creates a key-value pair in the messagesDictionary
                    //where the ID is the key and the message is the value.
                    //If the toID already exists in the dictionary, it's value gets updated to the
                    //text of the latest message sent.
                    if let chatPartnerID = message.chatPartnerID() {
                        self.messagesDictionary[chatPartnerID] = message
                        
                        self.messages = Array(self.messagesDictionary.values)
                        
                        //Sorts the different chats so the most recently active is
                        //displayed at the top of the table.
                        self.messages.sort { (message1, message2) -> Bool in
                            return message1.timeStamp!.intValue > message2.timeStamp!.intValue
                        }
                    }
                    
                    //Reloads the table with the new data
                    self.tableView.reloadData()
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    
    //Sets the number of rows in the table to the number of messages
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    //Sets the title of each cell to the text of the message.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Creates an instance of the UserCell class for each value of indexPath
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        
        //Gets each message from the messages list where the index of the item fetched
        //matches the row number in the table
        let message = messages[indexPath.row]
        //Sets the value of attribute in UserCell to the message constant
        cell.message = message
        
        return cell
    }
    
    
    //Make the cells in the table bigger
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    //Displays the given user's chat screen when their cell is selected in the table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Find the message corresponding to the cell selected
        let message = messages[indexPath.row]
        
        //Get's the ID of the other user in the chat by calling the "chatPartnerID" method.
        guard let chatPartnerID = message.chatPartnerID() else {
            return
        }
        
        //Sets up a reference to the aforementioned user's node
        let ref = Database.database().reference().child("Users").child(chatPartnerID)
        
        //Observes the values at the user's node
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Creates a dictionary to store the observed values
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            //Creates a user object
            let user = User()
            
            //Sets the attribute of the object based on the data stored in the dictionary
            user.name = dictionary["name"] as? String
            user.email = dictionary["email"] as? String
            user.id = snapshot.key
            
            //Display's the "chatLogContoller" for the selected user.
            self.displayChatLogControllerForUser(user: user)
            
        }, withCancel: nil)
    }
    
    
    //Function that will display chatLogController when called.
    func displayChatLogControllerForUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.hidesBottomBarWhenPushed = true
        //Sets the attribute "user" of chatLogController to the argument "user".
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
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
    
    
    //This function will display an instance of the UINavigationController class within a
    //root view controller that is an instance of NewMessageScreen.
    @objc func handleNewMessage() {
        let newMessageScreen = NewMessageScreen()
        newMessageScreen.chatScreen = self
        let navigationController = UINavigationController(rootViewController: newMessageScreen)
        present(navigationController, animated: true, completion: nil)
    }
    
    
    //This logs the current user out of Firebase
    func logOutCurrentUser() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    
    //Gets the current user's information when called
    func getCurrentUsersInfo() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("Users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            print(snapshot)
            
        }, withCancel: nil)
        
    }
}


