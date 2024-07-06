//
//  HTTPHeaderField.swift
//  BikeSlopeViewer
//
//  Created by William DESECOT on 17/01/2022.
//

import Foundation

enum HTTPHeaderField: String {
    case authorization = "Authorization"
    case contentType = "Content-Type"
}

enum ContentType: String {
    case json = "application/json"
}
