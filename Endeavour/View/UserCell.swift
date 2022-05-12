//
//  UserCell.swift
//  Endeavour
//
//  Created by Josh Edmundson on 20/02/2020.
//  Copyright © 2020 Josh Edmundson. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            
            setupName()
            
            //Sets the subtext of the cell equal to the contents of the message.
            self.detailTextLabel?.text = message?.text
            self.detailTextLabel?.textColor = UIColor.darkGray
            
            //Check that the current message has a time stamp
            //If it does, format the timestamp to a date and set the text of timeLabel
            //equal to the date.
            if let seconds = message?.timeStamp?.doubleValue {
                let timeStampDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timeStampDate as Date)
                
            }
        }
    }
    
    
    private func setupName() {
        
        if let id = message?.chatPartnerID() {
            //Creates a reference to the message node with a matching toID value.
            let ref = Database.database().reference().child("Users").child(id)
            
            //Takes a snapshot of the values that extend the message ID.
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    //Sets the value of the cell's text to the value stored at the child node "name".
                    self.textLabel?.text = dictionary["name"] as? String
                    
                }
                
            })
        }
    }
    
    
    //Creates a time stap at the edge of the message cell
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    //Changes the default style of the cell.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(timeLabel)
        
        //Constraints for timeLabel
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        //timeLabel.centerYAnchor.constraint(equalTo: textLabel!.centerYAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
