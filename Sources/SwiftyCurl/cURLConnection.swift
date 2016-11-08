//
//  File.swift
//  EasyAPNS
//
//  Created by Damian Malarczyk on 04.07.2016.
//
//
#if os(Linux)
    @_exported import Glibc
#else
    @_exported import Darwin.C
#endif
import CCurl
import Foundation

/**
 */
open class cURLConnection {
    
    /**
     connection's curl reference
     */
    public let curl: cURL
    
    /**
     absolute path to certificate which is to be used during connection
     */
    public var certificatePath: String? = nil {
        didSet {
            if let cert = certificatePath {
                didSet(certificatePath: cert)
            }
        }
    }
    
    func didSet(certificatePath: String) {
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(PATH_MAX))
        realpath(certificatePath, buffer)
        curl.set(.sslCert, value: String(cString: buffer))
        buffer.deinitialize(count: Int(PATH_MAX))
        buffer.deallocate(capacity: Int(PATH_MAX))
    }
    
    /**
     custom user-agent
     */
    public var userAgent: String? {
        didSet {
            didSet(userAgent: userAgent)
        }
    }
    
    func didSet(userAgent: String?) {
        guard let userAgent = userAgent else { return }
        curl.set(.userAgent, value: userAgent)
    }
    
    /**
     optional certificate's passphrase
     */
    public var certificatePassphrase: String? = nil {
        didSet {
            didSet(certificatePassphrase: certificatePassphrase)
        }
    }
    
    func didSet(certificatePassphrase: String?) {
        guard let certificatePassphrase = certificatePassphrase else { return }
        curl.set(.passPhrase, value: certificatePassphrase)
    }
    
    /**
     path to certificate authority file
     */
    public var caCertificatePath: String? {
        didSet {
            didSet(caCertificatePath: caCertificatePath)
        }
    }
    
    func didSet(caCertificatePath: String?) {
        if let caCertificatePath = caCertificatePath {
            let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(PATH_MAX))

            realpath(caCertificatePath, buffer)
            curl.set(.sslVerifyPeer, value: 1)
            curl.set(.caPath, value: String(cString: buffer))
            buffer.deinitialize(count: Int(PATH_MAX))
            buffer.deallocate(capacity: Int(PATH_MAX))
        } else {
            curl.set(.sslVerifyPeer, value: 0)
        }
    }
    
    /**
     request url
     */
    public var url: String? {
        didSet {
            if let url = url {
                didSet(url: url)
            }
        }
    }
    
    func didSet(url: String) {
        curl.set(.url, value: url)
    }
    
    /**
     request port
     */
    public var port: Int  = 0 {
        didSet {
            didSet(port: port)
        }
    }
    
    func didSet(port: Int) {
        curl.set(.port, value: port)
    }
    
    /**
     request's maximum timeout
     */
    public var timeout: Int {
        didSet {
            didSet(timeout: timeout)
        }
    }
    
    func didSet(timeout: Int) {
        curl.set(.timeout, value: timeout)
    }
    
    /**
     - parameter certificatePath:String absolute path to certificate used to instantiate secure connection
     */
    public init(timeout: Int = 20) {
        self.curl = cURL()
        self.timeout = timeout
        curl.set(.httpVersion, value: CURL_HTTP_VERSION_1_1)
        didSet(timeout: timeout)
//        curl.set(.useSsl, value: true)
//        curl.set(.sslEngineDefault, value: true)
    }
    public enum Error: Swift.Error {
        case incorrectURL
    }
    
    
    func setURLFrom(request: cURLRequest) throws {
        var urlString: String?

        var port: String?
        let cmp = URLComponents(url: request.url, resolvingAgainstBaseURL: true)
        
        if let urlStr: String = cmp?.string, let portRange = cmp?.rangeOfPort {
            
            let colonRange = Range<String.Index>(uncheckedBounds: (urlStr.index(before: portRange.lowerBound),portRange.upperBound))
            port = cmp?.string?.substring(with: portRange)
            urlString = cmp?.string
            urlString?.replaceSubrange(colonRange, with: "")
        } else {
            urlString = cmp?.string
        }
        
        guard let urlStr = urlString else {
            throw Error.incorrectURL
        }
        
        self.url = urlStr
        if let prt = port, let portValue = Int(prt) {
            self.port = portValue
        } else {
            self.port = 80
        }
    }
    
    open func request(_ req: cURLRequest) throws -> cURLResponse? {
        
        try setURLFrom(request: req)
        let httpHeaders = req.headers.map {
            return "\($0.key): \($0.value)"
        }
        let curlSlist = cURLSlist(fromArray: httpHeaders)
        curl.setSlist(.httpHeader, value: curlSlist.rawSlist)
        curl.set(.get, value: false)
        curl.set(.post, value: false)
        curl.set(.delete, value: nil)

        if let body = req.body {
            body.withUnsafeBytes {
                curl.set(.postFields, value: $0)
            }
        }
        
        switch req.method {
        case .get:
            curl.set(.get, value: true)
        case .post:
            curl.set(.post, value: true)
        case .delete:
            curl.set(.delete, value: "DELETE")
        }
        
        
        let result = try curl.execute() // persist reference to header's slist 
        return result 
    }
}

