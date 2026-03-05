import SwiftUI
import SpriteKit

struct ChromeWatchFace: View {
    var scene: SKScene {
        let scene = SKScene(size: CGSize(width: 200, height: 200))
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .black
        
        // Création du rectangle qui porte le shader
        let node = SKSpriteNode(color: .white, size: scene.size)
        node.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        
        // Chargement du shader depuis le fichier .fsh
        node.shader = SKShader(fileNamed: "Chrome.fsh")
        
        scene.addChild(node)
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}
