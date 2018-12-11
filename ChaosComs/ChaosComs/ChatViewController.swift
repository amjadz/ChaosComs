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
import Alamofire

class ChatViewController: MessagesViewController {
    var messages: [Message] = []
    var member: User!
    var color: UIColor = .blue
    var selectedUser: User!
    var initRef: DatabaseReference!
    
    @IBAction func goBackToSelectUser(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    let tagger: NSLinguisticTagger = NSLinguisticTagger(tagSchemes: [.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)
    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    
    @IBOutlet weak var backBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        color = .random
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        if member.name < selectedUser.name {
            initRef = Constants.refs.databaseChats.child(member.name + selectedUser.name)
        } else {
            initRef = Constants.refs.databaseChats.child(selectedUser.name + member.name)
        }
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
        self.view.bringSubviewToFront(backBar)
        
        // test message
//        let text = "Hello again, I'm still a phantom"
//        let testMessage = Message(member: selectedUser, text: text, messageId: UUID().uuidString)
//        insertNewMessage(testMessage)
    }
    
    func startRequestData(query: String) {
        
        let params: [String: Any] = ["part":"snippet", "q":"\(query)", "type":"video", "key":"AIzaSyAdV6HRuk3Cz7MgNXbBzClwqlZDjBVOaJc"]
        
        AF.request("https://www.googleapis.com/youtube/v3/search", method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if let JSON = response.result.value  as?  [String : Any] {
                
                if let items =  JSON["items"] as? [[String : Any]] {
                    let item = items[0]
                    let ids = item["id"] as? NSDictionary
                    //self.vidID = (ids?["videoId"] as? String)!
                    //print(self.vidID)
                    //self.playerView.load(withVideoId: self.vidID)
                    let itemDescription = item["snippet"] as? NSDictionary
                    let thumbnails = itemDescription?["thumbnails"] as? NSDictionary
                    let defaultThumbnail = thumbnails?["medium"] as? NSDictionary
                    let defaultURL = defaultThumbnail?["url"] as? String
                    print(item)
                    //print(defaultURL)
                    //self.loadImage(img: defaultURL ?? "")
                }
            }
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        let ref = initRef.childByAutoId()
        let messageJson = ["sender_id": message.member.uid, "name": message.member.name, "text": message.text]
        ref.setValue(messageJson)
        
        messagesCollectionView.scrollToBottom(animated: true)
    }

    
    private func determineLanguage(for text: String) {
        tagger.string = text
        let language = tagger.dominantLanguage
        print("The language is \(language)")
        //tokenizeText(for: text)
        //partsOfSpeech(for: text)
        namedEntityRecognition(for: text)
    }
    
    private func tokenizeText(for text: String) {
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { tag, tokenRange, stop in
            let word = (text as NSString).substring(with: tokenRange)
            print(word)
        }
    }
    
    private func partsOfSpeech(for text: String) {
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange, _ in
            if let tag = tag {
                let word = (text as NSString).substring(with: tokenRange)
                print("\(word): \(tag.rawValue)")
            }
        }
    }
    
    private func namedEntityRecognition(for text: String) {
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName, .noun, .verb]
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange, stop in
            if let tag = tag, tags.contains(tag) {
                let name = (text as NSString).substring(with: tokenRange)
                print("\(name): \(tag.rawValue)")
            }
        }
    }
    
//    private func loadImage(img: String) {
//        let imageUrl:URL = URL(string: img)!
//        
//        // Start background thread so that image loading does not make app unresponsive
//        DispatchQueue.global(qos: .userInitiated).async {
//            
//            let imageData:NSData = NSData(contentsOf: imageUrl)!
//            let imageView = self.imgContainer
//            imageView?.center = self.view.center
//            let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tappedImage))
//            self.imgContainer.isUserInteractionEnabled = true
//            self.imgContainer.addGestureRecognizer(singleTap)
//            
//            // When from background thread, UI needs to be updated on main_queue
//            DispatchQueue.main.async {
//                let image = UIImage(data: imageData as Data)
//                imageView?.image = image
//            }
//        }
//    }
//    
//    @objc func tappedImage() {
//        print("tapped image")
//        
//    }
    
    

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
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
            string: member.name,
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
        
        let ref = initRef.childByAutoId()
        let message = ["sender_id": member.uid, "name": member.name, "text": text]
        ref.setValue(message)
        
        self.namedEntityRecognition(for: text)
        
        inputBar.inputTextView.text = ""
    }
}

//extension ChatViewController: MessageCellDelegate {
//    func didTapMessage(in cell: MessageCollectionViewCell) {
//        print("YAYY")
//    }
//}
