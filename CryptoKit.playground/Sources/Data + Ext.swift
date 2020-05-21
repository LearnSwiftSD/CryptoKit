import CryptoKit
import Foundation

public extension Data {
    
    /// Warning: Raw Value represention in Bytes
    enum SaltSize: Int {
        case bits256 = 32
        case bits384 = 48
        case bits512 = 64
    }
    
    static func salt(ofSize saltSize: SaltSize = .bits256) -> Data {
        // Produce data (all zeros) of the specified size
        var data = Data(count: saltSize.rawValue)
        
        // Randomize the data in a cryptographically secure way
        _ = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, saltSize.rawValue, $0.baseAddress!)
        }
        
        // return the randomized data
        return data
    }
    
    var utf8String: String {
        return String(data: self, encoding: .utf8) ?? ""
    }
    
}
