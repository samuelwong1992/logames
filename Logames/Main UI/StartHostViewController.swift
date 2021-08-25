//
//  StartHostViewController.swift
//  Logames
//
//  Created by Samuel Wong on 16/7/21.
//

import UIKit
import MultipeerConnectivity

class StartHostViewController: UIViewController {
    static var viewController: StartHostViewController? {
        return UIConstants.Storyboards.Main.storyboard.instantiateViewController(identifier: UIConstants.ViewControllers.StartHostViewController.identifier) as? StartHostViewController
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startGameButton: UIButton!
    
    var browser: MCNearbyServiceBrowser = MCNearbyServiceBrowser(peer: UserDefaultConfig.peerID, serviceType: ConnectivityConstants.Search.rawValue)
    var session: MCSession = MCSession(peer: UserDefaultConfig.peerID, securityIdentity: nil, encryptionPreference: .none)
    
    var gameType: GameConfig.Type!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
}

//MARK: Initialization
extension StartHostViewController {
    func initialize() {
        browser.delegate = self
        browser.startBrowsingForPeers()
        
        session.delegate = self
        
        titleLabel.text = gameType.name()
        descriptionLabel.text = gameType.shortDescription()
                
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        startGameButton.addTarget(self, action: #selector(startGameButton_didPress), for: .touchUpInside)
    }
    
    @objc func startGameButton_didPress() {
        switch gameType! {
        case is SecretDictator.Type :
            if let vc = SecretDictatorTabBarController.viewController {
                let game = SecretDictator()
                vc.gameCoordinator = GameCoordinator(session: session, host: UserDefaultConfig.peerID, game: game)
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true, completion: ({() -> Void in
                    do {
                        let gameData = try JSONEncoder().encode(game)
                        try self.session.send(gameData, toPeers: self.session.connectedPeers, with: .reliable)
                    } catch {
                        print(error)
                    }
                }))
            }
        default :
            break
        }
    }
}

extension StartHostViewController: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let inviteText = "You have been invited to join a game of \(gameType.name()). Would you like to join?"
        browser.invitePeer(peerID, to: session, withContext: inviteText.data(using: String.Encoding.utf8), timeout: 60)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer")
    }
}

extension StartHostViewController: TableViewDDS {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.connectedPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.textLabel?.text = session.connectedPeers[indexPath.row].displayName
        
        return cell
    }
    
    
}

extension StartHostViewController: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
