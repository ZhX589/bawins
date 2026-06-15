# AGENTS.md

## Project Overview

Plays "Bad Apple!!" by opening up to 300 native OS windows and repositioning them each frame to form the image. Forked from mon/bad_apple_virus.

## Build Pipeline (order matters)

1. Place a **30fps** video as `1.mp4` in the repo root
2. Run `python bin.py` → generates `assets/boxes.bin` (binary frame data embedded at compile time via `include_bytes!`)
3. Place background music as `assets/2.ogg` (OGG Vorbis)
4. `cargo build --release` → `target/release/bad_apple`

`bin.py` caches: if `assets/boxes.json` exists it skips video processing and only re-serializes `.bin`.

## Python Dependencies

`bin.py` requires: `opencv-python`, `Pillow`, `tqdm`, `numpy`. No `requirements.txt` exists; install manually (a `venv/` with Python 3.14.5 is present but may be stale).

## Key Constants (`src/lib.rs:18-20`)

- `MAX_WINDOWS = 300` — max concurrent windows
- `BASE_WIDTH = 64`, `BASE_HEIGHT = 36` — change `BASE_HEIGHT` to `48` for 4:3 aspect ratio

## Platform Code

- `src/windows/mod.rs` — Win32 message loop, `DeferWindowPos` batching
- `src/macos/mod.rs` — cacao-based AppDelegate, `NSAnimationContext` batching
- `build.rs` — Windows-only: embeds manifest (Common Controls v6) and `icon.ico`

## Release Profile (`Cargo.toml`)

Optimized for small binary: `strip=true`, `opt-level="z"`, `lto=true`, `panic="abort"`, `codegen-units=1`. Expect slow release builds.

## Verification

No tests, no linter/formatter config. CI: GitHub Actions (`windows-latest` runner, `cargo build --release`, uploads `.exe` artifact). Local cross-compile: `x86_64-pc-windows-gnu` target with MinGW (`cargo build --target x86_64-pc-windows-gnu --release`; no icon/manifest).

## Cross-Compilation (Linux → Windows)

1. `rustup target add x86_64-pc-windows-gnu`
2. Install MinGW: `pacman -S mingw-w64-gcc` (Arch) / `apt install gcc-mingw-w64-x86-64` (Debian/Ubuntu)
3. `.cargo/config.toml` already sets linker to `x86_64-w64-mingw32-gcc`
4. `cargo build --target x86_64-pc-windows-gnu --release` → `target/x86_64-pc-windows-gnu/release/bad_apple.exe`
5. Note: `winres` is MSVC-only, so GNU builds skip icon/manifest embedding

## Gotchas

- `WinCoords` is `#[repr(C)]` packed 4 bytes — `assert_eq!(size_of::<WinCoords>(), 4)` runs at startup; changing its layout will panic
- `1.mp4` **must** be 30fps; the audio clock ticks at 30/sec (`src/lib.rs:38`)
- `assets/boxes.bin` is committed; regenerating requires the source video which is also committed as `1.mp4`
- macOS `cacao` dependency is a git fork: `https://github.com/ImTheSquid/cacao.git`
- No Linux platform code — project only compiles for Windows/macOS targets
