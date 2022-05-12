//
//  LoginRegisterScreen.swift
//  Endeavour
//
//  Created by Josh Edmundson on 26/01/2020.
//  Copyright © 2020 Josh Edmundson. All rights reserved.
//

import UIKit
import Firebase

class LoginRegisterScreen: UIViewController {
    
    var chatScreen: ChatScreen?
    
    //Creates the container to hold the text fields
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    
    //Create the input field for the user's name.
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    
    //This will create a UIView to seperate the name text field from the emailTextField
    let nameSeparatorView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(displayP3Red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    //Create email text field
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    //Create the email and password text field seperator
    let emailSeparatorView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(displayP3Red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    //Creates the password text field
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true //This will hide the user input.
        return tf
    }()
    
    
    //Create the login/register button
    let loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(displayP3Red: 41/255, green: 128/255, blue: 185/255, alpha: 1)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        //Always set this to false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        //Makes the button run the handleRegisterFunction when the user releases the button within its boundary
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    
    //Create segmented controller
    let loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //Change the background colour to "Green Sea"
        view.backgroundColor = UIColor(displayP3Red: 22/255, green: 160/255, blue: 133/255, alpha: 1.0)
        
        //Add all subviews to the screen
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(loginRegisterSegmentedControl)
        
        
        //Create subview dimensions using constraints
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupLoginRegisterSegmentedControl()
    }
    
    
    //This is called when switiching between segments in the segmented control.
    @objc func handleLoginRegisterChange() {
        //Set up two variables base on the current segment selected
        let currentIndex = loginRegisterSegmentedControl.selectedSegmentIndex
        let title = loginRegisterSegmentedControl.titleForSegment(at: currentIndex)
        
        //Update the text on the loginRegisterButton accordingly
        loginRegisterButton.setTitle(title, for: .normal)
        
        //Change height of inputContainerView based on the current index
        inputsContainerViewHeightAnchor?.constant = currentIndex == 0 ? 100 : 150
        
        //Change height of nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: currentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //Change the height of the emailTextField
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: currentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //Change the height of the passwordTextField
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: currentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    
    //This function determins whether the user is trying to login
    //or register and runs the corresponding function
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    
    //This function will sign the user in.
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            (user, error) in
            
            if error != nil {
                print(error as Any)
                return
            }
            
            //self.cleanUpChatScreenTable()
            
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    
    //This function attempts to refresh the list of chats when you log back in
    //but unfortunately, it doesn't work.
    func cleanUpChatScreenTable() {
        print("logging in")
        self.chatScreen?.messages.removeAll()
        self.chatScreen?.messagesDictionary.removeAll()
        self.chatScreen?.tableView.reloadData()
        self.chatScreen?.observeUserMessages()
    }
    
    
    //This function will register a new user
    @objc func handleRegister() {
        //This checks the inputs for email and password are actually valid
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
    
        //This creates a Firebase user using the inputs in the email and password fields.
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            //This if statement is there to catch any errors
            if let err = error {
                print(err)
                return
            }
            
            //Save the new user to the database
            //Here, we create a variable that will reference the database.
            var ref: DatabaseReference!
            ref = Database.database().reference(fromURL: "https://endeavour-c6824.firebaseio.com/")
            
            //Create a dictionary of the values we want to store in the database
            let values: Dictionary = ["name": name, "email": email]
            let userID = Auth.auth().currentUser!.uid
            
            //Add the new user's name and email to the database
            //to the database beneath the child nodes "Users"
            //and a unique id generated by childByAutoId
            ref.child("Users").child(userID).updateChildValues(values, withCompletionBlock: {
                (error, ref) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                print("Saved user sccessfully")
                self.dismiss(animated: true, completion: nil)
            })
            
        }
        
    }
    
    
    //Set up constraints for loginRegisterSegmentedControl
    func setupLoginRegisterSegmentedControl() {
        //Setup constraints
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    
    //Create variables that can change the layout constraints of the view
    //and that can be accessed outisde of setupInputsContainerView()
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    
    //This sets the constraints of the subview so the program knows how to display it.
    func setupInputsContainerView() {
        //Constraints: x, y, z, width, height
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        
        //We replaced the hard coded height anchor with a variable that we can access outside
        //of inputsContainerView, which will allow us to change the height.
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        
        //Add subviews
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        
        //Set up the constraints for nameTextField
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        //Place the height anchor wihin the variable nameTextFieldHeightAnchor
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //Set up the constraints for nameSeparatorView
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: nameTextField.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        //Set up the constraints for emailTextField
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        //Place the height anchor wihin the variable emailTextFieldHeightAnchor
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //Set up constraints for emailSeparatorView
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: nameTextField.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        //Set up constraints for passwordTextField
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        //Place the height anchor wihin the variable paswordTextFieldHeightAnchor
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
    }
    
    
    //Function to setup all the constraints neccessary to give loginRegisterButton dimensions and a position on the screen
    func setupLoginRegisterButton() {
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

}
