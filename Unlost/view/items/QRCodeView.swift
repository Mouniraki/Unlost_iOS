//
//  QRCodeView.swift
//  Unlost
//
//  Created by Mounir Raki on 15.07.22.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    @EnvironmentObject var userRepo: FIRUserRepository
    let item: Item
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    
    var body: some View {
        if let userID = userRepo.signedInUserID {
            let qrStr = "\(userID):\(item.id)"
        
            VStack{
                Image(uiImage: generateQRCode(from: qrStr))
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                Text(qrStr)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white.shadow(color: Color.black, radius: 2))
            .navigationTitle("QR Code of \(item.name)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage()
    }
}

struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView(item: Item.example)
            .environmentObject(FIRUserRepository())
    }
}
