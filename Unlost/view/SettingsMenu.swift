//
//  SettingsMenu.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import SwiftUI

struct SettingsMenu: View {
    @Environment (\.presentationMode) var presentationMode
    @EnvironmentObject var userRepo: UserRepository
    @EnvironmentObject var signInRepo: LocalSignInRepo
    
    
    @State private var enableDarkMode = false
    @State private var showSheet = false
    @State private var pickFromCamera = false
    @State private var showSignOutAlert = false
    
    var body: some View {
        
        NavigationView {
            VStack{
                if let user = userRepo.user {
                    VStack{
                        Image(uiImage: user.profilePicture)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .padding()
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
                                showSheet.toggle()
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
                            signInRepo.signOut()
                            presentationMode.wrappedValue.dismiss()
                        }
                        Button("Cancel", role: .cancel) {}
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
                ImagePicker(fromCameraBool: $pickFromCamera) { image in
                    userRepo.setNewProfilePicture(uiImage: image ?? UIImage(systemName: "person.fill")!)
                }
            }
        }
    }
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu()
            .environmentObject(UserRepository())
            .environmentObject(LocalSignInRepo())
    }
}
