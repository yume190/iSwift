//
//  JSONConvertable.swift
//  iSwiftCore
//
//  Created by Jin Wang on 19/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation
import Jay

protocol JSONConvertable {
    static func fromJSON(_ json: [String: Any]) -> Self?
    func toJSON() -> [String: Any]
}

extension JSONConvertable {
    func toData() -> Data { return toJSON().toData() }
    func toBytes() -> [UInt8] { return toJSON().toBytes() }
    func toJSONString() -> String {
        return (NSString(data: toData(), encoding: String.Encoding.utf8.rawValue) ?? "") as String
    }
}

extension Dictionary where Key: StringLiteralConvertible, Value: Any {
    func toData() -> Data {
        do {
            return try Jay(formatting: .prettified).dataFromJson(anyDictionary: self)
        } catch let e {
            print("NSJSONSerialization Error: \(e)")
            return Data()
        }
    }
    
    func toBytes() -> [UInt8] {
        let data = toData()
        let count = data.count
        var bytes = [UInt8](repeating: 0, count: count)
        data.copyBytes(to: bytes, count: count)
        
        return bytes
    }
}