# Patches

Applied in CI after cloning utmapp/UTM, before building.

## utm-builtin-jit.patch

Not yet written as a real diff, because it must be made against a pinned UTM commit, and UTM moves fast.

What it must do, when made:

1. Rebrand: app name, bundle id prefix, icon. Bundle id is set by sans, do not guess it here.
2. JIT method default: Built-in StikJIT first. Settings > JIT defaults to Built-in, StikDebug second, Wait for Debugger third.
3. Add helper extension target for Built-in StikJIT, embed StikJIT.xcframework 1.9.0, link it only in the helper.
4. Add JITSettings / JITPairing / JITEntitlements Swift files from `jit/` into the UTM Xcode project.
5. Add Info.plist keys: NSLocalNetworkUsageDescription, NSBonjourServices _remotepairing._tcp, UIFileSharingEnabled, LSSupportsOpeningDocumentsInPlace.
6. Script: hardcode `.legacy` for UTM. Do not expose script choice to the user.
7. VM start flow: call enableJITIfNeeded before starting QEMU TCG, fail closed with the exact error if JIT is not ready.

## Sysroot

UTM docs: get prebuilt dependencies from GitHub Actions. Pick the latest release and download the `Sysroot-ios-arm64` artifact, extract to repo root.

That artifact is not a public release asset, it needs a logged-in GitHub download. In CI we need a pinned UTM release run id, or build deps from source with `./scripts/build_dependencies.sh -p ios -a arm64`, which takes hours.

First CI run will likely fail at the Sysroot step. That is the known blocker to fix next, by pinning a UTM release and its Sysroot artifact URL, or by vendoring a sysroot build.

Do not claim the IPA is built until a CI run goes green and the artifact is downloaded.
