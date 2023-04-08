//
//  ContentView.swift
//  SliderSwiftUI
//
//  Created by sss on 08.04.2023.
//

import SwiftUI
import AVFoundation

class PlayerViewModel: ObservableObject {
    
    @Published public var maxDuration: Float = 0
    @Published public var currentProgress: Float = 0
   
    private var player: AVAudioPlayer?
    private var timer: Timer!

    private func playSong(name: String) {
        guard let audioPath = Bundle.main.path(forResource: name, ofType: "mp3") else {return}
        
        do {
            try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
            maxDuration = Float(player?.duration ?? 0.0)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func play() {
        playSong(name: "song")
        player?.play()
        addPeriodicTimeObserver()
    }

    public func stop() {
        player?.stop()
        timer.invalidate()
    }
    
    public func setTime(value: Float) {
        guard let time = TimeInterval(exactly: value) else {return}
        player?.currentTime = time
        player?.play()
    }
    

    func addPeriodicTimeObserver() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.currentProgress = Float(self.player?.currentTime ?? 0)
        })
    }
}



struct ContentView: View {
    
    @State private var progress: Float = 0
    @ObservedObject var viewModel = PlayerViewModel()
    
    var body: some View {
        VStack {
            
            Slider(value: Binding(get: {
                self.viewModel.currentProgress
            }, set: { newValue in
                print(newValue)
                
                progress = newValue
                viewModel.setTime(value: newValue)
            }), in: 0...viewModel.maxDuration).tint(.purple)
            
            HStack {
                Button {
                    viewModel.play()
                } label: {
                    Text("Play").foregroundColor(Color.white)
                }.frame(width: 100, height: 50).background(Color.orange).cornerRadius(10)
                
                Button {
                    viewModel.stop()
                } label: {
                    Text("Stop").foregroundColor(Color.white)
                }.frame(width: 100, height: 50).background(Color.orange).cornerRadius(10)
            }
            

        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
