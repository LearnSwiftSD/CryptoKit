import Foundation

public enum HexEncodingFormat: String {
    case uppercased = "%02hhX"
    case lowercased = "%02hhx"
}

public extension Sequence where Element == UInt8 {

    static func toHexString(format: HexEncodingFormat = .lowercased) -> (UInt8) -> String {
        return { String(format: format.rawValue, $0) }
    }
    
    func hexString(format: HexEncodingFormat = .lowercased) -> String {
        return map(Self.toHexString(format: format)).joined()
    }
    
}
