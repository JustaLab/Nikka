//
//  ParameterEncoding.swift
//  HerPlayground
//
//  Created by Emilien on 10/1/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation

public enum ParameterEncoding {
    case url, json, urLinBody
    
    static func defaultEncodingForMethod(_ method:HTTPMethod) -> ParameterEncoding{
        switch method {
        case .GET, .CONNECT, .HEAD, .OPTIONS, .PATCH, .DELETE, .TRACE :
            return .url
        case .POST, .PUT :
            return .json
        }
    }
}

extension URLRequest{
    
    mutating func encode(parameters:[String:Any]?, encoding:ParameterEncoding) -> JustaError? {
        guard let parameters = parameters else {return nil}
        var err:JustaError?
        switch encoding{
        case .url:
            var urlComponents = URLComponents(url: self.url!, resolvingAgainstBaseURL: false)
            if urlComponents != nil && !parameters.isEmpty {
                let paramString = (parameters.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
                let percentEncodedQuery = (urlComponents!.percentEncodedQuery.map { $0 + "&" } ?? "") + paramString
                urlComponents!.percentEncodedQuery = percentEncodedQuery
                self.url = urlComponents!.url
            }
            
        case .json:
            do {
                let options = JSONSerialization.WritingOptions()
                let data = try JSONSerialization.data(withJSONObject: parameters, options: options)
                
                if self.value(forHTTPHeaderField: "Content-Type") == nil {
                    self.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                
                self.httpBody = data
            } catch {
                err = JustaNetworkingError.parameterEncoding(parameters)
            }
        case .urLinBody:
            
            let paramString = (parameters.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
            if self.value(forHTTPHeaderField: "Content-Type") == nil {
                self.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            }
            self.httpBody = paramString.data(using: String.Encoding.utf8, allowLossyConversion: false)
        }
        return err
    }
}