//
//  FIRNotificationsRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 13.08.22.
//

import Foundation

final class FIRNotificationsRepository: NotificationsRepository {
    private let serverKey = "AAAAQ8AlXlQ:APA91bG7L_n6pHzCmolLXTmYTQZr53mAaHmMXsuwy064KKBT5ZSSOX1v1sPgWdbP5cs__siEWtlHECBpQvQ7YBv8qAheDSJGDOrSXcOmFCY_psCaWBOmm74AzHxQ0XN5WsjXXR7CnJZb"
    
    func sendNotification(title: String, body: String, devices: [String], _ completionHandler: @escaping (Bool) -> Void) {
        let jsonRequestData: [String: Any] = [
            "registration_ids": devices,
            "data": [
                "title": title,
                "body": body,
            ]
        ]
        
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.addValue("Authorization", forHTTPHeaderField: "key=\(serverKey)")
        request.httpMethod = "POST"
        request.httpBody = jsonRequestData.percentEncoded()
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                data != nil,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                print("ERROR: unable to perform the Firebase Messaging request")
                completionHandler(false)
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("ERROR: status code should be 2xx, found \(response.statusCode)")
                completionHandler(false)
                return
            }
            
            completionHandler(true)
        }
    }
}


extension Dictionary {
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
