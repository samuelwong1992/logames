//
//  UI Constants.swift
//  Logames
//
//  Created by Samuel Wong on 10/7/21.
//

import UIKit

struct UIConstants {
    enum Storyboards: String {
        case Main = "Main"
        case SecretDictator = "SecretDictator"
        
        var storyboard: UIStoryboard {
            return UIStoryboard(name: self.rawValue, bundle: nil)
        }
    }
    
    enum TableViewCells: String {
        case GameShortDescriptionCollectionViewCell = "GameShortDescriptionCollectionViewCell"
        
        var identifier: String {
            return self.rawValue
        }
    }
    
    enum ViewControllers: String {
        case StartHostViewController = "StartHostViewController"
        
        enum SecretHitler: String {
            case SecretDictatorHostViewController = "SecretDictatorHostViewController"
            case SecretDictatorPersonalViewController = "SecretDictatorPersonalViewController"
            
            var identifier: String {
                return self.rawValue
            }
        }
        
        var identifier: String {
            return self.rawValue
        }
    }
}
