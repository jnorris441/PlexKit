//
//  RemoveFromWatchList.swift
//  PlexKit
//
//  Created by Lachlan Charlick on 31/5/20.
//  Copyright © 2020 Lachlan Charlick. All rights reserved.
//

import Foundation

public extension Plex.Request {
    struct AddToWatchlist: PlexResourceRequest {
        public let path = ":/actions/addToWatchlist"
        public let httpMethod = "PUT"
        public var accept = "*/*"

        public var queryItems: [URLQueryItem]? {
            [
                .init(name: "ratingKey", value: ratingKey),
            ]
        }

        private let ratingKey: String

        public init(ratingKey: String) {
            self.ratingKey = ratingKey
        }

        public static func response(from data: Data) throws -> Data {
            // Empty response.
            data
        }
    }
}
