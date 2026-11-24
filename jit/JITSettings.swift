import Foundation

// Settings > JIT
// Built-in StikJIT first, StikDebug fallback, Wait for Debugger last.
// Based on StikDebug/StikJIT INTEGRATION.md Part 2 and Madeira docs/JIT.md

enum JITMethod: String, CaseIterable {
    case builtin = "builtin"       // Built-in StikJIT, default
    case stikDebug = "stikdebug"   // External StikDebug app
    case waitForDebugger = "wait"  // Xcode / manual debugger attach
}

struct JITStatus {
    var method: JITMethod
    var txmPresent: Bool?          // StikJIT.isTXMPresent
    var getTaskAllow: Bool
    var pairingFilePresent: Bool
    var vpnReachable: Bool
    var ddiReady: Bool
    var jitReady: Bool
    var lastError: String?
}

final class JITSettings {
    static let shared = JITSettings()

    // Developer-controlled, NOT a user setting.
    // UTM uses legacy.js on iOS 26. New apps use universal.js.
    // INTEGRATION.md: "The chosen script is developer-controlled and must not become a user setting."
    static let selectedScript = "legacy.js"

    var method: JITMethod = .builtin

    // Called when the user taps Start VM or Enable JIT.
    // Do not require Prepare JIT first; enableJIT performs preparation itself.
    func enableJITIfNeeded(completion: @escaping (Bool, String?) -> Void) {
        // 1. Gate checks, in order. Show exact error, do not silently switch methods.
        guard #available(iOS 17.4, *) else {
            completion(false, "StikJIT requires iOS 17.4 or later.")
            return
        }
        guard JITEntitlements.hasGetTaskAllow else {
            completion(false, "This install does not have get-task-allow. Reinstall with a signing method that preserves it.")
            return
        }
        guard JITPairing.hasPairingFile else {
            completion(false, "Import a valid pairing file before enabling JIT.")
            return
        }
        // 2. Check LocalDevVPN loopback 10.7.0.1 before calling helper.
        // 3. Launch helper extension over XPC with target PID, pairing data, script.
        // 4. Helper calls StikJIT.enableJIT(targetPID:pairingFile:ddiPaths:script:.legacy, ...)
        // 5. Wait for CS_DEBUGGED, then let QEMU TCG allocate its JIT regions.
        //    On TXM devices the helper's script prepares each RX region via brk #0xf00d.
        // 6. Mark JIT ready only after prepare + detach return successfully.
        completion(false, "Not wired yet: helper extension not merged into UTM fork.")
    }

    func prepareJIT(completion: @escaping (Bool, String?) -> Void) {
        // Helper calls StikJIT.prepareDevice(pairingFile:paths:) { stage in report(stage) }
        // .ready -> Ready, .unreachable -> Unreachable + reason, .preparationFailed -> Not Ready + reason
        completion(false, "Not wired yet.")
    }

    func resetDDI() {
        // Helper calls StikJIT.resetCachedDDI(at: paths)
    }
}
