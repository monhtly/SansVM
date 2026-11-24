import Foundation

// get-task-allow check, from StikJIT INTEGRATION.md.
// Must be checked in the host process, identified by targetPID.
// Checking from inside the helper checks the wrong executable.
// Uses Security framework SPI. Not App Store-safe. This app is sideload-only.

enum JITEntitlements {
    static var hasGetTaskAllow: Bool {
        // Full C implementation is in INTEGRATION.md using SecTaskCreateFromSelf
        // and SecTaskCopyValueForEntitlement for "get-task-allow".
        // Swift wrapper to add when merging into UTM:
        // - Link Security.framework to host target
        // - Call the C helper, compare to kCFBooleanTrue
        // Placeholder returns false until merged, so the app fails closed
        // with a clear error instead of crashing on a brk with no debugger.
        return false
    }
}
