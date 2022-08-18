//
//  SettingsMenu.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import SwiftUI
import AVKit

struct SettingsMenu: View {
    @Environment (\.presentationMode) var presentationMode
    @EnvironmentObject var userRepo: FIRUserRepository
    @EnvironmentObject var signInRepo: GoogleSignInRepo
    
    @State private var enableDarkMode = false
    @State private var showSheet = false
    @State private var pickFromCamera = false
    @State private var showSignOutAlert = false
    @State private var showSignOutErrorAlert = false
    
    @State private var showNoCameraPermissionsAlert = false
    
    var body: some View {
        NavigationView {
            VStack{
                if let user = userRepo.user {
                    VStack{                        
                        Image(uiImage: user.profilePicture)
                            .resizable()
                            .clipShape(Circle())
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .padding(5)
                            .background(.green)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.green, lineWidth: 3))
                            
                        HStack{
                            Spacer()
                        }
                        
                        Text(user.getFullUserName())
                            .font(.largeTitle)
                            .bold()
                            .padding(.bottom)

                    }
                }
                
                Form {
                    Section("Change picture") {
                        Menu {
                            Button {
                                pickFromCamera = true
                                if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                                    showSheet.toggle()
                                } else {
                                    AVCaptureDevice.requestAccess(for: .video) { granted in
                                        if granted {
                                            showSheet.toggle()
                                        } else {
                                            showNoCameraPermissionsAlert.toggle()
                                        }
                                    }
                                }
                            } label: {
                                Label("Take from camera…", systemImage: "camera")
                            }
                            
                            Button {
                                pickFromCamera = false
                                showSheet.toggle()
                            } label: {
                                Label("Take from gallery…", systemImage: "photo.on.rectangle.angled")
                            }
                        
                        } label: {
                            Label("Change picture", systemImage: "photo.on.rectangle.angled")
                        }
                    }
                    
                    
                    Button {
                        showSignOutAlert.toggle()
                    } label: {
                        Label("Sign out", systemImage: "arrow.left")
                    }
                    .foregroundColor(.red)
                    .alert("Are you sure you want to sign out?", isPresented: $showSignOutAlert) {
                        Button("Sign out", role: .destructive) {
                            signInRepo.signOut { success in
                                showSignOutErrorAlert = !success
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                    .alert("Error while signing out. Check your internet connection and try again.", isPresented: $showSignOutErrorAlert) {
                        Button("OK", role: .cancel){}
                    }
                    .alert("Unable to take pictures with the camera. Make sure you granted access to the camera for Unlost.", isPresented: $showNoCameraPermissionsAlert) {
                        Button("OK", role: .cancel){}
                    }
                }
            }
            .toolbar{
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showSheet){
                //TODO: FIND A WAY TO RESCALE IMAGES IN ORDER TO FILL IN THE IMAGEHOLDER
                ImagePicker(fromCameraBool: $pickFromCamera) { imageURL in
                    if let imageURL = imageURL {
                        userRepo.setNewProfilePicture(
                            imageURL: imageURL){
                                success in
                                // WE RELOAD THE FETCHED USER TO GET THE UPDATED PROFILE PICTURE
                                userRepo.getCurrentUser()
                            }
                    }

                }
            }
        }
    }
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu()
            .environmentObject(FIRUserRepository())
            .environmentObject(GoogleSignInRepo())
    }
}
