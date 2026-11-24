# JIT setup, user steps

Built-in StikJIT first. StikDebug is the fallback in Settings > JIT.

## One-time setup — iPhone 15, iOS 27

No computer needed for pairing on iOS 27. In-app pairing is the primary path.

1. Turn on Developer Mode: Settings > Privacy & Security > Developer Mode > On, restart when asked.
2. Install LocalDevVPN from the App Store, connect it. JIT reaches lockdownd through its loopback 10.7.0.1. It works on Wi-Fi, or with no network, but not while cellular data is in use.
3. Pair in the app: Settings > JIT > JIT setup > In-app > Start pairing, allow Local Network, then Settings > Privacy & Security > Developer Mode > Pair with <App>, enter the code shown.
   - Fallback, iOS 26 style: make a pairing file once on a computer with iDevicePair / iLoader / JitterbugPair, copy the .mobiledevicepairing file to the phone, then in the app Settings > JIT > JIT setup > Import pairing file.
   - A pairing file is device-specific. Do not use one from another phone. Do not share it.
4. In the app: Settings > JIT > Check setup. It checks VPN reachability, downloads / mounts / verifies the matching Developer Disk Image, and shows Ready or the exact error.
5. Tap Enable JIT.

## Every launch

JIT does not stay on. Every time you close the app, enable JIT again before starting a VM.

In the app, starting a VM runs Enable JIT automatically when JIT is off. If it fails, the VM does not start, and the error is shown.

## If it fails

- "get-task-allow missing": reinstall with a signing method that preserves it. App Store installs never have it.
- "Import a valid pairing file": the file is missing, for another device, or expired after an iOS update / reset. Make a new one.
- "LocalDevVPN not routing": connect LocalDevVPN, turn cellular data off if needed, try again.
- "DDI stale after iOS update": Settings > JIT > Reset Developer Disk Image, then Check setup again.
- "Failed to add observer" / helper not found: the sideloader renamed the bundle id and the helper lookup failed. Reinstall, do not rename manually.
