//
//  ChatViewController.swift
//  ChaosComs
//
//  Created by iguest on 12/3/18.
//  Copyright © 2018 Zubair Amjad. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar
import Firebase

class ChatViewController: MessagesViewController {
    var messages: [Message] = []
    var member: User!
    var color: UIColor = .blue
    var selectedUser: User!
    
    var initRef: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        color = .random
        member = User(name: Auth.auth().currentUser?.displayName ?? "someuser", uid: Auth.auth().currentUser?.uid ?? "1234")
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        initRef = Constants.refs.databaseChats.child(member.name + selectedUser.name)
        initRef.queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                let name = (snapshot.value as? NSDictionary)?["name"] as? String ?? "name"
                let id = (snapshot.value as? NSDictionary)?["sender_id"] as? String ?? "id"
                let text = (snapshot.value as? NSDictionary)?["text"] as? String ?? "text"
                
                let user: User!
                if name == self.member.name {
                    user = self.member
                } else {
                    user = self.selectedUser
                }
                
                let loadMsg = Message(member: user, text: text, messageId: id)
                self.messages.append(loadMsg)
                self.messagesCollectionView.reloadData()
            }
        })
        
        
        self.messagesCollectionView.scrollToBottom(animated: true)
        
        // test message
//        let text = "Hello again, I'm still a phantom"
//        let testMessage = Message(member: selectedUser, text: text, messageId: UUID().uuidString)
//        insertNewMessage(testMessage)
    }
    
    private func insertNewMessage(_ message: Message) {
        let ref = Constants.refs.databaseChats.child(member.name + selectedUser.name).childByAutoId()
        let messageJson = ["sender_id": message.member.uid, "name": message.member.name, "text": message.text]
        ref.setValue(messageJson)
        
        messagesCollectionView.scrollToBottom(animated: true)
    }

}

extension ChatViewController: MessagesDataSource {
    func numberOfSections(
        in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return Sender(id: member.uid, displayName: member.name)
    }
    
    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 12
    }
    
    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView)
    {
        //let message = messages[indexPath.section]
        //let color = message.member.color
        avatarView.backgroundColor = self.color
    }
}

extension ChatViewController: MessageInputBarDelegate {
    func messageInputBar(
        _ inputBar: MessageInputBar,
        didPressSendButtonWith text: String) {
        
        let ref = Constants.refs.databaseChats.child(member.name + selectedUser.name).childByAutoId()
        let message = ["sender_id": member.uid, "name": member.name, "text": text]
        ref.setValue(message)
        
        inputBar.inputTextView.text = ""
    }
}
