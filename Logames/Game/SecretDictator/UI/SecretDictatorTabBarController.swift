//
//  SecretDictatorTabBarController.swift
//  Logames
//
//  Created by Samuel Wong on 22/8/21.
//

import UIKit

protocol SecretDictatorViewControllerDataSource {
    func gameCoordinator(forViewController: UIViewController) -> GameCoordinator
}

class SecretDictatorTabBarController: UITabBarController {

    static var viewController: SecretDictatorTabBarController? {
        return UIConstants.Storyboards.SecretDictator.storyboard.instantiateInitialViewController() as? SecretDictatorTabBarController
    }
    
    var gameCoordinator: GameCoordinator!
    
    var personalController: SecretDictatorPersonalViewController?
    var hostController: SecretDictatorHostViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
}

extension SecretDictatorTabBarController {
    func initialize() {
        var _viewControllers: [UIViewController] = []
        
        if gameCoordinator.hostIsPlaying || (!gameCoordinator.hostIsPlaying && gameCoordinator.host != UserDefaultConfig.peerID) {
            if let vc = SecretDictatorPersonalViewController.viewController {
                personalController = vc
                personalController!._dataSource = self
                _viewControllers.append(vc)
            }
        }
        
        if gameCoordinator.hostIsPlaying || (!gameCoordinator.hostIsPlaying && gameCoordinator.host == UserDefaultConfig.peerID) {
            if let vc = SecretDictatorHostViewController.viewController {
                hostController = vc
                hostController!._dataSource = self
                _viewControllers.append(vc)
            }
        }
        
        self.viewControllers = _viewControllers
        
        gameCoordinator._delegate = self
    }
}

extension SecretDictatorTabBarController: GameCoordinatorDelegate {
    func updateTurnUI(forGameCoordinator gameCoordinator: GameCoordinator) {
        if let personalController = personalController {
            personalController.reloadView()
        }
        
        if let hostController = hostController {
            hostController.reloadView()
        }
    }
}

extension SecretDictatorTabBarController: SecretDictatorViewControllerDataSource {
    func gameCoordinator(forViewController: UIViewController) -> GameCoordinator {
        return self.gameCoordinator
    }
}
