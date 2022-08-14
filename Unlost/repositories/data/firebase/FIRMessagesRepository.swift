//
//  FIRMessagesRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 01.08.22.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

final class FIRMessagesRepository: MessagesRepository {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let st = Storage.storage()
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId: String = ""
    
    //TODO: IMPLEMENT LOADING OF IMAGES AND AUDIO MESSAGES
    func getMessages(convID: String) {
        if let userID = auth.currentUser?.uid {
            try? FileManager.default
                .createDirectory(at: documentsPath.appendingPathComponent("conversations_assets/\(convID)"),
                                 withIntermediateDirectories: true)
            
            db.collection("Conversations")
                .document(convID)
                .collection("Messages")
                .addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot else {
                        print("Error while fetching messages")
                        return
                    }
                    
                    self.messages = snapshot.documents.map { document in
                        let data = document.data()
                        let isReceived = (data["sender"] as! String) != userID
                        
                        let message = Message(id: document.documentID,
                                              isReceived: isReceived,
                                              timestamp: DateTime.fromFIRTimestamp(from: data["timestamp"] as! Timestamp))
                        
                        if let location = data["location"] as? GeoPoint {
                            return LocationMessage.fromMessage(message: message, location: Location.fromFIRGeopoint(from: location)!)
                            
                        } else if let imageUrl = data["image_url"] as? String {
                            
                            let imageFileURL = self.documentsPath.appendingPathComponent(imageUrl)
                            
                            self.downloadFile(strURL: imageUrl){ success in
//                                self.getMessages(convID: convID)
                                //TODO: IMPLEMENT HANDLER
                            }

                            return PicMessage.fromMessage(message: message, imageURL: imageFileURL)
                            
                        } else if let audioUrl = data["audio_url"] as? String {
                            let audioFileURL = self.documentsPath.appendingPathComponent(audioUrl)
                            
                            print("AUDIO FILE DOWNLOAD LOCATION: \(audioFileURL)")
                            
                            self.downloadFile(strURL: audioUrl) { success in
                                //TODO: IMPLEMENT HANDLER
//                                self.getMessages(convID: convID)
                            }
                            
                            return AudioMessage.fromMessage(message: message, audioUrl: audioFileURL)
                            
                        } else {
                            return TextMessage.fromMessage(message: message, body: data["body"] as! String)
                        }
                    }.sorted { $0.timestamp < $1.timestamp }
                    
                    if let id = self.messages.last?.id {
                        self.lastMessageId = id
                    }
                }
        }
    }
    
    func sendMessage(convID: String, message: Message, _ completionHandler: @escaping (Bool) -> Void) {
        if let userID = auth.currentUser?.uid {
            
            let prefix = convID.prefix(userID.count)
            let interlocutorID = String(prefix == userID ? convID.suffix(userID.count) : prefix)
            
            
            
            var messageDict: [String: Any] = [
                "sender": (message.isReceived ? interlocutorID : userID) as String,
                "timestamp": message.timestamp.toFIRTimestamp() as Timestamp
            ]
            
            if let locMsg = message as? LocationMessage {
                messageDict["location"] = locMsg.coordinates.toFIRGeopoint()
                self.sendMessageRoutine(convID: convID, data: messageDict, completionHandler)
                
            } else if let picMsg = message as? PicMessage {
                //TODO: MAYBE OFFLOAD THIS TO A SEPARATE METHOD
                
                if let data = self.loadImage(imgUrl: picMsg.imageURL).jpegData(compressionQuality: 0.6) {
                    let FIRstoragePath = "conversations_assets/\(convID)/JPEG_\(picMsg.timestamp.seconds).jpg"
                    
                    // SAVE IMAGE TO LOCAL CACHE
                    let localStorage = self.documentsPath.appendingPathComponent(FIRstoragePath)
                    if (try? data.write(to: localStorage)) != nil {
                        
                        let picReference = self.st.reference().child(FIRstoragePath)
                        
                        picReference.putData(data, metadata: nil) { metadata, error in
                            guard error == nil else {
                                print("ERROR: unable to upload image")
                                completionHandler(false)
                                return
                            }
                            
                            messageDict["image_url"] = FIRstoragePath
                            
                            //SEND MESSAGE ONLY NOW
                            self.sendMessageRoutine(convID: convID, data: messageDict, completionHandler)
                            
                        }
                    } else {
                        completionHandler(false)
                        return
                    }
                }
            } else if let audioMsg = message as? AudioMessage {
                let FIRAudioPath = "conversations_assets/\(convID)/\(audioMsg.audioUrl.lastPathComponent)"
                let audioReference = self.st.reference().child(FIRAudioPath)
                
                audioReference.putFile(from: audioMsg.audioUrl, metadata: nil){ metadata, error in
                    guard error == nil else {
                        print("ERROR: unable to upload audio file")
                        completionHandler(false)
                        return
                    }
                    
                    messageDict["audio_url"] = FIRAudioPath
                    
                    // SEND MESSAGE ONLY NOW
                    self.sendMessageRoutine(convID: convID, data: messageDict, completionHandler)
                    
                }
            } else if let txtMsg = message as? TextMessage {
                messageDict["body"] = txtMsg.body
                self.sendMessageRoutine(convID: convID, data: messageDict, completionHandler)
            }
        }
    }
    
    private func sendMessageRoutine(convID: String, data: [String: Any], _ completionHandler: @escaping (Bool) -> Void) {
        self.db.collection("Conversations")
            .document(convID)
            .collection("Messages")
            .addDocument(data: data) { err in
                if err != nil {
                    print("ERROR: unable to add this message to the conversation")
                    completionHandler(false)
                    return
                }
            }
        
        //TODO: PROVIDE LIST OF DEVICES TO PING
        FIRNotificationsRepository().sendNotification(title: "\(auth.currentUser!.displayName!)",
                                                      body: "New message",
                                                      devices: []) { success in
            completionHandler(success)
        }
    }
    
    private func downloadFile(strURL: String, _ completionHandler: @escaping (Bool) -> Void) {
        let gsReference = self.st.reference().child(strURL)
        
        let localFileURL = self.documentsPath.appendingPathComponent(strURL)
                
        gsReference.write(toFile: localFileURL) { url, error in
            if error != nil {
                // PERFORM ACTIONS
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
    }
    
    // USED ONLY TO COMPRESS IMAGES
    private func loadImage(imgUrl: URL) -> UIImage {
        if let imgData = try? Data(contentsOf: imgUrl), let loaded = UIImage(data: imgData) {
            return loaded
        } else {
            return UIImage()
        }
    }
}
