//
//  Collections2.swift
//  PlexKit
//
//  Created by Lachlan Charlick on 18/10/21.
//  Copyright © 2021 Lachlan Charlick. All rights reserved.
//

import Foundation

public extension Plex.Request {
    /// New collections endpoint. Supports smart collections.
    /// Requires Plex Media Server 1.22.3.4392.
    struct Collections2: PlexResourceRequest {
        public var path: String { "library/sections/\(libraryKey)/collections" }

        private let libraryKey: String
        private let mediaType: PlexMediaType?
        var range: CountableClosedRange<Int>?
        var excludeFields: [String] = []
        var filters: [Filter] = []

        public var queryItems: [URLQueryItem]? {
            var items: [URLQueryItem] = []

            if mediaType != nil {
                items.append(URLQueryItem(name: "subtype", value: mediaType!.key))
            }

            if let range = range {
                items.append(contentsOf: pageQueryItems(for: range))
            }

            for filter in filters {
                guard let queryItem = filter.queryItem else { continue }
                items.append(queryItem)
            }

            let excludeFields = [
                // This field can contain invalid unicode characters, causing
                // JSON decode errors. We don't use the field currently, so it can
                // be explicitly excluded here.
                "file",
            ] + self.excludeFields

            items.append(
                URLQueryItem(
                    name: "excludeFields",
                    value: excludeFields.joined(separator: ",")
                )
            )

            items.append(URLQueryItem.init(name: "includeMeta", value: "1"))
            items.append(URLQueryItem.init(name: "includeAdvanced", value: "1"))
            items.append(URLQueryItem.init(name: "includeExternalMedia", value: "1"))
            items.append(URLQueryItem.init(name: "includeCollections", value: "1"))

            return items
        }

        
        public init(
            libraryKey: String,
            mediaType: PlexMediaType?,
            range: CountableClosedRange<Int>? = nil,
            excludeFields: [String] = [],
            filters: [Filter] = []
        ) {
            self.libraryKey = libraryKey
            self.mediaType = mediaType
            self.range = range
            self.excludeFields = excludeFields
            self.filters = filters            
        }

        public struct Response: Codable {
            public let mediaContainer: MediaContainer

            enum CodingKeys: String, CodingKey {
                case mediaContainer = "MediaContainer"
            }
        }
    }
}


public extension Plex.Request.Collections2 {
    /// Filters the results of a `LibraryItems` request.
    enum Filter {
        /// Requests items in a specific set.
        case keys(Set<String>)

        /// Filters by a field in the result type.
        case property(name: String, Comparison, String)

        /// Filters by a date field in the result type.
        case dateProperty(name: String, Comparison, Date)

        /// Filters by items in a given collection.
        case collection(id: String)

        fileprivate var queryItem: URLQueryItem? {
            switch self {
            case let .keys(keys):
                guard !keys.isEmpty else { return nil }
                return .init(name: "id", value: keys.joined(separator: ","))
            case let .property(name, comparison, value):
                return .init(name: name + comparison.rawValue, value: value)
            case let .dateProperty(name, comparison, value):
                return .init(name: name + comparison.rawValue, value: String(Int(value.timeIntervalSince1970)))
            case let .collection(id):
                return .init(name: "collection", value: id)
            }
        }

        public enum Comparison: String {
            case greaterThan = ">"
            case lessThan = "<"
            case equal = ""
        }
    }
}

public extension Plex.Request.Collections2 {
    struct MediaContainer: Codable {
        public let size: Int
        public let totalSize: Int?
        public let allowSync: Bool?
        public let art: String?
        public let content: String?
        public let identifier: String?
        public let mediaTagPrefix: String?
        public let mediaTagVersion: Int?
        public let nocache: Bool?
        public let thumb: String?
        public let title1: String?
        public let title2: String?
        public let viewGroup: String?
        public let viewMode: Int?
        private let Metadata: [PlexCollection]?

        public var metadata: [PlexCollection] {
            Metadata ?? []
        }
    }
}
