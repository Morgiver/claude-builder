#!/usr/bin/env python3
"""
CLAUDE_COMMAND_NAME: process-files
CLAUDE_COMMAND_DESC: Process files in a directory with various operations
CLAUDE_COMMAND_ARGS: <operation> <directory> [pattern]

Available operations:
- count: Count files by extension
- size: Display file sizes
- find: Find files by pattern
- clean: Remove temporary files
"""

import sys
import os
import glob
import json
from collections import defaultdict
from pathlib import Path

def count_files_by_extension(directory):
    """Count files by extension"""
    counts = defaultdict(int)
    total_size = defaultdict(int)
    
    for file_path in Path(directory).rglob('*'):
        if file_path.is_file():
            ext = file_path.suffix.lower() or '.no-extension'
            counts[ext] += 1
            total_size[ext] += file_path.stat().st_size
    
    print(f"📊 Statistics for: {directory}")
    print(f"{'Extension':<15} {'Files':<8} {'Size (MB)':<12}")
    print("-" * 35)
    
    for ext in sorted(counts.keys()):
        size_mb = total_size[ext] / (1024 * 1024)
        print(f"{ext:<15} {counts[ext]:<8} {size_mb:<12.2f}")

def show_file_sizes(directory, pattern="*"):
    """Display file sizes"""
    files = []
    for file_path in Path(directory).rglob(pattern):
        if file_path.is_file():
            size = file_path.stat().st_size
            files.append((str(file_path), size))
    
    # Sort by size
    files.sort(key=lambda x: x[1], reverse=True)
    
    print(f"📁 File sizes in: {directory}")
    print(f"{'File':<50} {'Size':<15}")
    print("-" * 65)
    
    for file_path, size in files[:20]:  # Top 20
        if size > 1024 * 1024:
            size_str = f"{size / (1024 * 1024):.2f} MB"
        elif size > 1024:
            size_str = f"{size / 1024:.2f} KB"
        else:
            size_str = f"{size} B"
        
        # Shorten path if necessary
        display_path = file_path if len(file_path) <= 47 else "..." + file_path[-44:]
        print(f"{display_path:<50} {size_str:<15}")

def find_files(directory, pattern):
    """Find files by pattern"""
    matches = list(Path(directory).rglob(pattern))
    
    print(f"🔍 Searching '{pattern}' in: {directory}")
    print(f"Found {len(matches)} file(s):")
    
    for match in sorted(matches):
        if match.is_file():
            size = match.stat().st_size
            print(f"  📄 {match} ({size} bytes)")
        else:
            print(f"  📁 {match}")

def clean_temp_files(directory):
    """Remove temporary files"""
    temp_patterns = ['*.tmp', '*.temp', '*~', '*.bak', '*.swp', '.DS_Store']
    removed = []
    
    for pattern in temp_patterns:
        for file_path in Path(directory).rglob(pattern):
            if file_path.is_file():
                try:
                    file_path.unlink()
                    removed.append(str(file_path))
                except Exception as e:
                    print(f"❌ Unable to delete {file_path}: {e}")
    
    print(f"🧹 Cleanup completed in: {directory}")
    print(f"Removed {len(removed)} temporary file(s):")
    for file_path in removed:
        print(f"  🗑️  {file_path}")

def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 1
    
    operation = sys.argv[1].lower()
    directory = sys.argv[2]
    pattern = sys.argv[3] if len(sys.argv) > 3 else "*"
    
    if not os.path.exists(directory):
        print(f"❌ Directory not found: {directory}")
        return 1
    
    try:
        if operation == "count":
            count_files_by_extension(directory)
        elif operation == "size":
            show_file_sizes(directory, pattern)
        elif operation == "find":
            find_files(directory, pattern)
        elif operation == "clean":
            clean_temp_files(directory)
        else:
            print(f"❌ Unknown operation: {operation}")
            print(__doc__)
            return 1
            
    except Exception as e:
        print(f"❌ Error during processing: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())