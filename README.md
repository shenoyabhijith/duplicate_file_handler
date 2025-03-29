# Duplicate File Handler

A lightweight, customizable Bash script to identify and manage duplicate files on your hard drive, ensuring no third-party tools are required. This tool traverses directories, hashes file contents, generates a detailed report of duplicates, and provides an interactive option to delete them while always preserving at least one copy.

## Overview

Duplicate File Handler is designed for anyone tired of cluttered drives filled with redundant files—like that meme you downloaded 10 times or the “final_final.docx” that somehow multiplied. Instead of relying on bloated apps, this script uses native Bash commands (`find`, `md5sum`) to give you full control over your cleanup process. It’s safe, transparent, and flexible, with options to target specific directories or customize output.

## Features

- **Recursive Directory Scanning**: Traverses all subdirectories to find files.
- **Content-Based Detection**: Uses MD5 hashes to identify duplicates based on content, not just names or sizes.
- **Detailed Reporting**: Outputs a text file listing duplicate sets with paths and sizes.
- **Interactive Deletion**: Prompts you to choose which duplicates to delete, ensuring at least one copy remains.
- **Customizable**: Accepts command-line options for directory and output file.
- **Safety First**: Skips hidden/system files and requires user confirmation for deletions.
- **Progress Feedback**: Displays dots during hashing to show it’s working.

## Installation

No external dependencies—just Bash and standard Unix tools (`md5sum`, `find`, etc.), which are pre-installed on most Linux/macOS systems.

1. **Clone the Repository:**
```bash
git clone https://github.com/yourusername/duplicate-file-handler.git
cd duplicate-file-handler
```

2. **Make the script executable:**
```bash
chmod +x find_duplicates.sh
```
Usage
Run the script from the terminal:

```bash
./find_duplicates.sh
```

## Workflow

1. The script scans the specified directory and calculates MD5 hashes for all files.
2. It identifies duplicates and writes them to a report file.
3. If duplicates are found, it prompts you to delete them interactively, preserving the first copy in each set.

## Options

| Option          | Description                                     | Default                            |
|-----------------|-------------------------------------------------|------------------------------------|
| `-d, --dir DIR`  | Specify the root directory to scan              | `/Volumes/Abhi'sHD` (edit as needed) |
| `-o, --out FILE` | Set the output report file name                | `duplicate_files_report.txt`       |
| `-h, --help`     | Display usage information and exit             | N/A                                |

## Examples

**Scan a specific folder:**
```bash
./find_duplicates.sh -d ~/Pictures
```

Save the report to custom file

```bash
./find_duplicates.sh -d ~/Documents -o duplicates_log.txt
```
show help: 

```bash
./find_duplicates.sh --help
```

Sample Output
The script generates a duplicate_files_report.txt like this:
```
Duplicate Files Report
Generated on: Sat Mar 29 12:00:00 2025
Root directory: ~/Pictures

Duplicate Set #1 (Hash: a1b2c3d4e5f6g7h8)
~/Pictures/cat_meme.jpg (512 KB)
~/Pictures/funny_cat.jpg (512 KB)

Duplicate Set #2 (Hash: x9y8z7w6v5u4t3s2)
~/Pictures/vacation.jpg (1.2 MB)
~/Pictures/vacation_copy.jpg (1.2 MB)
```

During deletion, you’ll see prompts like:
```
Duplicate Set #1, File #2: ~/Pictures/funny_cat.jpg
Delete this file? (y/n/q to quit)
```

**Use Cases **
**Personal Cleanup**: Reclaim space from duplicate photos, music, or documents.

**Developer Workflow**: Clear redundant project backups or test files.

**Server Maintenance**: Manage storage on a shared drive without extra software.

**Contributing**
Contributions are welcome! Here’s how to get involved:

**Fork the repository**

```
Create a feature branch (git checkout -b feature/awesome-idea).

Commit your changes (git commit -m "Add awesome idea").

Push to the branch (git push origin feature/awesome-idea).

Open a pull request.

Please include tests or examples if adding new features, and update this README as needed.
```

**License**
This project is licensed under the MIT License. See the LICENSE file for details.

**Acknowledgments**
Built with Bash and love for clean drives.

Inspired by the need to avoid sketchy third-party tools.



