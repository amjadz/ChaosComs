//
//  Message.swift
//  ChaosComs
//
//  Created by iguest on 12/4/18.
//  Copyright © 2018 Zubair Amjad. All rights reserved.
//

import Foundation
import UIKit
import MessageKit
import Firebase

struct Constants {
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
    }
}

struct Member {
    let name: String
    let uid: String
    let email: String
    //let color: UIColor
}

extension Member {
    var toJSON: Any {
        return [
            "name": name,
            "uid": uid,
            "email": email,
            //"color": color.hexString
        ]
    }
    
    init?(fromJSON json: Any) {
        guard
            let data = json as? [String: Any],
            let name = data["name"] as? String,
            let uid = data["uid"] as? String,
            let email = data["email"] as? String
            //let hexColor = data["color"] as? String
            else {
                print("Couldn't parse Member")
                return nil
        }
        
        self.name = name
        self.email = email
        self.uid = uid
        //self.color = UIColor(hex: hexColor)
    }
}

struct Message {
    let member: Member
    let text: String
    let messageId: String
}

extension Message: MessageType {
    var sender: Sender {
        return Sender(id: member.uid, displayName: member.name)
    }
    
    var sentDate: Date {
        return Date()
    }
    
    var kind: MessageKind {
        return .text(text)
    }
}
