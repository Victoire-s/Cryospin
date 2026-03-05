import SwiftUI
import AVKit
import AVFoundation

struct VideoBackgroundView: UIViewRepresentable {
    var videoName: String
    var videoExtension: String
    @Binding var isPlaying: Bool
    
    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(videoName: videoName, videoExtension: videoExtension)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerView = uiView as? LoopingPlayerUIView {
            playerView.setPlaying(isPlaying)
        }
    }
}

class LoopingPlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    
    init(videoName: String, videoExtension: String) {
        super.init(frame: .zero)
        
        guard let fileUrl = Bundle.main.url(forResource: videoName, withExtension: videoExtension) else {
            print("Erreur : Impossible de trouver la vidéo \(videoName).\(videoExtension)")
            return
        }
        
        let asset = AVAsset(url: fileUrl)
        let item = AVPlayerItem(asset: asset)
        
        let queuePlayer = AVQueuePlayer(playerItem: item)
        queuePlayer.isMuted = true
        
        playerLayer.player = queuePlayer
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
    }
    
    func setPlaying(_ isPlaying: Bool) {
        if let queuePlayer = playerLayer.player as? AVQueuePlayer {
            if isPlaying {
                queuePlayer.play()
            } else {
                queuePlayer.pause()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
