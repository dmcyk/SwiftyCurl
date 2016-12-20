//
//  CurlSlist.swift
//  SwiftyCurl
//
//  Created by Damian Malarczyk on 07.07.2016.
//
//
import CCurl

/**
 Swift curl's slist wrapper
 */
public class cURLSlist  {
    
    /**
     raw curl's slist pointer
     */
    public private(set) var rawSlist: UnsafeMutablePointer<curl_slist>? = nil
    
    /**
     initialize from Swift's string array
     */
    public init(fromArray: [String]) {
        var slist: UnsafeMutablePointer<curl_slist>? = nil
        fromArray.forEach {
            let _ = $0.withCString { str in
                slist = curl_slist_append(slist, str)
            }
        }
        rawSlist = slist
    }
    
    /**
     append element
     */
    public func append(_ element: String) {
        rawSlist = curl_slist_append(rawSlist, element)
    }
    
    deinit {
        curl_slist_free_all(rawSlist)
    }
}
