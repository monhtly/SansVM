import Foundation
import UIKit

// Pairing file import for Built-in StikJIT.
// INTEGRATION.md recommends Documents/StikJIT/pairingFile.plist.
// Madeira stores it in Keychain instead, so Files / guest VMs cannot read it.
// We follow Madeira: import once, store in Keychain, delete any Documents copy.

enum JITPairing {
    static let keychainService = "com.sans.vm.jit-pairing"
    static let keychainAccount = "pairingFile"

    static var hasPairingFile: Bool {
        // Check Keychain first, then legacy Documents path for migration.
        return keychainData() != nil || legacyFileURL() != nil
    }

    static func legacyFileURL() -> URL? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent("StikJIT/pairingFile.plist")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    static func keychainData() -> Data? {
        // TODO: SecItemCopyMatching, kSecClassGenericPassword, service + account above.
        // Return nil until wired. Do not log contents.
        return nil
    }

    // Called from UIDocumentPickerViewController delegate.
    // Use security-scoped access while copying, replace atomically, do not log contents.
    static func importPairingFile(from url: URL) throws {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        let data = try Data(contentsOf: url)
        // TODO: store data in Keychain, delete legacy Documents copy if present.
        _ = data
    }

    // In-app pairing, iOS 27+ only. Madeira plays the computer for its own iPhone.
    // Settings > Privacy & Security > Developer Mode > Pair with <App>, enter code.
    // On iOS 26, this path is not available. Use import from computer instead.
    static var supportsInAppPairing: Bool {
        if #available(iOS 27, *) { return true }
        return false
    }
}
