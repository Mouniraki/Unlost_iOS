//
//  AudioMessageLayout.swift
//  Unlost
//
//  Created by Mounir Raki on 15.07.22.
//

import SwiftUI
import AVKit

//TODO: MOVE THIS TO A UTILITY CLASS
func formatDuration(time: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.zeroFormattingBehavior = .pad
    return formatter.string(from: time)!
}

struct AudioMessageLayout: View {
    @StateObject var audioPlayer = AudioPlayer()
    
    let message: AudioMessage
    
    @State private var isPlaying = false
    @State private var currentSliderPos = 0.0
    @State private var counterText = ""
    
    @State private var isEditing = false // TO PREVENT PLAYBACK CONFLICTS WHEN SEEKING
    
    // Performs refreshing of the UI for progress bar & time counter
    let timer = Timer
        .publish(every: 0.2, on: .main, in: .common)
        .autoconnect()
    
    var body: some View {
        VStack(alignment: message.isReceived ? .leading : .trailing) {
            HStack {
                // Optional binding => takes the inner value if it exists
                if let player = audioPlayer.player {
                    Button {
                        audioPlayer.playPauseAudio(url: message.audioUrl, isPlaying: isPlaying)
                        isPlaying.toggle()
                    } label: {
                        if isPlaying {
                            Image(systemName: "pause.fill")
                                .padding(.trailing)
                        } else {
                            Image(systemName: "play.fill")
                                .padding(.trailing)
                        }
                    }
                     
                    Slider(value: $currentSliderPos, in: 0...player.duration) { isSeeking in
                        isEditing = isSeeking
                        
                        if !isSeeking {
                            player.currentTime = currentSliderPos
                        }
                    }
                    .tint(.white)
                            
                    Text(counterText)
                        .font(.subheadline)
                        .onAppear {
                            counterText = formatDuration(time: player.duration)
                        }
                }
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            .background(message.isReceived ? .gray : .blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(maxWidth: 300, alignment: message.isReceived ? .leading : .trailing)

            Text(message.timestamp.toAppleDate().formatted(.dateTime.day().month().year().hour().minute()))
                .font(.caption)
        }
        .onAppear {
            audioPlayer.setUpAudioPlayer(url: message.audioUrl)
        }
        .onReceive(timer) { _ in
            // WHAT DOES THE ',' OPERATOR MEAN HERE ?
            guard let player = audioPlayer.player, !isEditing else { return }
            currentSliderPos = player.currentTime
            counterText = formatDuration(
                time: player.currentTime == 0.0 && !player.isPlaying ? player.duration : player.currentTime
            )
            isPlaying = player.isPlaying
        }
        .frame(maxWidth: .infinity, alignment: message.isReceived ? .leading : .trailing)
        .padding(message.isReceived ? .leading : .trailing)
        .padding(.horizontal, 10)
    }

}

struct AudioMessageLayout_Previews: PreviewProvider {
    static var previews: some View {
        AudioMessageLayout(message: AudioMessage.example)
    }
}
