//
//  SecretDictator.swift
//  Logames
//
//  Created by Samuel Wong on 13/7/21.
//

import Foundation
import MultipeerConnectivity

class SecretDictatorConfig: NSObject, GameConfig {
    func handleTurnData(data: Data, fromPeer peer: MCPeerID) {}
    
    var currentTurn: Int!
    var _delegate: GameConfigDelegateDataSource!
    
    func encode(to encoder: Encoder) throws {}
    required init(from decoder: Decoder) throws {}
    override init() {}
    
    static func name() -> String {
        return "Secret Dictator"
    }
    
    static func shortDescription() -> String {
        return "A game of political intrigue and batrayal."
    }
    
    static func minPlayers() -> Int {
        return 5
    }
    
    static func maxPlayers() -> Int {
        return 10
    }
    
    static func longDescription() -> String {
        return "Secret Dictator is a game of political intrigue and batrayal. Each player is given a secret politcal leaning and role. Every player will get a turn to run for President and select their Vice President. If they get elected, they will be able to pass some legislation. It is the role of the Freedom Party to pass Legislations of Freedom, while it is the role of the Tyranical Party to sow doubt and pass Legislations of Tyranny. As the two parties secretly vie for power, will the next ruler be a Leader of the Free World, or a Tyrant?"
    }
    
    static func rules() -> String {
        return "Each round, a new player will run for President."
    }
}

//MARK: Game Logic
class SecretDictator: SecretDictatorConfig {
    enum CodingKeys: CodingKey {
        case currentPresident
        case currentChancellor
        case currentTurn
        case possibleLegislationsToProvide
        case possibleLegislationsProvided
    }
    
    enum Turn: Int {
        case nominateChancellor = 0
        case voteForChancellor
        case selectPossibleLegislations
        case selectLegislation
        case performBonus
        
        var title: String {
            switch self {
            case .nominateChancellor : return "Nominate Chancellor"
            case .voteForChancellor : return "Vote For Chancellor"
            case .selectPossibleLegislations : return "Select Possible Legislations"
            case .selectLegislation : return "Select Legislation"
            case .performBonus : return "Bonus Ability"
            }
        }
        
        func description(game: SecretDictator) -> String {
            switch self {
            case .nominateChancellor : return game.currentPresident == UserDefaultConfig.peerID ? "It's time to nominate your chancellor!" : "\(game.currentPresident!.displayName) is nominating their chancellor."
            case .voteForChancellor : return "It's time to vote for the chancellor"
            case .selectPossibleLegislations : return game.currentPresident! == UserDefaultConfig.peerID ? "It's time to draw up the legislation to put to the cabinet!" : "\(game.currentPresident!.displayName) is drawing up their legislation."
            case .selectLegislation : return game.currentChancellor! == UserDefaultConfig.peerID ? "It's time to sign in your legislation!" : "\(game.currentChancellor!.displayName) is signing in some legislation."
            case .performBonus : return ""
            }
        }
        
        func nextTurn(game: SecretDictator) -> Turn {
            switch self {
            case .nominateChancellor : return .voteForChancellor
            case .voteForChancellor : return .selectPossibleLegislations
            case .selectPossibleLegislations : return .selectLegislation
            case .selectLegislation : return .performBonus
            case .performBonus : return .nominateChancellor
            }
        }
    }
    
    override init() {
        super.init()
        
        currentPresident = UserDefaultConfig.peerID
        currentTurn = 0
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let currentPresidentData = try values.decode(Data.self, forKey: CodingKeys.currentPresident)
        currentPresident = try NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: currentPresidentData)
        if values.contains(CodingKeys.currentChancellor) {
            let currentChancellorData = try values.decode(Data.self, forKey: CodingKeys.currentChancellor)
            currentChancellor = try NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: currentChancellorData)
        }
        
        if values.contains(CodingKeys.possibleLegislationsToProvide) {
            possibleLegislationsToProvide = try values.decodeIfPresent(Int.self, forKey: CodingKeys.possibleLegislationsToProvide)
        }
        if values.contains(CodingKeys.possibleLegislationsProvided) {
            
            possibleLegislationsProvided = try values.decodeIfPresent(Int.self, forKey: CodingKeys.possibleLegislationsProvided)
        }
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let currentPresidentData = try NSKeyedArchiver.archivedData(withRootObject: self.currentPresident!, requiringSecureCoding: true)
        try container.encode(currentPresidentData, forKey: CodingKeys.currentPresident)
        
        if let currentChancellor = currentChancellor {
            let currentChancellorData = try NSKeyedArchiver.archivedData(withRootObject: currentChancellor, requiringSecureCoding: true)
            try container.encode(currentChancellorData, forKey: CodingKeys.currentChancellor)
        }
        
        try container.encode(self.possibleLegislationsToProvide, forKey: CodingKeys.possibleLegislationsToProvide)
        try container.encode(self.possibleLegislationsProvided, forKey: CodingKeys.possibleLegislationsProvided)
    }

    var currentPresident: MCPeerID!
    var currentChancellor: MCPeerID?
    
    var votes: [(player: MCPeerID, vote: Bool)] = []
    var possibleLegislationsToProvide: Int?
    var possibleLegislationsProvided: Int?
    
    var legislationsPassed = 0
    var democraticLegislationsPassed = 0
    
    var legislationCount = 0
    
    override func handleTurnData(data: Data, fromPeer peer: MCPeerID) {
        do {
            if let turn = Turn(rawValue: currentTurn) {
                switch turn {
                case .nominateChancellor:
                    currentChancellor = try NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data)
                    currentTurn = turn.nextTurn(game: self).rawValue
                    _delegate.turnDidChange(forGameConfig: self)
                case .voteForChancellor:
                    let vote = try JSONDecoder().decode(Bool.self, from: data)
                    votes.append((peer, vote))
                    if votes.count >= _delegate.players(forGameConfig: self).count {
                        if votes.filter({ $0.vote }).count >= votes.filter({ !$0.vote }).count {
                            possibleLegislationsToProvide = 2
                            currentTurn = turn.nextTurn(game: self).rawValue
                        } else {
                            progressPresident()
                            currentTurn = Turn.nominateChancellor.rawValue
                        }
                        
                        _delegate.turnDidChange(forGameConfig: self)
                    }
                    
                case .selectPossibleLegislations:
                    if possibleLegislationsProvided == nil {
                        possibleLegislationsProvided = 0
                        legislationCount = 0
                    }
                    let legislation = try JSONDecoder().decode(Bool.self, from: data)
                    possibleLegislationsProvided! += legislation ? 1 : 0
                    legislationCount += 1
                    
                    if legislationCount >= 3 {
                        currentTurn = Turn.selectLegislation.rawValue
                        _delegate.turnDidChange(forGameConfig: self)
                    }
                    
                case .selectLegislation:
                    let legislation = try JSONDecoder().decode(Bool.self, from: data)
                    legislationCount += 1
                    democraticLegislationsPassed += legislation ? 1 : 0
                    progressPresident()
                    currentTurn = Turn.nominateChancellor.rawValue
                    _delegate.turnDidChange(forGameConfig: self)
                case .performBonus:
                    break
                }
            }
        } catch {
            print(error)
        }
    }
    
    func progressPresident() {
        if let index = _delegate.players(forGameConfig: self).firstIndex(of: currentPresident) {
            if index + 1 > _delegate.players(forGameConfig: self).count {
                currentPresident = _delegate.players(forGameConfig: self)[0]
            } else {
                currentPresident = _delegate.players(forGameConfig: self)[index + 1]
            }
        }
    }
}
