//
//  ChatView.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import SwiftUI
import CoreLocation
import AVKit
import Combine

//TODO: FIND A WAY TO HIDE THE TABVIEW BAR AT THE BOTTOM
struct ChatView: View {
    @EnvironmentObject var signInRepo: GoogleSignInRepo
    @EnvironmentObject var messagesRepo: FIRMessagesRepository
    
    let conversation: Conversation
    
    let audioRecorder = AudioRecorder()
    
    @State private var messageStr = ""
    @State private var showSendMessageBtn = false
    
    /// For the PicMessages
    @State private var showSheet = false
    @State private var pickFromCamera: Bool = false
    
    /// For the AudioMessages
    @State private var isRecording = false
    
    /// For the LocationMessages
    @StateObject var locationService = LocationService.shared
    
    /// Error handling pop-ups
    @State private var displayNoLocationAlert = false
    @State private var displaySendErrorAlert = false
    @State private var displayNoMicPermissionsAlert = false
    @State private var displayNoCameraPermissionsAlert = false
    
    var body: some View {
        //TODO: FIGURE OUT HOW TO FOCUS THE VIEW ON THE LAST MESSAGES PERMANENTLY
        VStack {
            if messagesRepo.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                if messagesRepo.messages.isEmpty {
                    Spacer()
                    Text("No messages for the moment")
                    Spacer()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            ForEach(messagesRepo.messages, id: \.id) { message in
                                switch message {
                                case is PicMessage: PicMessageLayout(message: message as! PicMessage)
                                    
                                case is LocationMessage: LocationMessageLayout(message: message as! LocationMessage)
                                    
                                case is AudioMessage: AudioMessageLayout(message: message as! AudioMessage)
                                    
                                default: TextMessageLayout(message: message as! TextMessage)
                                }
                            }
                        }
                        .onChange(of: messagesRepo.lastMessageId){ id in
                            print(id)
                            withAnimation{
                                proxy.scrollTo(id, anchor: .bottom)
                            }
                        }
                    }
                }
            }

            HStack {
                if !isRecording {
                    Menu {
                        Button {
                            pickFromCamera = false
                            showSheet.toggle()
                        } label: {
                            Label("Send gallery image…", systemImage: "photo.on.rectangle.angled")
                        }
                        
                        Button {
                            pickFromCamera = true
                            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                                showSheet.toggle()
                            } else {
                                AVCaptureDevice.requestAccess(for: .video) { granted in
                                    if granted {
                                        showSheet.toggle()
                                    } else {
                                        displayNoCameraPermissionsAlert.toggle()
                                    }
                                }
                            }
                            
                        } label: {
                            Label("Send camera image…", systemImage: "camera")
                        }
                        Button {
                            if locationService.lastLocation == nil {
                                displayNoLocationAlert.toggle()
                            } else {
                                messagesRepo.sendMessage(
                                    convID: conversation.id,
                                    message: LocationMessage(
                                        id: "MESSAGE\(messagesRepo.messages.count + 1)",
                                        isReceived: false,
                                        timestamp: DateTime.fromAppleDate(from: Date.now),
                                        coordinates: locationService.lastLocation!)
                                ){
                                    success in
                                    if !success {
                                        displaySendErrorAlert.toggle()
                                    }
                                }
                            }
                        } label: {
                            Label("Send location…", systemImage: "mappin.circle")
                        }
                    } label: {
                        Image(systemName: "paperclip")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    .frame(width: 25, height: 25)
                } else {
                    // Button to cancel recording
                    Button {
                        // WILDCARD HERE ONLY TO SILENCE WARNING MESSAGE
                        let (_, success) = audioRecorder.recordAudioMessage(userID: signInRepo.signedInUserID!,
                                                             convID: conversation.id,
                                                             isRecording: isRecording,
                                                             requestForCancellation: true)
                        
                        if success {
                            isRecording.toggle()
                        } else {
                            displayNoMicPermissionsAlert.toggle()
                        }
                    } label: {
                        Image(systemName: "xmark.bin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.red)
                    }
                }
                
                if !isRecording {
                    TextField("Message", text: $messageStr)
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50).stroke(.blue, lineWidth: 1)
                        )
                } else {
                    // Text mentioning recording in progress
                    Text("Recording voice message…")
                        .foregroundColor(.red)
                    //                        .frame(width: 280)
                        .padding(6)
                }
                
                if messageStr.isEmpty {
                    // Button to start/stop recording & send it
                    Button {
                        let (audioPath, success) = audioRecorder.recordAudioMessage(userID: signInRepo.signedInUserID!,
                                                                         convID: conversation.id,
                                                                         isRecording: isRecording,
                                                                         requestForCancellation: false)
                        
                        print(audioPath?.description ?? "No file recorded")
                        
                        if success {
                            isRecording.toggle()
                        } else {
                            displayNoMicPermissionsAlert.toggle()
                        }
                        
                        if audioPath != nil && success {
                            messagesRepo.sendMessage(
                                convID: conversation.id,
                                message: AudioMessage(id: "MESSAGE\(messagesRepo.messages.count + 1)",
                                                      isReceived: false,
                                                      timestamp: DateTime.fromAppleDate(from: Date.now),
                                                      audioUrl: audioPath!)){ success in
                                                          if !success {
                                                              displaySendErrorAlert.toggle()
                                                          }
                                                      }
                        }
                    } label: {
                        if !isRecording {
                            Image(systemName: "mic")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        } else {
                            Image(systemName: "arrow.up.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.red)
                        }
                    }
                } else {
                    Button{
                        messagesRepo.sendMessage(
                            convID: conversation.id,
                            message: TextMessage(
                                id: "MESSAGE\(messagesRepo.messages.count + 1)",
                                isReceived: false,
                                timestamp: DateTime.fromAppleDate(from: Date.now),
                                body: messageStr)){
                                    success in
                                    if !success {
                                        displaySendErrorAlert.toggle()
                                    }
                                }
                        
                        messageStr = ""
                    } label: {
                        Image(systemName: "paperplane")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                }
            }
            .padding()
            .onAppear{
                locationService.observeLocationUpdates()
                locationService.observeLocationAccessDenied()
                locationService.requestLocationUpdates()
            }
        }
        .onAppear {
            messagesRepo.getMessages(convID: conversation.id)
        }
        .sheet(isPresented: $showSheet){
            ImagePicker(fromCameraBool: $pickFromCamera){ imageURL in
                messagesRepo.sendMessage(
                    convID: conversation.id,
                    message: PicMessage(
                        id: "MESSAGE\(messagesRepo.messages.count + 1)",
                        isReceived: false,
                        timestamp: DateTime.fromAppleDate(from: Date.now),
                        imageURL: imageURL!)){
                            success in
                            if !success {
                                displaySendErrorAlert.toggle()
                            }
                        }
            }
        }
        .alert("Unable to send the location message. Make sure you granted access to location for Unlost.", isPresented: $displayNoLocationAlert) {
            Button("OK", role: .cancel){}
        }
        .alert("Unable to send your message. Check your internet connectivity and try again.", isPresented: $displaySendErrorAlert) {
            Button("OK", role: .cancel){}
        }
        .alert("Unable to record voice messages. Make sure you granted access to microphone for Unlost.", isPresented: $displayNoMicPermissionsAlert) {
            Button("OK", role: .cancel){}
        }
        .alert("Unable to take pictures with the camera. Make sure you granted access to the camera for Unlost.", isPresented: $displayNoCameraPermissionsAlert) {
            Button("OK", role: .cancel){}
        }
        .toolbar{
            ToolbarItem(placement: .principal){
                HStack {
                    Image(uiImage: conversation.user.profilePicture)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .background(.white)
                        .clipShape(Circle())
                    VStack(alignment: .leading){
                        Text(conversation.user.getFullUserName()).font(.headline)
                        Text("Related to item \"\(conversation.item.name)\" ").font(.subheadline)
                    }
                }
                
            }
        }
    }
    
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(conversation: Conversation.example)
            .environmentObject(FIRMessagesRepository())
            .environmentObject(GoogleSignInRepo())
    }
}
