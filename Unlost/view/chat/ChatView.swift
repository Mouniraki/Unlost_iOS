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
    @EnvironmentObject var messagesRepo: LocalMessagesRepository
    
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
    @State private var displayNoLocationAlert = false
    
    var body: some View {
        //TODO: FIGURE OUT HOW TO FOCUS THE VIEW ON THE LAST MESSAGES
        VStack {
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
                            showSheet.toggle()
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
                                        timestamp: Date.now,
                                        coordinates: locationService.lastLocation!)
                                ){
                                    success in
                                    // TODO: INSERT CODE HERE
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
                        _ = audioRecorder.recordAudioMessage(isRecording: isRecording, requestForCancellation: true)
                        
                        isRecording.toggle()
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
                        let audioPath = audioRecorder.recordAudioMessage(isRecording: isRecording, requestForCancellation: false)
                        
                        print(audioPath?.description ?? "No file recorded")
                        isRecording.toggle()
                        
                        if audioPath != nil {
                            messagesRepo.sendMessage(
                                convID: conversation.id,
                                message: AudioMessage(id: "MESSAGE\(messagesRepo.messages.count + 1)",
                                                     isReceived: false,
                                                     timestamp: Date.now,
                                                      audioUrl: audioPath!)){
                                                          success in
                                                          //TODO: INSERT CODE HERE
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
                                timestamp: Date.now,
                                body: messageStr)){
                                    success in
                                    // TODO: INSERT CODE HERE
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
            ImagePicker(fromCameraBool: $pickFromCamera){ image in
                messagesRepo.sendMessage(
                    convID: conversation.id,
                    message: PicMessage(
                        id: "MESSAGE\(messagesRepo.messages.count + 1)",
                        isReceived: false,
                        timestamp: Date.now,
                        image: image ?? UIImage())){
                            success in
                            //TODO: INSERT CODE HERE
                        }
            }
        }
        .alert("Unable to send the location message. Make sure you granted access to location for Unlost.", isPresented: $displayNoLocationAlert) {
            Button("OK", role: .cancel){}
        }
        .toolbar{
            ToolbarItem(placement: .principal){
                HStack {
                    Image(uiImage: conversation.user.profilePicture)
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
            .environmentObject(LocalMessagesRepository())
    }
}
