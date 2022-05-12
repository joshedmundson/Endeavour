//
//  ChatMessageCell.swift
//  Endeavour
//
//  Created by Josh Edmundson on 16/03/2020.
//  Copyright © 2020 Josh Edmundson. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    //Creates an attribute "textView" for the class that will allow me to display message text
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "Sample text for now"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.textColor = .white
        return tv
    }()
    
    //Create the background text bubble for each message.
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(displayP3Red: 22/255, green: 160/255, blue: 133/255, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    
    //Set up a variable that will allow me to access and modify the bubbleView's width externally
    var bubbleWidthAnchor: NSLayoutConstraint?
    
    
    //Override the constructor function
    override init(frame: CGRect) {
        //Inherit "frame" from the parent class
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        
        //Set up constraints for the "bubbleView"
        bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //Set up the constraints for "textView"
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    //This is an extra peice of code needed to make the above "override init" work. 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


