//
//  APIError.swift
//  BikeSlopeViewer
//
//  Created by William DESECOT on 13/01/2022.
//

import Foundation

enum APIError: Error {
    /// If we are unable to build the request
    case invalidRequest
    /// The response format could not be decoded into the expected type
    case decodingError
    /// If jwt token has expired or not valid
    case unauthorized
    /// The request could not be made (due to a timeout, missing connectivity, offline, etc).
    case networkConnectionError
    /// The server return an error with a status code
    case serverError(Int)
    case customError(Error)
    case unknown
}
