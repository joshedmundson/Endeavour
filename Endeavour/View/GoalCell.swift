//
//  GoalCell.swift
//  Endeavour
//
//  Created by Josh Edmundson on 26/02/2020.
//  Copyright © 2020 Josh Edmundson. All rights reserved.
//

import UIKit
import Firebase

class GoalCell: UITableViewCell {
    
    //Give GoalCell the attribute "goal" of type "Goal?"
    var goal: Goal? {
        
        //"didSet" will run as soon as "goal" is assigned a value
        didSet {
            
            //Sets the text of the cell to the goal's name
            self.textLabel?.text = goal?.name
            
            //Unwraps the endDate property of goal
            guard let endDate = goal?.endDate else{
                return
            }
            
            //Sets the subtext of the cell to the end date and alters its colour
            self.detailTextLabel?.text = "End date: " + endDate
            self.detailTextLabel?.textColor = UIColor.darkGray
        }
    }
    
    
    //Changes the default style of the cell.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
