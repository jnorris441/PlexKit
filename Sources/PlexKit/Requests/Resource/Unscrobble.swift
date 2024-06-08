
import Foundation

public extension Plex.Request {
    struct Unscrobble: PlexResourceRequest {
        public let path = ":/unscrobble"
        public let httpMethod = "GET"
        public var accept = "*/*"

        public var queryItems: [URLQueryItem]? {
            [
                .init(name: "key", value: ratingKey),
                .init(name: "identifier", value: "com.plexapp.plugins.library"),
            ]
        }

        /// - SeeAlso: `ratingKey` property of `MediaItem`.
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
