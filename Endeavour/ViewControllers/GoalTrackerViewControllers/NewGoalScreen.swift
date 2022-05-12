//
//  NewGoalScreen.swift
//  Endeavour
//
//  Created by Josh Edmundson on 24/02/2020.
//  Copyright © 2020 Josh Edmundson. All rights reserved.
//

import UIKit
import Firebase

class NewGoalScreen: UIViewController {
    
    var goalPickerDate: String = ""
    
    /* Define all the UI elements */
    
    //Set up the "Goal Name" text field
    let goalNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Goal Name"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    
    //Set up the "Accountablility" text field
    let accountabilityTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Peer's Email"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    
    //Set up the UIDatePicker
    let goalEndDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = UIDatePicker.Mode.date
        dp.minimumDate = NSDate() as Date
        dp.addTarget(self, action: #selector(changeGoalPickerDate(datePicker:)), for: .valueChanged)
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()
    
    
    //Set up the submit button
    let submitButton: UIButton = {
        let bn = UIButton(type: .system)
        bn.backgroundColor = UIColor(displayP3Red: 22/255, green: 160/255, blue: 133/255, alpha: 1.0)
        bn.setTitleColor(UIColor.white, for: .normal)
        bn.setTitle("Create Goal", for: .normal)
        bn.layer.cornerRadius = 5
        bn.addTarget(self, action: #selector(createNewGoal), for: .touchUpInside)
        bn.translatesAutoresizingMaskIntoConstraints = false
        return bn
    }()
    
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the background colour
        view.backgroundColor = .white
        
        //Set the view title
        title = "New Goal"
        
        //Adds a cancel button to the navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        
        //Adds all the subviews
        view.addSubview(goalNameTextField)
        view.addSubview(accountabilityTextField)
        view.addSubview(goalEndDatePicker)
        view.addSubview(submitButton)
        
        //Set up all UI constraints
        setupGoalNameTextField()
        setupAccountablilityTextField()
        setupGoalEndDatePicker()
        setupSubmitButton()
    }
    
    
    
    //Dismisses the view when called
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //Sets the end date of the goal based on the goal picker reading
    @objc func changeGoalPickerDate(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        goalPickerDate = dateFormatter.string(from: datePicker.date)
    }
    
    
    //Gets the current date and returns it as a string
    func getCurrentDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let currentDateString = dateFormatter.string(from: currentDate)
        return currentDateString
    }
    
    
    //Uploads the goal to Firebase and creates a reference for it under "User-Goals"
    @objc func createNewGoal() {
        
        //Creates a reference to a node called "Goals" in Firebase
        let ref = Database.database().reference().child("Goals")
        
        //Sets up another reference, this time to an auto-generate child node of "Goals"
        let childRef = ref.childByAutoId()
        
        //Get the values found in the various input UI elements
        let goalName = goalNameTextField.text!
        let email = accountabilityTextField.text!
        let startDate = getCurrentDate()
        let endDate = goalPickerDate
        
        //Store the user input as a dictionary
        let values = ["name": goalName, "accountabilityEmail": email, "startDate": startDate, "endDate": endDate] as [String : Any]
        
        //Upload the user input to Firebase as a goal
        childRef.updateChildValues(values) { (error, ref) in
            
            //Checks for and catches any errors
            if error != nil{
                print(error as Any)
                return
            }
            
            //Unwraps goalID
            guard let goalID = childRef.key else {
                return
            }
            
            //Gets the current users unique Firebase ID
            let currentUID = Auth.auth().currentUser!.uid
            
            //Creates a new database reference to "currentUID" as a sub-node of "User Goals"
            let userGoalRef = Database.database().reference().child("User-Goals").child(currentUID)
            
            //Uploads the goal ID as a sub-node of the user's ID
            userGoalRef.updateChildValues([goalID: true])
        }
        
        //Dismisses itself.
        handleCancel()
    }
    
    
    /* Defines the functions that will set up the UI constraints*/
    
    //Sets up the constraints for goalNameTextField
    func setupGoalNameTextField() {
        goalNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        goalNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        goalNameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        goalNameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -36).isActive = true
    }
    
    
    //Sets up th constraints for accountabilityTextField
    func setupAccountablilityTextField() {
        accountabilityTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        accountabilityTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        accountabilityTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        accountabilityTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -36).isActive = true
    }
    
    
    //Sets up the constraints for goalEndDatePicker
    func setupGoalEndDatePicker() {
        goalEndDatePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 250).isActive = true
        goalEndDatePicker.heightAnchor.constraint(equalToConstant: 300).isActive = true
        goalEndDatePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        goalEndDatePicker.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
    }
    
    
    //Sets up the constraints for the submit button
    func setupSubmitButton() {
        submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        submitButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -72).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
}
