//
//  main.swift
//  Example
//  SwiftyCurl
//  Created by Damian Malarczyk/dmcyk on 04.07.2016.
//
//

import SwiftyCurl
import Foundation
import CCurl

///// SwiftyCurl

var request = cURLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!, method: .get)
request.contentType = .json

let connection = cURLConnection(useSSL: true)

do {
    let res = try connection.request(request)
    dump(res.headers)

    if let body: String = res.body() {
        print("\nBody:\n")
        print(body)
    }
    
} catch {
    dump(error)
}



///// raw curl - that's a simple GET request, POST etc would require even more code to setup request's body


// basic SSL setup
let rawcon = curl_easy_init()

curlHelperSetOptString(rawcon, CURLOPT_URL, "https://jsonplaceholder.typicode.com/posts")
curlHelperSetOptInt(rawcon, CURLOPT_SSL_VERIFYHOST, 2)
curlHelperSetOptBool(rawcon, CURLOPT_USE_SSL, CURL_TRUE)
curlHelperSetOptBool(rawcon, CURLOPT_SSLENGINE_DEFAULT, CURL_TRUE)
curlHelperSetOptBool(rawcon, CURLOPT_HTTPGET, CURL_TRUE)


// json header
let headers = ["Accept": "application/json"]
let rawHeaders = headers.map {
    return "\($0.key): \($0.value)"
}

var slist: UnsafeMutablePointer<curl_slist>? = nil

rawHeaders.forEach {
    slist = curl_slist_append(slist, $0)
}

curlHelperSetOptList(rawcon, CURLOPT_HTTPHEADER, slist)

// header, body buffers
var headerBuff = Data(count: 0)
var bodyBuff = Data(count: 0)

var headerPointer = withUnsafeMutablePointer(to: &headerBuff) { $0 }
var bodyPointer = withUnsafeMutablePointer(to: &bodyBuff) { $0 }
curlHelperSetOptVoid(rawcon, CURLOPT_HEADERDATA, headerPointer)
curlHelperSetOptVoid(rawcon, CURLOPT_WRITEDATA, bodyPointer)

curlHelperSetOptFunc(rawcon, CURLOPT_WRITEFUNCTION) { (data, size, nmemb, userData) -> Int in
    
    if nmemb > 0, let response = userData?.assumingMemoryBound(to: Data.self),
        let characters = data?.assumingMemoryBound(to: UInt8.self) {
        response.pointee.append(characters, count: nmemb)
    }
    
    return size * nmemb
}
curlHelperSetOptFunc(rawcon, CURLOPT_HEADERFUNCTION) { (data, size, nmemb, userData) -> Int in
    if nmemb > 0, let response = userData?.assumingMemoryBound(to: Data.self),
        let characters = data?.assumingMemoryBound(to: UInt8.self) {
        response.pointee.append(characters, count: nmemb)
        
    }
    return size * nmemb
}

let start = curl_easy_perform(rawcon)
if start != CURLE_OK {
    print(String(cString: curl_easy_strerror(start)))
    
} else {
    
    // Headers in curl are simply separated by \r\n, SwiftyCurl takes care of that and headers are in an array with already trimmed \r\n (trimming is optional)
    dump(String(data: headerBuff, encoding: .utf8))
    
    print("\nBody:\n")
    if let body = String(data: bodyBuff, encoding: .utf8) {
        print(body)
    } else {
        print("No body :c")
    }
}

curl_slist_free_all(slist)
curl_easy_cleanup(rawcon)

