//
//  SecretDictatorPersonalViewController.swift
//  Logames
//
//  Created by Samuel Wong on 18/7/21.
//

import UIKit

class SecretDictatorPersonalViewController: UIViewController {

    @IBOutlet weak var turnTitleLabel: UILabel!
    @IBOutlet weak var turnDescriptionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var legislationChosen: Bool = false
    
    var _dataSource: SecretDictatorViewControllerDataSource!
            
    static var viewController: SecretDictatorPersonalViewController? {
        return UIConstants.Storyboards.SecretDictator.storyboard.instantiateViewController(identifier: UIConstants.ViewControllers.SecretHitler.SecretDictatorPersonalViewController.identifier) as? SecretDictatorPersonalViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
}

extension SecretDictatorPersonalViewController {
    func initialize() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SecretDictatorPersonalViewController {    
    func reloadView() {
        legislationChosen = false
        tableView.reloadData()
    }
}

extension SecretDictatorPersonalViewController: TableViewDDS {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let gameCoordinator = _dataSource.gameCoordinator(forViewController: self)
        guard let turn = SecretDictator.Turn(rawValue: gameCoordinator.game.currentTurn) else { return 0 }
        guard let game = gameCoordinator.game as? SecretDictator else { return 0 }
        
        switch turn {
        case .nominateChancellor :
            if game.currentPresident == UserDefaultConfig.peerID {
                return gameCoordinator.mcSession.connectedPeers.count
            } else {
                return 0
            }
        case .voteForChancellor:
            return 2
        case .selectPossibleLegislations :
            if game.currentPresident == UserDefaultConfig.peerID {
                return 3
            } else {
                return 0
            }
        case .selectLegislation :
            if game.currentPresident == UserDefaultConfig.peerID {
                return 2
            } else {
                return 0
            }
        case .performBonus :
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let gameCoordinator = _dataSource.gameCoordinator(forViewController: self)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        guard let game = gameCoordinator.game as? SecretDictator else { return cell }
        guard let turn = SecretDictator.Turn(rawValue: gameCoordinator.game.currentTurn) else { return cell }
        
        switch turn {
        case .nominateChancellor :
            cell.textLabel?.text = gameCoordinator.mcSession.connectedPeers[indexPath.row].displayName
        case .voteForChancellor:
            cell.textLabel?.text = indexPath.row == 0 ? "Approve" : "Decline"
        case .selectPossibleLegislations :
            cell.textLabel?.text = game.possibleLegislationsToProvide!.toBooleanArray(capacity: 3)[indexPath.row] ? "Freedom" : "Tyranny"
        case .selectLegislation :
            cell.textLabel?.text = game.possibleLegislationsToProvide!.toBooleanArray(capacity: 2)[indexPath.row] ? "Freedom" : "Tyranny"
        case .performBonus :
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gameCoordinator = _dataSource.gameCoordinator(forViewController: self)
        guard let game = gameCoordinator.game as? SecretDictator else { return }
        guard let turn = SecretDictator.Turn(rawValue: gameCoordinator.game.currentTurn) else { return }
        
        switch turn {
        case .nominateChancellor :
            let chancellor = gameCoordinator.mcSession.connectedPeers[indexPath.row]
            do {
                let chancellorData = try NSKeyedArchiver.archivedData(withRootObject: chancellor, requiringSecureCoding: true)
                try gameCoordinator.mcSession.send(chancellorData, toPeers: [gameCoordinator.host], with: .reliable)
            } catch {
                print(error)
            }

        case .voteForChancellor:
            let approval = indexPath.row == 0
            do {
                let approvalData = try! JSONEncoder().encode(approval)
                try gameCoordinator.mcSession.send(approvalData, toPeers: [gameCoordinator.host], with: .reliable)
            } catch {
                print(error)
            }
        case .selectPossibleLegislations :
            let legislation =  game.possibleLegislationsToProvide!.toBooleanArray(capacity: legislationChosen ? 2 : 3)[indexPath.row]
            do {
                let legislationData = try! JSONEncoder().encode(legislation)
                try gameCoordinator.mcSession.send(legislationData, toPeers: [gameCoordinator.host], with: .reliable)
                legislationChosen = true
                if legislation {
                    game.possibleLegislationsToProvide! -= 1
                }
                tableView.reloadData()
            } catch {
                print(error)
            }

        case .selectLegislation :
            let legislation = game.possibleLegislationsToProvide!.toBooleanArray(capacity: 2)[indexPath.row]
            do {
                let legislationData = try! JSONEncoder().encode(legislation)
                try gameCoordinator.mcSession.send(legislationData, toPeers: [gameCoordinator.host], with: .reliable)
                legislationChosen = true
            } catch {
                print(error)
            }

        case .performBonus :
            break

        }
    }
}
