# SansVM — VM app with built-in JIT first

App name: SansVM, bundle id placeholder com.sans.sansvm, target device iPhone 15 base, iOS 27, 6 GB RAM.

A UTM-like iOS VM app. You import an ISO or disk image, create a VM, boot it.

Built-in JIT first, StikDebug as fallback. No jailbreak, no TrollStore.

## v1 vs v2, honest status

v1, this build: stock UTM full iOS build, renamed SansVM-unsigned.ipa. It proves the UTM + Sysroot build goes green on GitHub Actions. It does NOT yet have the built-in StikJIT helper merged in. You enable JIT in v1 with StikDebug, same as stock UTM.

v2: merge the built-in StikJIT helper extension from jit/ into UTM's Xcode project, default method Built-in, in-app pairing on iOS 27.

Do not claim v1 has built-in JIT. It does not.

## What this is

Not a VM written from scratch. That would be QEMU plus a full iOS frontend, years of work.

This is a fork/rebrand of UTM (open source, QEMU-based):

- UTM already boots Windows, Linux, and more on iPhone/iPad
- UTM already supports ISO / qcow2 / img import from Files
- UTM already works with StikDebug on iOS 26, using `legacy.js`

What we add, first:

1. Built-in StikJIT helper inside the app, so you do not need the separate StikDebug app
2. A Settings > JIT screen, default method Built-in StikJIT
3. Pairing file import, LocalDevVPN check, Check setup, Enable JIT, Reset DDI
4. Our own name, bundle id, and icon (to be set by sans)

StikDebug stays as a fallback method in the same screen.

## Built-in JIT, how it works

From StikDebug/StikJIT INTEGRATION.md and Madeira docs/JIT.md:

- Built-in JIT requires iOS 26 or later and a normal sideloaded install. Unavailable in simulator and LiveContainer.
- It needs this iPhone's pairing file. On iOS 27 it can be made in-app. On iOS 26, import a pairing file made once on a computer.
- The host app must have `get-task-allow`. That is a development signing entitlement, so the IPA is unsigned in CI and must be sideloaded with AltStore / SideStore / Sideloadly, not installed from the App Store.
- Built-in StikJIT uses two processes because a process that attaches a debugger to itself deadlocks: host app talks over XPC to a helper app extension, which embeds `StikJIT.xcframework`.
- The helper, not the host, links and embeds the framework. Helper deployment target iOS 17.4 or later.
- Gate every entry point: iOS 17.4+, `get-task-allow` true, pairing file readable. If any fails, show the exact error, do not silently switch methods.
- Pairing file location: `Documents/StikJIT/pairingFile.plist` in the StikJIT guide, moved to Keychain in Madeira for safety. We store it in Keychain, import via `UIDocumentPickerViewController`.
- DDI cache lives in the helper's Library. StikJIT downloads/mounts the matching Developer Disk Image, verifies it, then enables JIT.
- Script: UTM uses `legacy.js`. Do not expose script choice to the user. It is developer-controlled. New apps should use `universal.js`, but UTM is a legacy-script app, so we keep `.legacy` for UTM.
- JIT does not survive closing the app. Enable JIT again every launch, before starting a VM.

On iOS 17.4 to 18.x, StikDebug is the stable path. On iOS 26+, built-in needs the app-side TXM support above, which UTM already has via legacy.js.

## Repo layout

- `.github/workflows/ios.yml` — two jobs, clones utmapp/UTM in CI, builds Sysroot ios-arm64 from source then builds UTM, packages unsigned IPA as SansVM-unsigned.ipa
- `patches/` — rebrand + JIT defaults patch, applied in CI
- `jit/` — the built-in JIT design and Swift code to merge into the UTM fork
  - `JITSettings.swift` — method picker, default Built-in
  - `JITPairing.swift` — import pairing file, Keychain storage
  - `JITEntitlements.swift` — get-task-allow check
  - `JITHelper.md` — helper extension spec
  - `JIT26Protocol.md` — why Part 1 is already done for UTM
  - `JITSetup.md` — user-facing setup steps
- `vm/ISOImport.md` — ISO / disk image import spec

## Build

No Swift / Xcode compile on this Linux VM. The first real compile is the GitHub Actions run on macos-26.

Workflow is two jobs, copied from UTM's own build.yml:
- build-sysroot: `./scripts/build_dependencies.sh -p ios -a arm64`, cached in Actions cache. Slow on first run, QEMU deps take a long time.
- build-utm: restore Sysroot, `./scripts/build_utm.sh -k iphoneos -s iOS -a arm64 -o UTM`, then `./scripts/package.sh ipa UTM.xcarchive output`, renamed to SansVM-unsigned.ipa.

Prebuilt Sysroot is NOT downloaded from UTM releases in v1, because that artifact needs a logged-in download and is not a public release asset. Building it from source in CI is the reliable path UTM itself uses.

Output is an unsigned IPA. Sideload it, then do the JIT setup in the app.

## Status

2026-11-23: scaffold ready, workflow rewritten to UTM two-job build. Not yet pushed to GitHub, not yet CI-built, not device-tested. First run will take a long time for Sysroot, likely 1-3 hours, and may fail on brew / Xcode version / cache. That is expected, we fix from the log.

Target device confirmed: iPhone 15 base, iOS 27, 6 GB RAM. See vm/iPhone15-iOS27.md. In-app pairing, no computer needed. TXM present, UTM legacy.js path. VM defaults 2 GB RAM, 2 cores.

Still needed from sans:
- Empty GitHub repo name, to create under monhtly (same browser-upload pattern as ShapeMahjong, connector cannot create repos)

## Licenses

UTM is Apache 2.0, QEMU parts are GPL. StikJIT is MPL-2.0. Keep all notices. This fork must keep UTM's license files.
