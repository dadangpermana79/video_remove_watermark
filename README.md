# video_remove_watermark
the script is to remove_watermark from video mp4

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
