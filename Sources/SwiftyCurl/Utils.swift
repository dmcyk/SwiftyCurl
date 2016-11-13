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
    
    func realPath() -> String {
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(PATH_MAX))
        realpath(self, buffer)
        
        let newValue = String(cString: buffer)
        buffer.deinitialize(count: Int(PATH_MAX))
        buffer.deallocate(capacity: Int(PATH_MAX))
        return newValue
    }
}


