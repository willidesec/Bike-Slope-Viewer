//
//  Endpoint.swift
//  BikeSlopeViewer
//
//  Created by William DESECOT on 13/01/2022.
//

import Foundation

struct Endpoint<Kind: EndpointKind, Response> {
    var baseURL: String
    var method: HTTPMethod
    var path: String
    var queryItems = [URLQueryItem]()
    var body: HTTPBody = EmptyBody()
    var parse: (Data) throws -> Response
}

extension Endpoint where Response: Decodable {
    init(baseURL: String,
         method: HTTPMethod = .get,
         path: String,
         queryItems: [URLQueryItem] = [URLQueryItem](),
         body: HTTPBody = EmptyBody(),
         decoder: JSONDecoder = .init()) {

        self.init(baseURL: baseURL,
                  method: method,
                  path: path,
                  queryItems: queryItems,
                  body: body) { data -> Response in
            do {
                return try decoder.decode(Response.self, from: data)
            } catch {
                throw APIError.decodingError
            }
        }
    }
}

extension Endpoint where Response == Void {
    init(baseURL: String,
         method: HTTPMethod = .get,
         path: String,
         queryItems: [URLQueryItem] = [URLQueryItem](),
         body: HTTPBody = EmptyBody()) {

        self.init(baseURL: baseURL,
                  method: method,
                  path: path,
                  queryItems: queryItems,
                  body: body) { _ -> Response in () }
    }
}

extension Endpoint {
    func makeRequest(with data: Kind.RequestData) -> URLRequest? {
        let currentBaseURL = baseURL
        var components = URLComponents(string: currentBaseURL)
        components?.path += "/" + path
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        // If either the path or the query items passed contained
        // invalid characters, we'll get a nil URL back:
        guard let url = components?.url else {
            return nil
        }

        let timeoutInterval: Double = 30
        var request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue

        if body.isEmpty == false {
            // if our body defines additional headers, add them
            for (header, value) in body.additionalHeaders {
                request.addValue(value, forHTTPHeaderField: header)
            }

            // attempt to retrieve the body data
            request.httpBody = try? body.encode()
        }

        Kind.prepare(&request, with: data)
        return request
    }
}

// MARK: - Endpoint kind

protocol EndpointKind {
    associatedtype RequestData
    static func prepare(_ request: inout URLRequest, with data: RequestData)
}

enum EndpointKinds {
    enum Public: EndpointKind {
        static func prepare(_ request: inout URLRequest, with _: Void) {
            request.cachePolicy = .reloadIgnoringLocalCacheData
        }
    }

    enum Protected: EndpointKind {
        static func prepare(_ request: inout URLRequest, with token: String?) {
            if let token = token {
                request.addValue("Bearer \(token)",
                                 forHTTPHeaderField: HTTPHeaderField.authorization.rawValue)
            } else {
                request.cachePolicy = .reloadIgnoringLocalCacheData
            }
        }
    }
    
    enum ThirdPartyProtected: EndpointKind {
        static func prepare(_ request: inout URLRequest, with token: String?) {
            if let token = token {
                request.addValue("Basic \(token)",
                                 forHTTPHeaderField: HTTPHeaderField.authorization.rawValue)
            } else {
                request.cachePolicy = .reloadIgnoringLocalCacheData
            }
        }

    }
}
