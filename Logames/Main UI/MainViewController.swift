//
//  MainViewController.swift
//  Logames
//
//  Created by Samuel Wong on 10/7/21.
//

import UIKit
import MultipeerConnectivity

class MainViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    let session = MCSession(peer: UserDefaultConfig.peerID, securityIdentity: nil, encryptionPreference: .none)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
}

//MARK: Initialization
extension MainViewController {
    func initialize() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: UserDefaultConfig.peerID, discoveryInfo: ["hello": "hello"], serviceType: ConnectivityConstants.Search.rawValue)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        collectionView.register(GameShortDescriptionCollectionViewCell.kNib, forCellWithReuseIdentifier: GameShortDescriptionCollectionViewCell.kReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension MainViewController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let message = context != nil ? String(data: context!, encoding: String.Encoding.utf8) : "An Invite was received"
        let alert = UIAlertController(title: "Invite", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Deny", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { action in
            self.session.delegate = self
            invitationHandler(true, self.session)
            print(self.session.connectedPeers)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension MainViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print(state)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let game = try JSONDecoder().decode(SecretDictator.self, from: data)
            DispatchQueue.main.async {
                if let vc = SecretDictatorTabBarController.viewController {
                    vc.gameCoordinator = GameCoordinator(session: session, host: peerID, game: game)
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("3")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("4")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("5")
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        print("6")
        certificateHandler(true)
    }
}

extension MainViewController: CollectionViewDDS {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Games.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameShortDescriptionCollectionViewCell.kReuseIdentifier, for: indexPath) as! GameShortDescriptionCollectionViewCell
        
        if let game = Games.init(rawValue: indexPath.row) {
            cell.game = game.gameType
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = StartHostViewController.viewController {
            if let game = Games(rawValue: indexPath.row) {
                vc.gameType = game.gameType
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
