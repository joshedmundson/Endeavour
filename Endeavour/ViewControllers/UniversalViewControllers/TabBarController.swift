//
//  TabBarController.swift
//  Endeavour
//
//  Created by Josh Edmundson on 26/01/2020.
//  Copyright © 2020 Josh Edmundson. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets up the tab bar
        setupTabBar()
    }
    
    
    //Creates two navigation controllers and places them whithin our custom view controllers
    func setupTabBar() {
        
        //Creates two instances of UINavigationController within the screens
        let goalTrackerScreen = UINavigationController(rootViewController: GoalTrackerScreen())
        let chatScreen = UINavigationController(rootViewController: ChatScreen())
        
        //Creates a tabBarItem for each of the two screens. Add icons later.
        goalTrackerScreen.tabBarItem.title = "Goals"
        goalTrackerScreen.tabBarItem.image = UIImage(named: "goals_pin_unselected")
        goalTrackerScreen.tabBarItem.selectedImage = UIImage(named: "goals_pin_selected")
        
        chatScreen.tabBarItem.title = "Chats"
        chatScreen.tabBarItem.image = UIImage(named: "messages_unselected")
        chatScreen.tabBarItem.selectedImage = UIImage(named: "messages_selected")
        
        //Adds the view controllers to the tab bar
        viewControllers = [goalTrackerScreen, chatScreen]
    }
    
    

}
