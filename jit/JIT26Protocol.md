# iOS 26 JIT protocol, Part 1

From StikDebug/StikJIT INTEGRATION.md Part 1.

## The problem on TXM / SPTM devices

On iOS 26, on TXM/SPTM hardware (A15+ / M2+), the old JIT path can no longer produce executable memory. The debugger flag alone is not enough: each executable memory region must be prepared through the debug connection before the app executes code from it.

StikJIT / StikDebug handle the debugger side. The host app's JIT allocator must implement the matching breakpoint protocol:

- `brk #0xf00d`, command in x16, args in x0 / x1
- `JIT26PrepareRegion(address, length)` — x16 = 1, returns RX address in x0
- `JIT26Detach()` — x16 = 0

Order where TXM is present:
1. Start JIT acquisition. Its universal script attaches and waits for breakpoint calls.
2. Wait until CS_DEBUGGED appears before any brk. A brk without the script attached will crash.
3. Allocate / request every initial RX region and call JIT26PrepareRegion for each.
4. Create writable aliases, finish JIT allocator init.
5. Call JIT26Detach.
6. Mark JIT ready only after prepare + detach return successfully.

Preallocate regions before detaching. A region added later cannot be prepared by a script that already detached.

## Why we skip Part 1 for UTM

UTM already enables JIT successfully after the user manually selects it and its script in StikDebug. Its script is `legacy.js`.

INTEGRATION.md says: if the app already enables JIT successfully after manual selection in StikDebug, skip Part 1. Record whether it uses universal.js, legacy.js, or a custom script, then complete Part 2.

Recorded: UTM = legacy.js.

New apps should use universal.js. We do NOT switch UTM to universal, because that would change its working JIT allocator. Part 2 does not require changing a working JIT allocator.

## What Part 2 adds

- Wait for Debugger path preserved
- Automatic StikDebug URL launching
- Optional Built-in StikJIT: embed StikJIT.xcframework in helper extension, XPC from host, gate checks, pairing import, DDI cache, enableJIT call with script = .legacy
