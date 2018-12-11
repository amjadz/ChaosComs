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


struct User {
    let name: String
    let uid: String
}

extension User {
    var toJSON: Any {
        return [
            "name": name,
            "uid": uid,
            //"color": color.hexString
        ]
    }
    
    init?(fromJSON json: Any) {
        guard
            let data = json as? [String: Any],
            let name = data["name"] as? String,
            let uid = data["uid"] as? String
            //let hexColor = data["color"] as? String
            else {
                print("Couldn't parse User")
                return nil
        }
        
        self.name = name
        self.uid = uid
        //self.color = UIColor(hex: hexColor)
    }
}

struct Message {
    let member: User
    let text: String
    let messageId: String
    let videoID: String
    let imageURL: String
    let image: UIImageView
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
