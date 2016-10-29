//
//  Utils.swift
//  EasyAPNS
//
//  Created by Damian Malarczyk on 04.07.2016.
//
//

internal extension String {
    
    /**
     HTTP entries end with \r\n, which this method trims 
     */
    mutating func trimHTTPNewline() {
        if let preEndLineIndex = index(endIndex, offsetBy: -1, limitedBy: startIndex) {
            removeSubrange(Range<Index>(uncheckedBounds: (preEndLineIndex,endIndex)))
            
        }
    }
}
