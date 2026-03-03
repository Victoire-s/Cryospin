import SwiftUI
import AVKit
import AVFoundation

struct VideoBackgroundView: UIViewRepresentable {
    var videoName: String
    var videoExtension: String
    
    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(videoName: videoName, videoExtension: videoExtension)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class LoopingPlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    
    init(videoName: String, videoExtension: String) {
        super.init(frame: .zero)
        
        // Load the video from the app bundle
        guard let fileUrl = Bundle.main.url(forResource: videoName, withExtension: videoExtension) else {
            print("Erreur : Impossible de trouver la vidéo \(videoName).\(videoExtension)")
            return
        }
        
        let asset = AVAsset(url: fileUrl)
        let item = AVPlayerItem(asset: asset)
        
        // Use an AVQueuePlayer to allow for seamless looping
        let queuePlayer = AVQueuePlayer(playerItem: item)
        queuePlayer.isMuted = true // Mute the background video
        
        playerLayer.player = queuePlayer
        playerLayer.videoGravity = .resizeAspectFill // Fill the entire screen
        layer.addSublayer(playerLayer)
        
        // Create the looper
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        
        // Start playing
        queuePlayer.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
