//
//  SecretDictatorHostViewController.swift
//  Logames
//
//  Created by Samuel Wong on 18/7/21.
//

import UIKit

class SecretDictatorHostViewController: UIViewController {

    var _dataSource: SecretDictatorViewControllerDataSource!
    
    static var viewController: SecretDictatorHostViewController? {
        return UIConstants.Storyboards.SecretDictator.storyboard.instantiateViewController(identifier: UIConstants.ViewControllers.SecretHitler.SecretDictatorHostViewController.identifier) as? SecretDictatorHostViewController
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
}

//MARK: Initialization
extension SecretDictatorHostViewController {
    func initialize() {
    }
    
    func reloadView() {
        if let game = _dataSource.gameCoordinator(forViewController: self).game as? SecretDictator {
            if let turn = SecretDictator.Turn(rawValue: game.currentTurn) {
                switch turn {
                case .nominateChancellor:
                    titleLabel.text = "Nominate Chancellor"
                case .voteForChancellor:
                    titleLabel.text = "Vote for chancellor - \(game.currentChancellor?.displayName ?? "")"
                case .selectPossibleLegislations:
                    titleLabel.text = "Select Possible Legislation - \(game.possibleLegislationsToProvide ?? 0)"
                case .selectLegislation:
                    titleLabel.text = "Select Legislation - \(game.possibleLegislationsProvided ?? 0)"
                case .performBonus:
                    titleLabel.text = "Perform Bonus"
                }
            }
        }
    }
}
