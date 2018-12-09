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
    
    // let ref: DatabaseReference! = Database.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        color = .random
        member = User(name: Auth.auth().currentUser?.displayName ?? "someuser", uid: Auth.auth().currentUser?.uid ?? "1234")
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        // add connection to new messages here
//        let text = "I love pizza, what is your favorite kind?"
//        let testMessage = Message(member: selectedUser, text: text, messageId: UUID().uuidString)
//        insertNewMessage(testMessage)
    }
    
    private func insertNewMessage(_ message: Message) {
        let ref = Constants.refs.databaseChats.child(member.name + selectedUser.name).childByAutoId()
        let messageJson = ["sender_id": message.member.uid, "name": message.member.name, "text": message.text]
        ref.setValue(messageJson)
        messagesCollectionView.scrollToBottom(animated: true)
        
        messages.append(message)
        messagesCollectionView.reloadData()
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
        
        let newMessage = Message(
            member: member,
            text: text,
            messageId: UUID().uuidString)
        
        let ref = Constants.refs.databaseChats.child(member.name + selectedUser.name).childByAutoId()
        let message = ["sender_id": member.uid, "name": member.name, "text": text]
        ref.setValue(message)
        
        messages.append(newMessage)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
}
