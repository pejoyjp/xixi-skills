---
name: img-to-webp
description: Convert image files (`jpg`, `jpeg`, `png`, `tif`) to `webp` recursively on macOS with optional naming-based resize rules. Use when the user asks to batch convert images, keep original basenames, process subdirectories, apply desktop/mobile dimensions from filename suffixes (`-d`/`-m`), or convert unmatched filenames without resizing.
---

# Img to WebP

Use `scripts/img_to_webp.sh` to process a folder tree.

## Run

Run from the target directory:

```bash
bash /path/to/img-to-webp/scripts/img_to_webp.sh
```

Or provide an explicit root:

```bash
bash /path/to/img-to-webp/scripts/img_to_webp.sh /absolute/or/relative/path
```

Useful options:

```bash
bash scripts/img_to_webp.sh . --quality 80
bash scripts/img_to_webp.sh . --keep-original
bash scripts/img_to_webp.sh . --dry-run
```

## Naming Rules

Supported type prefixes:
`product`, `collection`, `banner`, `icon`, `logo`, `badge`, `review`, `blog`, `ad`, `brand`, `temp`

Accepted filename contain:
- `<type>-d`: use desktop size
- `<type>-m`: use mobile size
- `<type>`: use desktop size
- Any unmatched filename: convert to `webp` only (no resize)

Extensions:
- Source: `jpg`, `jpeg`, `png` (case-insensitive)
- Output: same basename with `.webp`

## Size Rules

Type-to-size mapping:

- `product`, `temp`: desktop `300x300`, mobile `150x150`
- `collection`, `banner`: desktop `1200x400`, mobile `360x120`
- `icon`: desktop `32x32`, mobile `48x48`
- `logo`, `brand`: desktop `400x100`, mobile `160x40`
- `badge`: desktop `100x100`, mobile `60x60`
- `review`: desktop `300x300`, mobile `90x90`
- `blog`: desktop `1200x800`, mobile `360x240`
- `ad`: desktop `1280x720`, mobile `360x200`

## Behavior

- Process files recursively.
- Install `webp` via Homebrew automatically when `cwebp` is missing.
- Keep basename and directory; change extension only.
- Skip resize for unmatched names and still convert to `webp`.
- Donot delete original files.

## Script

Use: `scripts/img_to_webp.sh`
