#!/usr/bin/env bash
#
# remove_watermark.sh
# Created by Dadang Permana
#
# Remove the NotebookLM ("Gemini Notebook") watermark from a 1280x720 video,
# then trim the last N seconds. Prints the start and end date/time.
#
# Usage:
#   ./remove_watermark.sh [input.mp4] [output.mp4] [output_rev.mp4] [trim_seconds]
#
# Defaults:
#   input.mp4  ->  output.mp4 (watermark removed)  ->  output_rev.mp4 (last 1 s trimmed)
#
# Examples:
#   ./remove_watermark.sh                                  # default names, trim last 1 second
#   ./remove_watermark.sh input.mp4 output.mp4 output_rev.mp4 3
#                                                          # sample: trim the last 3 seconds
#   ./remove_watermark.sh SAP_BRIM.mp4 SAP_BRIM_clean.mp4 SAP_BRIM_final.mp4 3
#   KEEP_INTERMEDIATE=0 ./remove_watermark.sh SAP_BRIM.mp4 # delete output.mp4 at the end

set -euo pipefail

INPUT="${1:-input.mp4}"
OUTPUT="${2:-output.mp4}"
OUTPUT_REV="${3:-output_rev.mp4}"
TRIM_SECONDS="${4:-1}"
KEEP_INTERMEDIATE="${KEEP_INTERMEDIATE:-1}"

# Watermark position for a 1280x720 frame
DELOGO="delogo=x=1154:y=697:w=124:h=18"

now() { date '+%Y-%m-%d %H:%M:%S'; }

# Always print the end date/time (also when something fails)
finish() {
  local code=$?
  echo
  echo "End      : $(now)"
  printf 'Duration : %02d:%02d:%02d\n' $((SECONDS / 3600)) $((SECONDS % 3600 / 60)) $((SECONDS % 60))
  if [ "$code" -ne 0 ]; then
    echo "Status   : FAILED (exit code $code)"
  else
    echo "Status   : SUCCESS"
  fi
}
trap finish EXIT

echo "=== Remove Watermark & Trim | Created by Dadang Permana ==="
echo "Start    : $(now)"
echo "Input    : $INPUT"
echo

# ---- Checks -------------------------------------------------------------
for cmd in ffmpeg ffprobe awk; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Error: '$cmd' is not installed." >&2; exit 1; }
done
[ -f "$INPUT" ] || { echo "Error: input file '$INPUT' not found." >&2; exit 1; }
[[ "$TRIM_SECONDS" =~ ^[0-9]+([.][0-9]+)?$ ]] || { echo "Error: trim_seconds must be a number." >&2; exit 1; }

# Fail early (before the slow encode) if the video is too short to trim
IN_DURATION="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$INPUT")"
awk -v d="$IN_DURATION" -v t="$TRIM_SECONDS" 'BEGIN { exit !(d > t) }' || {
  echo "Error: video (${IN_DURATION}s) is not longer than trim_seconds (${TRIM_SECONDS}s)." >&2
  exit 1
}

# ---- Step 1: remove the watermark ---------------------------------------
echo "[1/2] Removing watermark -> $OUTPUT"
ffmpeg -hide_banner -loglevel error -stats -y -i "$INPUT" \
  -vf "$DELOGO" \
  -c:v libx264 -crf 18 -preset medium -pix_fmt yuv420p \
  -c:a copy "$OUTPUT"

# ---- Step 2: trim the last N seconds ------------------------------------
DURATION="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUTPUT")"
NEW_DURATION="$(awk -v d="$DURATION" -v t="$TRIM_SECONDS" 'BEGIN { printf "%.3f", d - t }')"

echo
echo "[2/2] Trimming last ${TRIM_SECONDS}s (${DURATION}s -> ${NEW_DURATION}s) -> $OUTPUT_REV"
ffmpeg -hide_banner -loglevel error -stats -y -i "$OUTPUT" \
  -t "$NEW_DURATION" -c copy "$OUTPUT_REV"

# ---- Cleanup ------------------------------------------------------------
if [ "$KEEP_INTERMEDIATE" = "0" ]; then
  rm -f "$OUTPUT"
  echo "Removed intermediate file: $OUTPUT"
fi

echo
echo "Final file: $OUTPUT_REV"
