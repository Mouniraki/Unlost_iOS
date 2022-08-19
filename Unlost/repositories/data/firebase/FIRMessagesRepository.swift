//
//  FIRMessagesRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 01.08.22.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase
import UIKit

final class FIRMessagesRepository: MessagesRepository {
    private let auth = Auth.auth()
    private let fs = Firestore.firestore()
    private let db = Database.database()
    private let st = Storage.storage()
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId: String = ""
    @Published private(set) var isLoading: Bool = false
    
    func getMessages(convID: String) {
        if let userID = auth.currentUser?.uid {
            self.isLoading = true
            try? FileManager.default
                .createDirectory(at: documentsPath.appendingPathComponent("conversations_assets/\(convID)"),
                                 withIntermediateDirectories: true)
            
            fs.collection("Conversations")
                .document(convID)
                .collection("Messages")
                .addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot else {
                        print("Error while fetching messages")
                        return
                    }
                    
                    Task {
                        var messageTemp: [Message] = []
                        for document in snapshot.documents {
                            
                            let data = document.data()
                            let isReceived = (data["sender"] as! String) != userID
                            let timestamp = document.get("timestamp", serverTimestampBehavior: .estimate) as? Timestamp
                            
                            let message = Message(id: document.documentID,
                                                  isReceived: isReceived,
                                                  timestamp: DateTime.fromFIRTimestamp(from: timestamp ?? Timestamp.init(date: Date.now)))
                            
                            if let location = data["location"] as? GeoPoint {
                                messageTemp.append(
                                    LocationMessage.fromMessage(message: message, location: Location.fromFIRGeopoint(from: location)!)
                                )
                                
                            } else if let imageUrl = data["image_url"] as? String {
                                let imageFileURL = self.documentsPath.appendingPathComponent(imageUrl)
                                
                                if await self.downloadFile(strURL: imageUrl){
                                    messageTemp.append(
                                        PicMessage.fromMessage(message: message, imageURL: imageFileURL)
                                    )
                                }

                            } else if let audioUrl = data["audio_url"] as? String {
                                let audioFileURL = self.documentsPath.appendingPathComponent(audioUrl)
                                
//                                print("AUDIO FILE DOWNLOAD LOCATION: \(audioFileURL)")
                                
                                if await self.downloadFile(strURL: audioUrl) {
                                    messageTemp.append(
                                        AudioMessage.fromMessage(message: message, audioUrl: audioFileURL)
                                    )
                                }
                                
                            } else {
                                messageTemp.append(
                                    TextMessage.fromMessage(message: message, body: data["body"] as! String)
                                )
                            }
                        }
                        
                        self.messages = messageTemp.sorted { $0.timestamp < $1.timestamp }
                        
                        if let id = self.messages.last?.id {
                            self.lastMessageId = id
                        }
                        
                        self.isLoading = false
                    }

                }
        }
    }
    
    func sendMessage(convID: String, message: Message, _ completionHandler: @escaping (Bool) -> Void) {
        if let userID = auth.currentUser?.uid {
            
//            let prefix = convID.prefix(userID.count)
//            let interlocutorID = String(prefix == userID ? convID.suffix(userID.count) : prefix)

            var messageDict: [String: Any] = [
                "sender": userID as String,
                "timestamp": FieldValue.serverTimestamp()
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
        self.fs.collection("Conversations")
            .document(convID)
            .collection("Messages")
            .addDocument(data: data) { err in
                if err != nil {
                    print("ERROR: unable to add this message to the conversation")
                    completionHandler(false)
                    return
                }
                
                completionHandler(true)
            }
        
//        //TODO: PROVIDE LIST OF DEVICES TO PING
//        FIRNotificationsRepository().sendNotification(title: "\(auth.currentUser!.displayName!)",
//                                                      body: "New message",
//                                                      devices: []) { success in
//            completionHandler(success)
//        }
    }
    
    @MainActor
    private func downloadFile(strURL: String) async -> Bool {
        do {
            let gsReference = self.st.reference().child(strURL)
            
            let localFileURL = self.documentsPath.appendingPathComponent(strURL)
                    
            _ = try await gsReference.writeAsync(toFile: localFileURL)
            
            return true
        } catch {
            return false
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
