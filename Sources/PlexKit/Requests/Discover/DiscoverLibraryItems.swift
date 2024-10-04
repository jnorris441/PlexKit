//
//  DiscoverLibraryItems.swift
//  PlexKit
//
//  Created by Lachlan Charlick on 31/5/20.
//  Copyright © 2020 Lachlan Charlick. All rights reserved.
//

import Foundation

public extension Plex.Request {
    /// Fetches a library's contents.
    typealias DiscoverLibraryItems = _DiscoverLibraryItems<PlexMediaItem>

    struct _DiscoverLibraryItems<MediaItem: PlexMediaItemType>: PlexResourceRequest {
        public var path: String { "library/\(key != nil ? "sections/\(key!)/" : "")all" }
        public var queryItems: [URLQueryItem]? {
            var items: [URLQueryItem] = []

            if mediaType.key != -1 {
                items.append(URLQueryItem(name: "type", value: mediaType.key))
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

            return items
        }

        var key: String?
        var mediaType: PlexMediaType
        var range: CountableClosedRange<Int>?
        var excludeFields: [String] = []
        var filters: [Plex.Request._LibraryItems.Filter] = []

        public init(
            key: String?,
            mediaType: PlexMediaType,
            range: CountableClosedRange<Int>? = nil,
            excludeFields: [String] = [],
            filters: [Plex.Request._LibraryItems.Filter] = []
        ) {
            self.key = key
            self.mediaType = mediaType
            self.range = range
            self.excludeFields = excludeFields
            self.filters = filters
        }

        public struct Response: Codable {
            public let mediaContainer: MediaContainer
        }
    }
}

public extension Plex.Request._DiscoverLibraryItems.Response {
    enum CodingKeys: String, CodingKey {
        case mediaContainer = "MediaContainer"
    }

    struct MediaContainer: Codable, Hashable {
        public let size: Int
        public let totalSize: Int?
        public let allowSync: Bool?
        public let art: String?
        public let identifier: String?
        public let librarySectionID: String?
        public let librarySectionTitle: String?
        public let librarySectionUUID: String?
        public let mediaTagPrefix: String?
        public let mediaTagVersion: Int?
        public let nocache: Bool?
        public let offset: Int?
        public let thumb: String?
        public let title1: String?
        public let title2: String?
        public let viewGroup: PlexMediaType?
        public let viewMode: Int?

        private let Metadata: [MediaItem]?

        public var metadata: [MediaItem] {
            Metadata ?? []
        }
    }
}
