//
//  URLSession+extensions.swift
//  BikeSlopeViewer
//
//  Created by William DESECOT on 13/01/2022.
//

import Foundation
import Combine

extension URLSession {
    func publisher<K, R>(for endpoint: Endpoint<K, R>,
                         using requestData: K.RequestData) -> AnyPublisher<R, APIError> {

        guard let request = endpoint.makeRequest(with: requestData) else {
            return Fail(error: .invalidRequest).eraseToAnyPublisher()
        }

        return dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode != 401 else {
                    throw APIError.unauthorized
                }

                guard 200...206 ~= response.statusCode else {
                    throw APIError.serverError(response.statusCode)
                }

                return output.data
            }
            .tryMap { try endpoint.parse($0) }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else if let urlError = error as? URLError,
                          urlError.code == URLError.Code.notConnectedToInternet {
                    return APIError.networkConnectionError
                } else {
                    return APIError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
}
