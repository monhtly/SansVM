# ISO and disk image import

UTM already does this. Keep it, do not rebuild it.

## Supported files

- .iso — installer / live CD, attach as CD/DVD drive
- .qcow2 — QEMU disk image, attach as hard drive
- .img, .raw — raw disk image
- .utm — UTM VM bundle, import whole VM
- .zip — unzip in Files first, then import the image inside

User supplies the OS. The app does not ship Windows, Linux, or any copyrighted OS.

## Flow in the app

1. Download the ISO in Safari / Files, or AirDrop it to the phone.
2. In the app: + > Create VM > pick architecture / system, or + > Import.
3. Tap the CD/DVD icon, browse Files, pick the .iso.
4. For a disk image, pick it as the hard drive, or let the VM create a new qcow2 and install from ISO.
5. Set RAM / CPU cores. More RAM helps, but iOS will kill the app if you give the guest too much. Start low: 2 GB RAM, 2 cores for light Linux, 4 GB for Windows ARM.
6. Start the VM. If JIT is off, the app runs Enable JIT first, then starts.

## What to add on top of UTM

- In-app download: paste a direct ISO URL, download to Files / app Documents with progress, then offer Import. Do not add a built-in browser that bypasses anything, just a URL download with progress.
- Show file size and free space before import. ISOs are 2-6 GB, phones fill fast.
- Keep the VM list, with per-VM ISO attached, so you do not have to re-pick it every boot.

## Speed notes

- ARM guest on ARM host: fastest, near native with JIT.
- x86 / x86-64 guest on ARM host: emulation through TCG + JIT, slower, usable for light desktops, not for gaming.
- UTM on iOS does not use Hypervisor.framework. That is macOS only.
