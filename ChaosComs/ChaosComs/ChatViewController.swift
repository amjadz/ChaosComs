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
import youtube_ios_player_helper

class ChatViewController: MessagesViewController {
    var messages: [Message] = []
    var member: User!
    var color: UIColor = .blue
    var selectedUser: User!
    
    var initRef: DatabaseReference!
    
    @IBOutlet weak var backBar: UIToolbar!
    
    var videoID = ""
    
    let tagger: NSLinguisticTagger = NSLinguisticTagger(tagSchemes: [.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)
    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    
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
                let text = (snapshot.value as? NSDictionary)?["text"] as? String
                let vidID = (snapshot.value as? NSDictionary)?["vidID"] as? String ?? ""
                let imageURL = (snapshot.value as? NSDictionary)?["imageURL"] as? String ?? "imageURL"
                
                self.videoID = vidID
                print(self.videoID)
                
                let user: User!
                if name == self.member.name {
                    user = self.member
                } else {
                    user = self.selectedUser
                }
                
                if (text != nil) {
                    let img = UIImageView()
                    let loadMsg = Message(member: user, text: text!, messageId: id, videoID: vidID, imageURL: imageURL, image: img)
                    self.messages.append(loadMsg)
                    self.messagesCollectionView.reloadData()
                }
            }
        })
        
        self.messagesCollectionView.scrollToBottom(animated: true)
        self.view.bringSubviewToFront(backBar)
    }
    
    private func insertNewMessage(_ message: Message) {
        let ref = Constants.refs.databaseChats.child(member.name + selectedUser.name).childByAutoId()
        let messageJson = ["sender_id": message.member.uid, "name": message.member.name, "text": message.text]
        ref.setValue(messageJson)
        
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    
    
    func startRequestData(query: String, text: String, ref: DatabaseReference) {
        
        let params: [String: Any] = ["part":"snippet", "q":"\(query)", "type":"video", "key":"AIzaSyAdV6HRuk3Cz7MgNXbBzClwqlZDjBVOaJc"]
        var vidID = ""
        var thumbnailURL = ""
        
        AF.request("https://www.googleapis.com/youtube/v3/search", method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if let JSON = response.result.value  as?  [String : Any] {
                if let items =  JSON["items"] as? [[String : Any]] {
                    let item = items[0]
                    let ids = item["id"] as? NSDictionary
                    vidID = (ids?["videoId"] as? String)!
                    let itemDescription = item["snippet"] as? NSDictionary
                    let thumbnails = itemDescription?["thumbnails"] as? NSDictionary
                    let defaultThumbnail = thumbnails?["medium"] as? NSDictionary
                    let defaultURL = defaultThumbnail?["url"] as? String
                    thumbnailURL = defaultURL ?? ""
                    // print(item)
                    let message = ["sender_id": self.member.uid, "name": self.member.name, "text": text]
                    let imageMessage = ["sender_id": self.member.uid, "name": self.member.name, "vidID": vidID, "imageURL": thumbnailURL]
                    ref.setValue(message)
                    let Newref = Constants.refs.databaseChats.child(self.member.name + self.selectedUser.name).childByAutoId()
                    Newref.setValue(imageMessage)
                    self.videoID = vidID
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? YoutubeController {
            if (self.videoID == "") {
                self.videoID = "IYnsfV5N2n8"
            } else {
                target.videoID = self.videoID
            }
        }
    }
    
    
    func loadImageOnly(member: User, messageId: String, vidID: String, imageURL: String) {
        let imageUrl:URL = URL(string: imageURL)!
        
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData:NSData = NSData(contentsOf: imageUrl)!
            DispatchQueue.main.async {
                let image = UIImage(data: imageData as Data)
                let view = UIImageView()
                view.image = image
                let loadmsg = Message(member: member, text: "", messageId: messageId, videoID: vidID, imageURL: imageURL, image: view)
                self.messages.append(loadmsg)
                self.messagesCollectionView.reloadData()
            }
        }
    }
    
    private func determineLanguage(for text: String) {
        tagger.string = text
        let language = tagger.dominantLanguage
        print("The language is \(language)")
        //tokenizeText(for: text)
        //partsOfSpeech(for: text)
        // namedEntityRecognition(for: text)
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
    
    
    private func namedEntityRecognition(for text: String, messageText: String, ref: DatabaseReference) {
        tagger.string = text
        var textTags: [String] = []
        let range = NSRange(location: 0, length: text.utf16.count)
        let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName, .noun, .verb, .adjective]
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange, stop in
            if let tag = tag, tags.contains(tag) {
                let name = (text as NSString).substring(with: tokenRange)
                textTags.append(name)
                print("\(name): \(tag.rawValue)")
            }
        }
        if (textTags.count == 0) {
            startRequestData(query: "asdf", text: messageText, ref: ref)
        } else if (textTags.count == 1) {
            startRequestData(query: textTags[0], text: messageText, ref: ref)
        } else {
            startRequestData(query: "\(String(describing: textTags.randomElement())) \(String(describing: textTags.randomElement()))", text: messageText, ref: ref)
        }
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
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
            string: "Stoneee",
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
        self.namedEntityRecognition(for: text, messageText: text, ref: ref)
        
        //let message = ["sender_id": member.uid, "name": member.name, "text": text]
        //ref.setValue(message)
        
        inputBar.inputTextView.text = ""
    }
}
