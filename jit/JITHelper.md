# Built-in StikJIT helper extension

Two processes, because a process that attaches a debugger to itself deadlocks:

Host app (target PID, pairing-file settings, get-task-allow check)
  -> XPC
Helper app extension (StikJIT, DDI cache, blocking work)

## Xcode setup

1. Add `StikJIT.xcframework` to the Xcode project. Version pinned: 1.9.0 in Madeira, check StikDebug/StikJIT latest release before building.
2. Link and embed it in the helper extension, NOT the host app.
3. Helper deployment target iOS 17.4 or later.
4. Make sure the final app contains and signs the framework. StikJIT.framework lives in the app's own Frameworks folder, helper loads it through `@executable_path/../../Frameworks`, where sideloaders re-sign it.
5. Give the helper a way to receive host PID, pairing-file data, settings, progress, results. XPC is a good fit.
6. Do NOT strongly link StikJIT into the host if the host supports older iOS. Keeping it in the iOS 17.4 helper prevents loading on older systems.
7. Do NOT add IOKit to the host bridging header. The XCFramework links IOKit internally.
8. StikJIT does not provide or launch the helper extension. The app owns that integration.

Madeira uses a classic app extension on `com.apple.ar.viewer`, as LiveContainer's LiveProcess does. An ExtensionKit extension does not survive a sideloader renaming the bundle id. Use the classic extension point.

Helper bundle id must be found after a sideloader renames the app bundle id (SideStore, AltStore append team id). Start it through NSExtension by the bundle id the helper has in this install.

## APIs, timing

StikJIT preparation and enablement APIs are synchronous and blocking. Run them on one dedicated serial background queue in the helper. Do not split into concurrent operations or Task/async calls.

When settings opens: use `StikJIT.isTXMPresent` to show Present / Not Present / Unknown. Informational only.

When user selects Prepare JIT: helper calls
`StikJIT.prepareDevice(pairingFile:paths:) { stage in report(stage) }`

When user launches a VM: run host preflight, launch helper, call `enableJIT` with script `.legacy` for UTM. Do not require Prepare JIT first; enableJIT performs preparation itself.

When user resets cache: helper calls `StikJIT.resetCachedDDI(at: paths)`

DDI cache in helper Library:
`Library/StikJIT/` via DDIPaths.default(in: library/StikJIT)
Before iOS 26.4: three-file personalized DDI. On iOS 26.4+: five-file cryptex DDI. Do not validate cached DDI yourself; StikJIT selects the format for the running OS.

Default tunnel endpoint 10.7.0.1:49152, fallback if discovery fails. For Bonjour discovery, host Info.plist needs:
- NSLocalNetworkUsageDescription: Find the device's Remote Pairing service to enable JIT.
- NSBonjourServices: _remotepairing._tcp

Also host Info.plist:
- UIFileSharingEnabled: true (to copy pairing file via Finder / AFC)
- LSSupportsOpeningDocumentsInPlace: true

Built-in StikJIT is unavailable in simulator and inside LiveContainer, because LiveContainer cannot create the required helper extension.
