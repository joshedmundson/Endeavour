//
//  ChatLogController.swift
//  Endeavour
//
//  Created by Josh Edmundson on 09/02/2020.
//  Copyright © 2020 Josh Edmundson. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    
    //Sets the title of the instance of ChatLogController to the selected user's name
    //as soon as the user's name is set.
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            //Calls observe messages
            observeMessages()
        }
    }
    
    
    //Stores the messages of the current user.
    var messages = [Message]()
    
    
    //Observes the messages of which the current user is either the sender or recipient and appends them to the
    //"messages" list.
    func observeMessages() {
        
        //Unwrapps the current user UID
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        //Sets up a reference to the "User-Messages" node in Firebase
        let userMessagesRef = Database.database().reference().child("User-Messages").child(uid)
        
        //Observes each message at the current user's UID sub-node
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            //Gets the message ID as the snapshot key
            let messageID = snapshot.key
            
            //Sets up another reference to the "Messages" node this time
            let messagesRef = Database.database().reference().child("Messages").child(messageID)
            
            //Observes each message either sent or recieved by the current user
            messagesRef.observe(.value, with: { (snapshot) in
                
                //Unwrapps the values found and stores them in a dictionary
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                //Creates a message object for each message found
                let message = Message()
                
                //Sets the "message" attributes to the corresponding values from the database
                message.text = dictionary["text"] as? String
                message.fromID = dictionary["fromID"] as? String
                message.timeStamp = dictionary["timeStamp"] as? NSNumber
                message.toID = dictionary["toID"] as? String
                
                //Makes sure only messages that belong in that chat are displayed
                if message.chatPartnerID() == self.user?.id {
                    //Adds the each "message" to the "messages" array
                    self.messages.append(message)
                    
                    //Reloads the table data to display all the messages.
                    self.collectionView.reloadData()
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }
    
    //This reason we define inputTextField in this way is so that we can
    //reference it outside of the setupInputComponents() function
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    
    //Create a cell ID
    let cellID = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets the background colour of the UIView at the bottom of the screen to solid white
        //This makes sure you cannot see the messages through the text bar.
        //Also gives the top message some padding from the navigation bar
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 58, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        
        setupInputComponents()
    }
    
    
    //Set the size of each cell being displayed
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Creates a height variable for the cell and gives it a base value
        var height: CGFloat = 80
        
        //Checks the message has text
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    
    //Gets an estimate for the size of a message cell based off of the text to be displayed.
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    
    //Sets the number of cells in the collection view
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Sets the number of cells to be displayed equal to the number of messages in "messages".
        return messages.count
    }
    
    
    //Controlls the content of each cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Creates a cell as an instance of "ChatMessageCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        
        //Retrieves the text of each message in the "messages" list
        let message = messages[indexPath.item]
        
        //Sets the "text" attribute of each cell equal to the text of one of the messages.
        cell.textView.text = message.text
        
        //Modify the message buble width
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
        
        return cell
    }
    
    
    //Setup the GUI
    func setupInputComponents() {
        //Set up container at the bottom of the screen
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        //Constraints for the container
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 83).isActive = true
        
        
        //Setup send button
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        
        //Constrain sendButton
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        //Add inputTextField to subview.
        containerView.addSubview(inputTextField)
        
        //Constraints for inputTextField
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        //Create separator to seperate the containerView from the rest of view
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(displayP3Red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(separatorLineView)
        
        //Constrain separatorLineView
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    

    //Uploads the text from the inputTextField to the cloud when called
    @objc func handleSend() {
        //Creates a reference to a new node in firebase "Messages"
        let ref = Database.database().reference().child("Messages")
        //Creates a unique ID for this particular message node
        let childRef = ref.childByAutoId()
        //Uploads text and recipient from the text field to the database.
        let toID = user!.id!
        let fromID = Auth.auth().currentUser!.uid
        let timeStap = NSDate().timeIntervalSince1970
        let values = ["text": inputTextField.text!, "toID": toID, "fromID": fromID, "timeStamp": timeStap] as [String : Any]
        
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
        //Clears the text field
        inputTextField.text = ""
    }
    
    
    //Allows the user to send a message by pressing the "Enter" key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
