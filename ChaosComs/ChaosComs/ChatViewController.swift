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
    
    var videoID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        color = .random
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        print(member)
        
        if member.name < selectedUser.name {
            initRef = Constants.refs.databaseChats.child(member.name + selectedUser.name)
        } else {
            initRef = Constants.refs.databaseChats.child(selectedUser.name + member.name)
        }
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
    
    func startRequestData(query: String, text: String, ref: DatabaseReference) {
        
        let params: [String: Any] = ["part":"snippet", "q":"\(query)", "type":"video", "key":"AIzaSyAdV6HRuk3Cz7MgNXbBzClwqlZDjBVOaJc"]
        var thumbnailURL = ""
        
        AF.request("https://www.googleapis.com/youtube/v3/search", method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if let JSON = response.result.value  as?  [String : Any] {
                if let items =  JSON["items"] as? [[String : Any]] {
                    let item = items[0]
                    let ids = item["id"] as? NSDictionary
                    let vidID = (ids?["videoId"] as? String)!
                    let itemDescription = item["snippet"] as? NSDictionary
                    let thumbnails = itemDescription?["thumbnails"] as? NSDictionary
                    let defaultThumbnail = thumbnails?["medium"] as? NSDictionary
                    let defaultURL = defaultThumbnail?["url"] as? String
                    thumbnailURL = defaultURL ?? ""
                    self.videoID = vidID
                    print(vidID)
                    // print(item)
                    let message = ["sender_id": self.member.uid, "name": self.member.name, "text": text, "vidID": vidID]
                    //let imageMessage = ["sender_id": self.member.uid, "name": self.member.name, "vidID": vidID, "imageURL": thumbnailURL]
                    ref.setValue(message)
                    //let Newref = Constants.refs.databaseChats.child(self.member.name + self.selectedUser.name).childByAutoId()
                    //Newref.setValue(imageMessage)
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
        // self.namedEntityRecognition(for: text, messageText: text, ref: ref)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? YoutubeController {
            print(self.videoID)
            if (self.videoID == "") {
                self.videoID = "IYnsfV5N2n8"
                target.videoID = self.videoID
                
            } else {
                target.videoID = self.videoID
            }
        }
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
        
        self.namedEntityRecognition(for: text, messageText: text, ref: ref)

        inputBar.inputTextView.text = ""
    }
}

//extension ChatViewController: MessageCellDelegate {
//    func didTapMessage(in cell: MessageCollectionViewCell) {
//        print("YAYY")
//    }
//}
