//
//  LibraryItems.swift
//  PlexKit
//
//  Created by Lachlan Charlick on 31/5/20.
//  Copyright © 2020 Lachlan Charlick. All rights reserved.
//

import Foundation

public extension Plex.Request {
    struct DiscoverLibraryItemUserState: PlexResourceRequest {
        public var path: String { "library/metadata/\(key)/userState" }
        public var queryItems: [URLQueryItem]? {
            var items: [URLQueryItem] = []
            return items
        }

        var key: String

        public init(
            key: String
        ) {
            self.key = key
        }

        public struct Response: Codable {
            public let mediaContainer: MediaContainer
        }
    }
}

public struct PlexUserStateItem: Codable, Hashable {
    public let ratingKey: String?
    public let type: String?
    public let viewOffset: Int? 
    public let watchlistedAt: Date?
}

public extension Plex.Request.DiscoverLibraryItemUserState.Response {
    enum CodingKeys: String, CodingKey {
        case mediaContainer = "MediaContainer"
    }

    struct MediaContainer: Codable, Hashable {
        public let size: Int
        public let totalSize: Int?
        public let allowSync: Bool?
        public let art: String?
        public let identifier: String?
        public let librarySectionID: Int?
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

        private let UserState: [PlexUserStateItem]?

        public var userState: [PlexUserStateItem] {
            UserState ?? []
        }
    }
}
