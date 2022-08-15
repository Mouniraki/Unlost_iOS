//
//  QRScanMenu.swift
//  Unlost
//
//  Created by Mounir Raki on 13.07.22.
//

import CodeScanner
import SwiftUI
import AVFoundation

struct QRScanMenu: View {
    @Environment (\.presentationMode) var presentationMode
    @EnvironmentObject var convRepo: FIRConversationsRepository
    
    @State private var qrText = ""
    @State private var isValid = false
    @State private var showProgressView = false
    
    @State private var isValidText = "The ID field is empty"
    @State private var textFieldId: String = UUID().uuidString // ONLY TO CLOSE KEYBOARD
    
    @StateObject var locationService = LocationService.shared
    @State private var showLocationErrorAlert = false
    @State private var showProcessingErrorAlert = false
    @State private var showNoCameraPermissionsAlert = false
    @State private var showSuccessAlert = false
    
    @State private var showCodeScanner = false
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            qrText = result.string
        case .failure(let error):
            //TODO: TRIGGER ALERT NOTIFYING FAILURE OF CAMERA INITIALIZATION
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if showCodeScanner {
                        CodeScannerView(codeTypes: [.qr], simulatedData: "MyQRCodeContent", completion: handleScan)
                            .frame(height: 300)
                    } else {
                        Text("UNABLE TO START CAMERA")
                            .frame(height: 300)
                    }
                    
                    Form {
                        Section("Report item") {
                            TextField("Scan or enter item ID…", text: $qrText)
                                .onChange(of: qrText) { text in
                                    if text.isEmpty {
                                        isValid = false
                                        isValidText = "The ID field is empty"
                                    } else {
                                        let nbSeparators = text.filter{char in char == ":"}.count
                                        let arr = text.split(separator: ":")
                                        
                                        if nbSeparators == 1 && arr.count == 2 && !arr[0].isEmpty && !arr[1].isEmpty {
                                            isValid = true
                                            isValidText = "Report item"
                                        } else {
                                            isValid = false
                                            isValidText = "The ID field is badly formatted"
                                        }
                                    }
                                }
                                .id(textFieldId)
                        }
                        
                        Section {
                            Button {
                                showProgressView = true
                                textFieldId = UUID().uuidString
                                
                                if locationService.lastLocation == nil {
                                    showProgressView = false
                                    showLocationErrorAlert.toggle()
                                } else {
                                    convRepo.addConversation(
                                        qrID: qrText,
                                        location: locationService.lastLocation!
                                    ) { isSuccess in
                                        showProgressView = false
                                        showSuccessAlert = isSuccess
                                        showProcessingErrorAlert = !isSuccess
                                    }
                                }
                                
                            } label: {
                                Label(isValidText, systemImage: isValid ? "arrow.up.doc": "exclamationmark.triangle")
                            }
                            .disabled(!isValid)
                            .alert("Thank you ! The user has been notified.", isPresented: $showSuccessAlert) {
                                Button("OK", role: .cancel){
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            .alert("An error has occurred while fetching your last location. Please make sure you granted location permissions and try again.", isPresented: $showLocationErrorAlert){
                                Button("OK", role: .cancel){
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            .alert("Unable to start the camera. Please make sure you granted camera permissions and try again.", isPresented: $showNoCameraPermissionsAlert){
                                Button("OK", role: .cancel){}
                            }
                            .alert("Error: the QR code doesn't belong to a valid item, or you already notified the user for this item.", isPresented: $showProcessingErrorAlert){
                                Button("OK", role: .cancel){}
                            }
                        }
                    }
                    
                    Spacer()
                }
                .navigationTitle("Scan QR Code")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar{
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", role: .cancel) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .onAppear{
                    locationService.observeLocationUpdates()
                    locationService.observeLocationAccessDenied()
                    locationService.requestLocationUpdates()
                }
                
                if showProgressView {
                    ZStack {
                        Color(.black)
                            .opacity(0.3)
                            
                        ProgressView("Processing ID…")
                            .progressViewStyle(.circular)
                            .padding()
                            .background()
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .shadow(radius: 4)
                    }
                   
                }
            }
            .onAppear {
                if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                    showCodeScanner = true
                } else {
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            showCodeScanner = true
                        } else {
                            showCodeScanner = false
                            showNoCameraPermissionsAlert.toggle()
                        }
                    }
                }
            }
        }

        
    }
}

struct QRScanMenu_Previews: PreviewProvider {
    static var previews: some View {
        QRScanMenu()
            .environmentObject(FIRConversationsRepository())
    }
}
