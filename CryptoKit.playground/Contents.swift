/*
Cryptography Terms and Definitions
- - - - - - - - - - - - - - - - -

Hash - A hashing function is a way of converting a given value of arbitrary size into a
       deterministic (always the same) output of a predetermined length (size).

Digest - The output of a hash function. Also known as the hash value.

SHA - (Secure Hashing Algorithm) A hashing function that is sufficiently secure by having a psuedo
       random (looks but is not random) output based on the input given to be hashed. Additionally
       a secure hash will be non-invertible meaning that the original input cannot be
       reverse-engineered.

Encryption - The process of converting data into an unrecognizable format (Cipher Text) by the use
       of a key. Using the key that encrypted the data is the only way to decrypt (convert back)
       the data to the original format.

Salt - A random (non-secret) value that adds complexity and security to a hashing function in order
       to prevent a category of attacks known as precomputation attacks.

Nonce - Stands for "A Number Used Once." As the name implies this is typically a throw-away value
       used only once or in shortened, predetermined life-cycles. Like the Salt, it is a random
       (non-secret) value intended to add complexity and security. Specifically, it is commonly
       used alongside encryptions to prevent a category of attacks known as replay attacks.

Keys (Asymmetric/Symmetric) -
       (Asymmetric Keys) - A set of Keys that a user holds, one of them being private (only that
       user knows and has access to it) and the other being public, which can be shared and
       stored publicly.
       (Symmetric Keys) - A set of identicle keys that are held and stored secretly between two
       users for the purpose of encrypting and decrypting data between the two.

Diffie-Hellmen Key Exchange - Also known as a Key Agreement, is a way for two parties to
       derive a set of symmetric (identicle) encryption keys through a series of exchanges. This
       allows them to send encrypted data back and forth without anyone else being able to get a
       copy or derive the key themselves though what's available in the public domain.

ECC (Oversimplified) - Elliptic Curve Cryptography is an efficient mathmatical operation that uses
       large prime numbers allowing us to add data to an existing data set in such a way that the
       original data set cannot (effectively) be reverse engineered. Used extensively in Key
       Exchanges (where it is known as Elliptic Curve Diffie Hellman or ECDH) and in generating
       public keys, where the private key is an input as with Key Signing (where it is known as
       Elliptic Curve Digital Signature Algorithm or ECDSA).

Key Signing - A way of verifying the sender and integrity of content sent by signing the content
       with a private key and verifying it with a public key.

AES-GCM - Advanced Encryption Standard using the Galois Counter Mode

HKDF - Hash-based message authentication (HMAC) key derivation function

NIST - National Institute of Standards and Technology

*/


import CryptoKit
import Foundation


// MARK: - Secure Hashing

let messageToHash = "This is my message to hash".data(using: .utf8)!

let messageHash = SHA256.hash(data: messageToHash)

print(messageHash.hexString())

let anotherMessageToHash = "This is my message to hash".data(using: .utf8)!

let anotherMessageHash = SHA256.hash(data: anotherMessageToHash)

messageHash == anotherMessageHash

// MARK: - Encryption

/// A key that you want to keep secret - Stored securely
let symmetricKey = SymmetricKey(size: .bits256)

let aMessageToEncrypt = "This is my super secret message".data(using: .utf8)!

let sealedMessage = try! AES.GCM.seal(aMessageToEncrypt, using: symmetricKey)

let decryptedMessage = try! AES.GCM.open(sealedMessage, using: symmetricKey)

print(String(data: decryptedMessage, encoding: .utf8)!)

// MARK: - Key Signing

/// Hidden Key Not Available to anyone else
let personalPrivateKey = P521.Signing.PrivateKey()

/// Unhidden key that anyone can publicly refer to
let personalPublicKey = personalPrivateKey.publicKey

let somethingISent = "My authenticated message - I was the one who sent this, I promise.".data(using: .utf8)!

let signature = try! personalPrivateKey.signature(for: somethingISent)


let aTamperedMessage = "My authenticated message - 🤣 was the one who sent this, I promise.".data(using: .utf8)!

let anotherPersonsPrivKey = P521.Signing.PrivateKey()

let anotherSignature = try! anotherPersonsPrivKey.signature(for: somethingISent)

personalPublicKey.isValidSignature(anotherSignature, for: somethingISent)

// MARK: - Key Agreement

let sharedSalt = Data.salt(ofSize: .bits256)

let sharedInfo = Data()

// Bobs Keys

let bobsPrivateKey = P521.KeyAgreement.PrivateKey()

let bobsPublicKey = bobsPrivateKey.publicKey


// Alices Keys

let alicesPrivateKey = P521.KeyAgreement.PrivateKey()

let alicesPublicKey = alicesPrivateKey.publicKey

let alicesSharedSecret = try! alicesPrivateKey.sharedSecretFromKeyAgreement(with: bobsPublicKey)

let alicesSymmetricKey = alicesSharedSecret.hkdfDerivedSymmetricKey(
    using: SHA256.self,
    salt: sharedSalt,
    sharedInfo: sharedInfo,
    outputByteCount: 32
)

// Bob again

let bobsSharedSecret = try! bobsPrivateKey.sharedSecretFromKeyAgreement(with: alicesPublicKey)

let bobsSymmetricKey = bobsSharedSecret.hkdfDerivedSymmetricKey(
    using: SHA256.self,
    salt: sharedSalt,
    sharedInfo: sharedInfo,
    outputByteCount: 32
)

bobsSymmetricKey == alicesSymmetricKey

let bobsMessage = "Hello".data(using: .utf8)!

let bobsSealedMessage = try! AES.GCM.seal(bobsMessage, using: bobsSymmetricKey)

let alicesRecievedMessage = try! AES.GCM.open(bobsSealedMessage, using: alicesSymmetricKey)

print(alicesRecievedMessage.utf8String)
