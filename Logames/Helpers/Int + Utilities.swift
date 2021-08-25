//
//  Int + Utilities.swift
//  Logames
//
//  Created by Samuel Wong on 21/8/21.
//

extension Int {
    func toBooleanArray(capacity: Int) -> [Bool] {
        var toReturn: [Bool] = []
        
        for i in 0 ..< capacity {
            toReturn.append(i < self)
        }
        
        return toReturn
    }
}
