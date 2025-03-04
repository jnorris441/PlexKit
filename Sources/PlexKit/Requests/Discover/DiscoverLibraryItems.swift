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
    typealias DiscoverLibraryItems = _DiscoverLibraryItems<PlexMediaDiscoveryItem>

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
        var filters: [Plex.Request.LibraryItems.Filter] = []

        public init(
            key: String?,
            mediaType: PlexMediaType,
            range: CountableClosedRange<Int>? = nil,
            excludeFields: [String] = [],
            filters: [Plex.Request.LibraryItems.Filter] = []
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



// just using the guid.
public struct PlexMediaDiscoveryItem: PlexMediaItemType {
    public var ratingKey: String
    
    public var key: String
    
    public let guid: String?
}

/*
public struct PlexMediaDiscoveryItem: PlexMediaItemType {
    public let ratingKey: String
    public let key: String
    public let parentRatingKey: String?
    public let grandparentRatingKey: String?
    public let guid: String?
    public let parentGuid: String?
    public let grandparentGuid: String?
    public let librarySectionID: Int?
    public let type: PlexMediaType
    public let title: String?
    public let titleSort: String?
    public let grandparentKey: String?
    public let parentKey: String?
    public let grandparentTitle: String?
    public let parentTitle: String?
    public let summary: String?
    public let index: Int?
    public let parentIndex: Int?
    public let ratingCount: Int?
    public let viewCount: Int?
    public let viewOffset: Int?
    public let lastViewedAt: Date?
    public let thumb: String?
    public let art: String?
    public let banner: String?
    public let parentThumb: String?
    public let grandparentThumb: String?
    public let grandparentArt: String?
    public let duration: Int?
    public let addedAt: Date?
    public let updatedAt: Date?
    public let originalTitle: String?
    public let rating: Double?
    public let ratingImage: String?
    public let audienceRating: Double?
    public let audienceRatingImage: String?
    public let userRating: Double?
    public let lastRatedAt: Date?
    public let year: Int?
    public let originallyAvailableAt: String?
    public let studio: String?
    public let tagline: String?
    public let contentRating: String?
    public let chapterSource: String?
    public let theme: String?
    public let parentTheme: String?
    public let grandparentTheme: String?
    public let loudnessAnalysisVersion: String?

    public let allowSync: Bool?
    public let leafCount: Int?
    public let viewedLeafCount: Int?
    public let childCount: Int?

    private let Marker: [Marker]?
    private let Media: [Media]?
    private let Genre: [Tag]?
    private let Country: [Tag]?
    private let Style: [Tag]?
    private let Mood: [Tag]?
    private let Director: [Tag]?
    private let Writer: [Tag]?
    private let Role: [Tag]?

    // Playlist.
    public let smart: Bool?
    public let playlistType: PlexPlaylistType?
    public let composite: String?

    public struct Tag: Codable, Hashable {
        public let id: Int?
        public let tag: String
    }

    public struct Marker: Codable, Hashable {
        public let id: Int?
        public let startTimeOffset: Int?
        public let endTimeOffset: Int?
        public let type: String?
        public let markerType: String?
    }

    public struct Media: Codable, Hashable {
        public let id: Int?
        public let duration: Int?
        public let bitrate: Int?
        public let container: String?
        public let has64BitOffsets: Bool?
        public let optimizedForStreaming: Int?

        // Audio.
        public let audioChannels: Int?
        public let audioCodec: String?
        public let audioProfile: String?

        // Video.
        public let width: Int?
        public let height: Int?
        public let aspectRatio: Double?
        public let videoCodec: String?
        public let videoResolution: String?
        public let videoFrameRate: String?
        public let videoProfile: String?

        private let Part: [Part]?

        public var parts: [Part] {
            Part ?? []
        }
    }

    /// A single media part, generally representing a single file.
    public struct Part: Codable, Hashable {
        public let id: Int
        public let key: String
        public let duration: Int?
        public let file: String?
        public let size: Int?
        public let container: String?
        public let hasThumbnail: String?
        public let audioProfile: String?
        public let videoProfile: String?
        public let has64BitOffsets: Bool?
        public let optimizedForStreaming: Int?
        public let indexes: String?

        private let Stream: [Stream]?

        /// Zero or more media streams belonging to the media file.
        ///
        /// When a media file contains only a single stream, `streams` will be empty. In this case,
        /// stream data can be read directly from the `Media` or `Part`.
        public var streams: [Stream] {
            Stream ?? []
        }
    }

    /// Represents a video, audio, subtitle or lyric stream.
    public struct Stream: Codable, Hashable {
        public let id: Int
        private let streamType: Int
        public let streamDefault: Bool?
        public let codec: String
        public let index: Int?
        public let bitrate: Int?
        public let bitDepth: Int?
        public let chromaLocation: String?
        public let chromaSubsampling: String?
        public let codedHeight: Int?
        public let codedWidth: Int?
        public let frameRate: Double?
        public let hasScalingMatrix: Bool?
        public let height: Int?
        public let level: Int?
        public let profile: String?
        public let refFrames: Int?
        public let requiredBandwidths: String?
        public let scanType: String?
        public let width: Int?
        public let displayTitle: String?
        public let extendedDisplayTitle: String?
        public let channels: Int?
        public let language: String?
        public let languageCode: String?
        public let audioChannelLayout: String?
        public let samplingRate: Int?
        public let selected: Bool?
        public let title: String?
        public let headerCompression: Bool?
        public let colorPrimaries: String?
        public let colorSpace: String?
        public let colorRange: String?
        public let colorTrc: String?
        public let DOVILevel: Int?
        public let DOVIProfile: Int?
        public let codecID: String?


        public var type: StreamType {
            .init(rawValue: streamType)
        }

        public enum StreamType: Hashable {
            /// A video stream.
            case video
            /// An audio stream.
            case audio
            /// A subtitle stream.
            case subtitle
            /// A lyric stream.
            case lyrics
            /// An unknown stream type.
            case unknown(Int)

            init(rawValue: Int) {
                switch rawValue {
                case 1:
                    self = .video
                case 2:
                    self = .audio
                case 3:
                    self = .subtitle
                case 4:
                    self = .lyrics
                default:
                    self = .unknown(rawValue)
                }
            }
        }
    }
}
*/
