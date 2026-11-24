# Target device: iPhone 15 base, iOS 27

Confirmed by sans 2026-11-23. Base, 6 GB RAM, A16 Bionic. Storage size unknown.

## What this changes

- Built-in JIT is the right first path. It requires iOS 26 or later, and iOS 27 is in range.
- In-app pairing works on iOS 27, no computer needed for a pairing file. The app plays the computer for its own iPhone over local network, then you pair in Settings > Privacy & Security > Developer Mode.
- On iOS 26 you would have to import a pairing file made on a computer. On iOS 27 that step is gone, unless in-app pairing fails, then fall back to import.
- TXM is present. On iOS 27 TXM is on everything except iPad8,11 / iPad8,12, and iPhone 15 is A16, well above the iOS 26 TXM floor of A14. So the TXM breakpoint protocol is required, not optional. UTM already handles it via legacy.js.
- StikDebug is still the fallback, and UTM is on its iOS 26 supported list.

## Hardware limits

- iPhone 15 base / Plus: A16 Bionic, 6 GB RAM
- iPhone 15 Pro / Pro Max: A17 Pro, 8 GB RAM

Assume 6 GB until sans says Pro. That sets VM defaults:

- RAM: 2 GB default, 3 GB max for light Linux, do not default to 4 GB. iOS will kill the app if the guest takes too much.
- CPU: 2 cores default
- Disk: start with 16-32 GB qcow2, check free space first. ISOs are 2-6 GB.
- Guest choice: ARM Linux first for speed, Windows ARM second, x86 Windows last and slowest even with JIT.

## Build target

- Minimum iOS: 26.0 (built-in JIT floor)
- Target SDK: latest Xcode on macos-15 runner, iphoneos
- UTM build: full iOS, not SE, arm64
- Helper extension deployment target: iOS 17.4 or later, per StikJIT guide, but the app itself only needs to run on iOS 26+ for built-in

## JIT setup on this device

1. Developer Mode on, restart
2. LocalDevVPN installed and connected, Wi-Fi on, cellular data off for JIT
3. In app: Settings > JIT > In-app > Start pairing, allow Local Network
4. Settings > Privacy & Security > Developer Mode > Pair with <App>, enter code
5. Back in app: Check setup, then Enable JIT
6. Start VM. Enable JIT again every time the app is fully closed.
