#!/bin/bash

# =============================================================================
# VENDOR DATA COMPRESSION SCRIPT
# =============================================================================
#
# This script compresses vendor transaction CSV files into tar.gz archives
# using maximum gzip compression (level 9) for efficient GitHub repository storage.
#
# FILE STRUCTURE:
# - CSV Files: Individual vendor transaction files by fiscal year and period (FY16-FY24)
# - Compressed Archives: .tar.gz files containing compressed CSV data
# - Scripts: Shell scripts for compression and decompression operations
#
# COMPRESSION:
# The vendor CSV files are compressed using maximum gzip compression (level 9)
# to minimize storage space. Archives are created by fiscal year.
#
# USAGE:
#   ./compress_vendors.sh
#
# This script will:
# - Compress CSV files by fiscal year into separate .tar.gz archives
# - Split each fiscal year into chunks of 6 CSV files per archive
# - Use maximum gzip compression (level 9) for optimal space savings
# - Create archives named vendors_fy{year}_part{number}.tar.gz (e.g., vendors_fy16_part1.tar.gz)
#
# MANUAL COMPRESSION COMMANDS:
# # Compress all CSV files for a specific fiscal year (chunked by 6)
# find . -name "Vendor_FY16P*.csv" -type f | sort | split -l 6 - temp_chunk_
# for chunk in temp_chunk_*; do
#     GZIP=-9 cat "$chunk" | tar -czf "vendors_fy16_part$(basename $chunk | cut -d_ -f3).tar.gz" -T -
#     rm "$chunk"
# done
#
# # Compress all vendor CSV files into a single archive
# find . -name "Vendor_FY*.csv" -type f | tar -czf vendors_all_csv.tar.gz -T -
#
# # Compress with maximum gzip compression
# GZIP=-9 find . -name "Vendor_FY*.csv" -type f | tar -czf vendors_max_compressed.tar.gz -T -
#
# DECOMPRESSION FOR ETL OPERATIONS:
# # Extract all .tar.gz files in the current directory
# for archive in *.tar.gz; do
#     echo "Extracting $archive..."
#     tar -xzf "$archive"
# done
#
# # Extract specific fiscal year (all parts)
# tar -xzf vendors_fy16_part1.tar.gz
# tar -xzf vendors_fy16_part2.tar.gz
#
# # Extract to specific directory for ETL processing
# mkdir -p ../etl_workspace/vendors
# for archive in *.tar.gz; do
#     echo "Extracting $archive to ETL workspace..."
#     tar -xzf "$archive" -C ../etl_workspace/vendors/
# done
#
# # Verify extraction
# ls -1 *.csv | wc -l
# ls -lh *.csv | head -10
# ls -1 Vendor_FY16P*.csv | wc -l
#
# ETL INTEGRATION:
# # Pre-ETL Setup
# cd data/vendors/
# for archive in *.tar.gz; do
#     tar -xzf "$archive"
# done
# echo "Total CSV files: $(ls -1 *.csv | wc -l)"
# echo "Expected: 105 files (FY16-FY24, 12 periods each + extras)"
#
# # Post-ETL Cleanup
# rm -f Vendor_FY*.csv
# ls -la *.tar.gz  # Should show compressed archives
#
# ARCHIVE MANAGEMENT:
# # List archive contents without extracting
# tar -tzf vendors_fy16.tar.gz
# tar -tzvf vendors_fy16.tar.gz
#
# # Show archive sizes and compression ratios
# ls -lh *.tar.gz
# for archive in *.tar.gz; do
#     echo "=== $archive ==="
#     echo "Size: $(du -h "$archive" | cut -f1)"
#     echo "Files: $(tar -tzf "$archive" | wc -l)"
#     echo "Compression: $(tar -tzvf "$archive" | awk '{sum+=$3} END {print sum/1024/1024 " MB uncompressed"}')"
# done
#
# NOTES:
# - Compression Level: All archives use gzip level 9 (maximum compression)
# - File Naming: Archives follow the pattern vendors_fy{year}.tar.gz
# - CSV Pattern: Individual CSV files follow Vendor_FY{year}P{period}.csv
# - Storage: Compressed archives are stored in the same directory as original CSV files
# - ETL Workflow: Always extract before ETL, clean up after ETL to maintain repository efficiency
#
# =============================================================================

set -e  # Exit on any error

VENDORS_DIR="$(dirname "$0")"
ARCHIVE_DIR="$VENDORS_DIR"

echo "Starting vendor CSV compression process..."
echo "Source directory: $VENDORS_DIR"
echo "Archive directory: $ARCHIVE_DIR (same as source)"

# Function to compress files by fiscal year in chunks of 6
compress_by_fy() {
    local fy=$1
    
    echo "Compressing FY${fy} vendor files in chunks of 6..."
    
    # Find all CSV files for the fiscal year
    local csv_files=$(find "$VENDORS_DIR" -name "Vendor_FY${fy}P*.csv" -type f | sort)
    
    if [ -z "$csv_files" ]; then
        echo "No CSV files found for FY${fy}, skipping..."
        return
    fi
    
    # Count files
    local file_count=$(echo "$csv_files" | wc -l)
    echo "Found $file_count CSV files for FY${fy}"
    
    # Split files into chunks of 6 and create archives
    local chunk_num=1
    echo "$csv_files" | split -l 6 - temp_chunk_
    
    for chunk_file in temp_chunk_*; do
        local archive_name="vendors_fy${fy}_part${chunk_num}.tar.gz"
        local archive_path="$ARCHIVE_DIR/$archive_name"
        
        echo "Creating $archive_name..."
        
        # Create tar.gz archive with maximum compression (gzip level 9)
        GZIP=-9 cat "$chunk_file" | tar -czf "$archive_path" -T -
        
        # Verify archive was created and get size
        if [ -f "$archive_path" ]; then
            local archive_size=$(du -h "$archive_path" | cut -f1)
            local files_in_chunk=$(wc -l < "$chunk_file")
            echo "✓ Created $archive_name (${archive_size}) - ${files_in_chunk} files"
        else
            echo "✗ Failed to create $archive_name"
            rm -f "$chunk_file"
            return 1
        fi
        
        # Clean up temp file
        rm -f "$chunk_file"
        ((chunk_num++))
    done
}

# Compress all fiscal years (FY16-FY24)
for fy in {16..24}; do
    compress_by_fy "$fy"
done

# Summary
echo ""
echo "Compression complete!"
echo "Archives created in: $ARCHIVE_DIR"
echo ""
echo "Archive contents:"
ls -lh "$ARCHIVE_DIR"/*.tar.gz

echo ""
echo "Next steps:"
echo "1. Verify archives were created successfully"
echo "2. Test extraction: tar -xzf vendors_fy16_part1.tar.gz"
echo "3. Remove original CSV files: rm -f Vendor_FY*.csv"
echo "4. Commit compressed archives to git"
echo ""
echo "To decompress for ETL operations, see the header comments in this script."