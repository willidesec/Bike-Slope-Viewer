//
//  HTTPBody.swift
//  BikeSlopeViewer
//
//  Created by William DESECOT on 13/01/2022.
//

import Foundation

public protocol HTTPBody {
    var isEmpty: Bool { get }
    var additionalHeaders: [String: String] { get }
    func encode() throws -> Data
}

public extension HTTPBody {
    var isEmpty: Bool {
        return false
    }

    var additionalHeaders: [String: String] {
        return [:]
    }
}

public struct EmptyBody: HTTPBody {
    public let isEmpty = true

    public init() {
        // As there is no Body, the init is empty
    }

    public func encode() throws -> Data {
        Data()
    }
}

public struct DataBody: HTTPBody {
    public var isEmpty: Bool { data.isEmpty }
    public var additionalHeaders: [String: String]

    private let data: Data

    public init(_ data: Data, additionalHeaders: [String: String] = [:]) {
        self.data = data
        self.additionalHeaders = additionalHeaders
    }

    public func encode() throws -> Data {
        data
    }
}

public struct JSONBody: HTTPBody {
    public let isEmpty: Bool = false
    public let additionalHeaders = [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]

    private let encoding: () throws -> Data

    public init<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) {
        self.encoding = { try encoder.encode(value) }
    }

    public func encode() throws -> Data {
        try encoding()
    }
}
