//
//  ChatViewViewModel.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import Foundation
import AVKit

class AudioRecorder: ObservableObject {
    private var session: AVAudioSession!
    private var recorder: AVAudioRecorder!
        
    init() {
        setupAudioRecorder()
    }
    
    /* AUDIO RECORDER FUNCTIONS */
    // Sets up the audio recorder environment
    func setupAudioRecorder() {
        do {
            self.session = AVAudioSession.sharedInstance()
            
            // Initializing the recorder
            self.session = AVAudioSession.sharedInstance()
            try self.session.setCategory(.playAndRecord)
            
            // Requesting mic permissions
            self.session.requestRecordPermission{ status in
                
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Performs audio recording
    func recordAudioMessage(userID: String, convID: String, isRecording: Bool, requestForCancellation: Bool) -> (URL?, Bool) {
        do {
            switch session.recordPermission {
                case .denied:
                    return (nil, false)
                default:
                    if !isRecording {
                        // Records audio inside the Documents folder (name contains full date to distinguish between multiple audio messages)
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        if (try? FileManager.default.createDirectory(at: url.appendingPathComponent("conversations_assets/\(convID)"),
                                                                     withIntermediateDirectories: true)) == nil {
                            return (nil, false)
                        }
                        let filename = url.appendingPathComponent("conversations_assets/\(convID)/AUDIO_\(userID)_\(Int(Date.now.timeIntervalSince1970)).m4a")
                        
                        // If no recording is occurring when we request to record => start a new recording
                        let settings = [
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 12000,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                        ]
                        
                        self.recorder = try AVAudioRecorder(url: filename, settings: settings)
                        self.recorder.record()
                        
                        return (nil, true)
                    } else {
                        // Otherwise => stop recording and save the file
                        self.recorder.stop()
                        
                        if requestForCancellation {
                            self.recorder.deleteRecording()
                            return (nil, true)
                        } else {
                            return (self.recorder.url, true)
                        }
                        
                    }
            }

        } catch {
            // In case of error => print the error message (DEBUG ONLY)
            print("ERROR WHILE RECORDING: \(error.localizedDescription)")
            return (nil, false)
        }
    }
    
}
