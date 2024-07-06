
import Foundation


public extension Plex.Request {
    struct Prefs: PlexResourceRequest {
        public let path = ":/prefs"
        public let queryItems: [URLQueryItem]? = nil
        public let httpMethod = "GET"
        public let accept = "application/json"

        public init() {}

        public struct Response: Codable {
            public let mediaContainer: MediaContainer
        }

    }
}

public struct PlexSetting: Codable {
    enum CodingKeys: String, CodingKey {
        case defaultValue = "default", id, label, summary, type, value, hidden, advanced, group
    }
    public var id:String?
    public var label:String?
    public var summary:String?
    public var type:String?
    public var defaultValue:SettingValue?
    public var value:SettingValue?
    public var hidden:Bool?
    public var advanced:Bool?
    public var group:String?
    
    public enum SettingValue: Codable {
            case intValue(Int)
            case stringValue(String)
            case boolValue(Bool)

        public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let intValue = try? container.decode(Int.self) {
                    self = .intValue(intValue)
                } else if let stringValue = try? container.decode(String.self) {
                    self = .stringValue(stringValue)
                } else if let boolValue = try? container.decode(Bool.self) {
                    self = .boolValue(boolValue)
                } else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
                }
            }

        public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .intValue(let int):
                    try container.encode(int)
                case .stringValue(let string):
                    try container.encode(string)
                case .boolValue(let bool):
                    try container.encode(bool)
                }
            }
        }
}

public extension Plex.Request.Prefs.Response {
    enum CodingKeys: String, CodingKey {
        case mediaContainer = "MediaContainer"
    }

    struct MediaContainer: Codable {

        public enum CodingKeys: String, CodingKey {
            case setting = "Setting"
        }

        public let setting: [PlexSetting]
    }
}
