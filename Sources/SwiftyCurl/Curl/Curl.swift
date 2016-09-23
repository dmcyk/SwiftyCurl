//
//  Curl.swift
//  EasyAPNS
//
//  Created by Damian Malarczyk on 04.07.2016.
//
//
import cURL

/**
 Swift curl wrapper 
 */
public class cURL {
    
    /**
     raw C's curl pointer
     */
    public let rawCURL: UnsafeMutableRawPointer
    
    /**
     instantiate curl lib with easy interface
     */
    public init() {
        rawCURL = curl_easy_init()
    }
    
    deinit {
        curl_easy_cleanup(rawCURL)
    }
    
    /**
     - parameter option:CurlSetOption option to set
     - parameter value:Int value for option
     */
    public func set(_ option: cURLSetOption, value: Int) {
        curl_easy_setopt_long(rawCURL, option.raw, value)
    }
    
    
    /**
     - parameter option:CurlSetOption option to set
     - parameter value:UnsafePointer<Int8> value for option
     */
    public func set(_ option: cURLSetOption, value: UnsafePointer<Int8>?) {
        curl_easy_setopt_cstr(rawCURL, option.raw, value)
    }
    
    /**
     - parameter option:CurlSetOption option to set
     - parameter value:Int64 value for option
     */
    public func set(_ option: cURLSetOption, value: Int64) {
        curl_easy_setopt_int64(rawCURL, option.raw, value)

    }
    
    /**
     - parameter option:CurlSetOption option to set
     - parameter value:UnsafeMutablePointer<curl_slist> slist pointer
     */
    public func setSlist(_ option: cURLSetOption, value: UnsafeMutablePointer<curl_slist>) {
        curl_easy_setopt_slist(rawCURL, option.raw, value)
    }
    
    /**
     - parameter option:CurlSetOption curl's option to set
     - parameter value:UnsafeMutablePointer<Void> value for option
     */
    public func set(_ option: cURLSetOption, value: UnsafeMutableRawPointer) {
        curl_easy_setopt_void(rawCURL, option.raw, value)
    }
    
    /**
     - parameter option:CurlSetOption option to set
     - parameter value:Bool value for option
     */
    public func set(_ option: cURLSetOption, value: Bool) {
        curl_easy_setopt_long(rawCURL, option.raw, value ? 1 : 0)
    }
    
    /**
     - parameter option:CurlSetOption option to set
     - parameter optionType:CurlOptionType wrapped option value
     */
    public func set(_ option: cURLSetOption, optionType: cURLOptionType) {
        switch optionType {
        case .int(let val):
            set(option, value: val)
        case .int64(let val):
            set(option, value: val)
        case .upInt8(let val):
            set(option, value: val)
        case .umpCurlSlist(let val):
            setSlist(option, value: val)
        case .umpVoid(let val):
            set(option, value: val)
        }
    }
    
    /**
     * helper method, batch options setting
     - parameter data:[CurlSetOption: CurlOptionType] curl's options data
     */
    public func set(_ data: [cURLSetOption: cURLOptionType]) {
        data.enumerated().forEach { _, element in
            set(element.key, optionType: element.value)
        }
    }
    
    /**
     - parameter option:CurlGetOption option to get
     - returns:Int value for given option
     */
    public func get(_ option: cURLGetOption) -> Int {
        var result = 0
        curl_easy_getinfo_long(rawCURL, option.raw, &result)
        return result
    }
    
    /**
     - parameter parseMode:CurlParse when set to `trimNewLineCharacters` new line characters will be trimmed from response headers
     - returns:CurlResponse wrapped curl's reponse for request with actuall settings 
     */
    public func execute(_ parseMode: cURLParseOption = .trimNewLineCharacters) throws -> cURLResponse {
        var response = cURLResponse(parseMode: parseMode)
        let responsePointer = withUnsafeMutablePointer(to: &response) { UnsafeMutableRawPointer($0) }
        
        curl_easy_setopt_void(rawCURL, CURLOPT_HEADERDATA, responsePointer)
        curl_easy_setopt_void(rawCURL, CURLOPT_WRITEDATA, responsePointer)
        curl_easy_setopt_func(rawCURL, CURLOPT_WRITEFUNCTION) { (data, size, nmemb, userData) -> Int in

            if nmemb > 0, let response = userData?.assumingMemoryBound(to: cURLResponse.self),
                let characters = data?.assumingMemoryBound(to: CChar.self) {
                
                let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: size * nmemb + 1)
                strcpy(buffer, characters)
                buffer[size * nmemb] = 0
                var resultString = String(cString: buffer)
                if case .trimNewLineCharacters = response.pointee.parseMode {
                    resultString.trimHTTPNewline()
                }
                response.pointee.body.append(resultString)
                
                buffer.deinitialize()
                buffer.deallocate(capacity: size * nmemb + 1)
            }
            
            return size * nmemb
        }
        curl_easy_setopt_func(rawCURL, CURLOPT_HEADERFUNCTION) { (data, size, nmemb, userData) -> Int in
            if nmemb > 0, let response = userData?.assumingMemoryBound(to: cURLResponse.self),
                let characters = data?.assumingMemoryBound(to: CChar.self) {

                let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: size * nmemb + 1)
                strcpy(buffer, characters)
                buffer[size * nmemb] = 0
                var resultString = String(cString: buffer)
                if case .trimNewLineCharacters = response.pointee.parseMode {
                    // HTTP's headers end with CRLF line break
                    resultString.trimHTTPNewline()
                }
                response.pointee.headers.append(resultString)
                
                buffer.deinitialize()
                buffer.deallocate(capacity: size * nmemb + 1)
                
            }
            return size * nmemb
        }
        let start = curl_easy_perform(rawCURL)
        
        if start != CURLE_OK {
            throw cURLError(curlCode: start)
        }
        
        if case .trimNewLineCharacters = parseMode {
            // HTTP headers are separated by one line contating only CRLF
            let _ = response.headers.popLast()
        }
        
        response.code = get(.httpResponseCode)
        
        return response
    }
    
}






