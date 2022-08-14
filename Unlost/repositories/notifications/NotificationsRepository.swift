//
//  MessagingRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 13.08.22.
//

import Foundation

protocol NotificationsRepository: ObservableObject {
    func sendNotification(title: String, body: String, devices: [String], _ completionHandler: @escaping (Bool) -> Void)
}
