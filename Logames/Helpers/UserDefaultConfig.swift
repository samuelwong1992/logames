//
//  UserDefaultConfig.swift
//  Logames
//
//  Created by Samuel Wong on 16/7/21.
//

import Foundation
import MultipeerConnectivity

var _peerID: MCPeerID?

struct UserDefaultConfig {
    private enum UserDefaultKeys: String {
        case peerID = "PeerID"
        
        var identifier: String {
            return self.rawValue
        }
    }
    
    static var peerID: MCPeerID {
        get {
            if let _peerID = _peerID {
                return _peerID
            }
            
            
            if let storedPeerId = UserDefaults.standard.data(forKey: UserDefaultKeys.peerID.identifier) {
                do {
                    _peerID = try NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: storedPeerId)
                    return _peerID!
                } catch {
                    UserDefaults.standard.removeObject(forKey: UserDefaultKeys.peerID.identifier)
                }
                
            }
            
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let randomString = String((0..<6).map{ _ in letters.randomElement()! })
            
            _peerID = MCPeerID(displayName: randomString)
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: _peerID!, requiringSecureCoding: true)
                UserDefaults.standard.setValue(data, forKey: UserDefaultKeys.peerID.identifier)
            } catch {
                
            }
            
            return _peerID!
        }
    }
}
