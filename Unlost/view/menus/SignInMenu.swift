//
//  SignInView.swift
//  Unlost
//
//  Created by Mounir Raki on 18.07.22.
//

import SwiftUI
import GoogleSignInSwift

struct SignInMenu: View {
    @EnvironmentObject var signInRepo: GoogleSignInRepo
    
    // TO BE ABLE TO CHANGE COLORS ACCORDING TO THE CHOSEN UI THEME
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var showQRSheet = false
    @State private var showProgressBar = false
    @State private var showSignInErrorAlert = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                //TODO: REPLACE BY ACTUAL UNLOST LOGO
                Image(systemName: "globe.europe.africa")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                
                Text("Unlost")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                Group {
                    Button{
                        showProgressBar = true
                        signInRepo.signIn { isSuccess in
                            showProgressBar = false
                            showSignInErrorAlert = !isSuccess
                        }
                    } label: {
                        Label("Sign in with Google", systemImage: "g.square.fill")
                    }
                    .padding()
                    .background(colorScheme == .light ? .black : .white)
                    .foregroundColor(colorScheme == .light ? .white : .black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .alert("Error while trying to sign you in. Check your credentials and try again.", isPresented: $showSignInErrorAlert) {
                        Button("OK", role: .cancel){}
                    }
                    
                    Button{
                        showQRSheet.toggle()
                    } label: {
                        Label("Report lost item", systemImage: "qrcode.viewfinder")
                    }
                    .padding()
                    .padding(.horizontal, 13)
                    .background(colorScheme == .light ? .black : .white)
                    .foregroundColor(colorScheme == .light ? .white : .black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
            }
            .sheet(isPresented: $showQRSheet) {
                QRScanMenu()
            }
            
            if showProgressBar {
                Color(.black)
                    .opacity(0.3)
                
                ProgressView("Connecting…")
                    .padding()
                    .background()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 3)
            }
        }
    }
}

struct SignInMenu_Previews: PreviewProvider {
    static var previews: some View {
        SignInMenu()
            .environmentObject(GoogleSignInRepo())
    }
}
