//
//  Theme.swift
//  Logames
//
//  Created by Samuel Wong on 1/7/21.
//

import UIKit
import wongyhelpers

struct Theme {
    enum Colours {
        case Background
        
        private var hex: String {
            switch self {
            case .Background : return "003049"
            }
        }
        
        var colour: UIColor {
            return UIColor.colourWithHexString(self.hex)
        }
    }
}
