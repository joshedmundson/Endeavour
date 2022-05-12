//
//  Message.swift
//  Endeavour
//
//  Created by Josh Edmundson on 18/02/2020.
//  Copyright © 2020 Josh Edmundson. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromID: String?
    var text: String?
    var timeStamp: NSNumber?
    var toID: String?

    
    func chatPartnerID() -> String? {
    
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
        
    }
    
}
