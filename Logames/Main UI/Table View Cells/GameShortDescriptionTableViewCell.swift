//
//  GameShortDescriptionTableViewCell.swift
//  Logames
//
//  Created by Samuel Wong on 10/7/21.
//

import UIKit

class GameShortDescriptionCollectionViewCell: UICollectionViewCell {
    
    static let kReuseIdentifier = UIConstants.TableViewCells.GameShortDescriptionCollectionViewCell.identifier
    static let kNib = UINib(nibName: UIConstants.TableViewCells.GameShortDescriptionCollectionViewCell.identifier, bundle: nil)

    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var playersLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    var game: GameConfig.Type! {
        didSet {
            nameLabel.text = game.name()
            descriptionLabel.text = game.shortDescription()
            playersLabel.text = "\(game.minPlayers()) - \(game.maxPlayers()) players"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
