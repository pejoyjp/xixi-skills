#!/usr/bin/env bash
set -euo pipefail

QUALITY=80
DRY_RUN=0
ROOT="."

usage() {
cat <<'EOF'
Usage:
  img_to_webp.sh [root] [--quality N] [--dry-run]

Options:
  --quality N   WebP quality (default: 80)
  --dry-run     Show planned operations without converting
  -h, --help    Show help
EOF
}

normalize() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

detect_type() {
  local name="$1"

  for t in product collection banner icon logo badge review blog ad brand temp; do
    if [[ "$name" == *"$t"* ]]; then
      echo "$t"
      return
    fi
  done

  echo ""
}

get_device() {
  local name="$1"

  if [[ "$name" == *"-m"* ]]; then
    echo "m"
  else
    echo "d"
  fi
}

get_size() {
  local type="$1"
  local device="$2"

  case "$type" in
    product|temp)
      [[ "$device" == "m" ]] && echo "150 150" || echo "300 300"
      ;;
    collection|banner)
      [[ "$device" == "m" ]] && echo "360 120" || echo "1200 400"
      ;;
    icon)
      [[ "$device" == "m" ]] && echo "48 48" || echo "32 32"
      ;;
    logo|brand)
      [[ "$device" == "m" ]] && echo "160 40" || echo "400 100"
      ;;
    badge)
      [[ "$device" == "m" ]] && echo "60 60" || echo "100 100"
      ;;
    review)
      [[ "$device" == "m" ]] && echo "90 90" || echo "300 300"
      ;;
    blog)
      [[ "$device" == "m" ]] && echo "360 240" || echo "1200 800"
      ;;
    ad)
      [[ "$device" == "m" ]] && echo "360 200" || echo "1280 720"
      ;;
    *)
      echo "0 0"
      ;;
  esac
}

install_dependencies() {

  if ! command -v cwebp >/dev/null 2>&1; then

    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[dry-run] cwebp not installed, would install via brew"
    else
      if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew required: https://brew.sh" >&2
        exit 1
      fi

      echo "Installing webp via Homebrew..."
      brew install webp
    fi
  fi

  if ! command -v magick >/dev/null 2>&1; then

    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[dry-run] imagemagick not installed, would install via brew"
    else
      echo "Installing ImageMagick..."
      brew install imagemagick
    fi
  fi
}

convert_file() {

  local file="$1"

  local base
  local name
  local lower
  local type
  local device
  local out
  local size
  local w
  local h
  local ext

  base="$(basename "$file")"
  name="${base%.*}"
  lower="$(normalize "$name")"

  ext="${file##*.}"
  ext="$(normalize "$ext")"

  type="$(detect_type "$lower")"
  device="$(get_device "$lower")"

  out="${file%.*}.webp"

  if [[ -f "$out" ]]; then
    return
  fi

  if [[ -n "$type" ]]; then

    size="$(get_size "$type" "$device")"
    read -r w h <<<"$size"

    if [[ "$w" -gt 0 && "$h" -gt 0 ]]; then

      echo "resize $file -> $out (${w}x${h})"

      if [[ "$DRY_RUN" -eq 0 ]]; then

        if [[ "$ext" == "tif" || "$ext" == "tiff" ]]; then
          local tmp_png
          tmp_png="$(mktemp -t img_to_webp_resize_XXXXXX.png)"
          magick "$file" -resize "${w}x${h}" "$tmp_png"
          cwebp -q "$QUALITY" -m 6 -mt "$tmp_png" -o "$out" >/dev/null
          rm -f "$tmp_png"
        else
          cwebp -q "$QUALITY" -m 6 -mt -resize "$w" "$h" "$file" -o "$out" >/dev/null
        fi

      fi

      return
    fi
  fi

  echo "convert $file -> $out"

  if [[ "$DRY_RUN" -eq 0 ]]; then

    if [[ "$ext" == "tif" || "$ext" == "tiff" ]]; then
      local tmp_png
      tmp_png="$(mktemp -t img_to_webp_convert_XXXXXX.png)"
      magick "$file" "$tmp_png"
      cwebp -q "$QUALITY" -m 6 -mt "$tmp_png" -o "$out" >/dev/null
      rm -f "$tmp_png"
    else
      cwebp -q "$QUALITY" -m 6 -mt "$file" -o "$out" >/dev/null
    fi

  fi
}

parse_args() {

  while [[ $# -gt 0 ]]; do

    case "$1" in

      --quality)
        shift
        QUALITY="$1"
        ;;

      --dry-run)
        DRY_RUN=1
        ;;

      -h|--help)
        usage
        exit 0
        ;;

      -*)
        echo "Unknown option: $1" >&2
        exit 1
        ;;

      *)
        ROOT="$1"
        ;;

    esac

    shift
  done
}

main() {

  parse_args "$@"

  if [[ "$(uname)" != "Darwin" ]]; then
    echo "Only macOS supported." >&2
    exit 1
  fi

  if [[ ! -d "$ROOT" ]]; then
    echo "Directory not found: $ROOT" >&2
    exit 1
  fi

  install_dependencies

  while IFS= read -r -d '' file
  do
    convert_file "$file"
  done < <(
    find "$ROOT" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.tif" -o -iname "*.tiff" \) \
    -print0
  )

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Done (dry-run)."
  else
    echo "Done."
  fi
}

main "$@"
