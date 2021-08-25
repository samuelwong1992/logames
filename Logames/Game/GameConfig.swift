//
//  Game.swift
//  Logames
//
//  Created by Samuel Wong on 13/7/21.
//

import MultipeerConnectivity

protocol GameConfigDelegateDataSource {
    func players(forGameConfig gameConfig: GameConfig) -> [MCPeerID]
    func turnDidChange(forGameConfig gameConfig: GameConfig)
}

protocol GameConfig: Codable {
    static func name() -> String
    static func shortDescription() -> String
    static func longDescription() -> String
    static func minPlayers() -> Int
    static func maxPlayers() -> Int
    static func rules() -> String
    
    func handleTurnData(data: Data, fromPeer peer: MCPeerID)
    var currentTurn: Int! { get set }
    var _delegate: GameConfigDelegateDataSource! { get set }
}

protocol GameCoordinatorDelegate {
    func updateTurnUI(forGameCoordinator gameCoordinator: GameCoordinator)
}

class GameCoordinator: NSObject {
    var mcSession: MCSession
    var host: MCPeerID
    
    var hostIsPlaying: Bool!
    
    var game: GameConfig
    var _delegate: GameCoordinatorDelegate?
    
    init(session: MCSession, host: MCPeerID, game: GameConfig) {
        self.mcSession = session
        self.host = host
        self.game = game
        super.init()
        self.game._delegate = self
    }
    
    func disseminateGame() {
        do {
            try mcSession.send(Data(bytes: &game,
                            count: MemoryLayout.size(ofValue: game)), toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            //TODO: handle error
        }
    }
}
extension GameCoordinator: GameConfigDelegateDataSource {
    func turnDidChange(forGameConfig gameConfig: GameConfig) {
        disseminateGame()
    }
    
    func players(forGameConfig gameConfig: GameConfig) -> [MCPeerID] {
        return mcSession.connectedPeers
    }
}

extension GameCoordinator: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("did change state")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if host != UserDefaultConfig.peerID {
            do {
                let game = try JSONDecoder().decode(SecretDictator.self, from: data)
                self.game = game
                _delegate?.updateTurnUI(forGameCoordinator: self)
            } catch {
                print(error)
            }
        } else {
            self.game.handleTurnData(data: data, fromPeer: peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}


var gameTypes: [GameConfig.Type] = [SecretDictator.self]

enum Games: Int, CaseIterable {
    case SecretDictatorGame
    
    var gameType: GameConfig.Type {
        switch self {
        case .SecretDictatorGame : return SecretDictator.self
        }
    }
}
