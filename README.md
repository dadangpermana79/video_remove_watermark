# video_remove_watermark
the script is to remove_watermark from video mp4

Usage:

./remove_watermark.sh [input.mp4] [output.mp4] [output_rev.mp4] [trim_seconds]

Defaults:

input.mp4  ->  output.mp4 (watermark removed)  ->  output_rev.mp4 (last 1 s trimmed)

Examples:

sample: trim the last 3 seconds

./remove_watermark.sh input.mp4 output.mp4 output_rev.mp4 3

or

./remove_watermark.sh SAP_BRIM.mp4 SAP_BRIM_clean.mp4 SAP_BRIM_final.mp4 3

