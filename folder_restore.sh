#!/bin/bash

# Configuration
SOURCE_DIR="/Volumes/Shadab T7 One/Oracle Content Orcl Laptop MacbookBro/Oracle Content" # No Trailing Slash
BACKUP_DIR="/Users/shadab/Downloads"  # No Trailing Slash
CHECKPOINT_FILE="$HOME/Library/Application Support/FolderRestore/restore_checkpoint"
LOG_FILE="$HOME/Library/Logs/FolderRestore.log"

# Create necessary directories
mkdir -p "$(dirname "$CHECKPOINT_FILE")"
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$BACKUP_DIR"

# Logging function with console output
log() {
    message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message" | tee -a "$LOG_FILE"
}

# Check if backup directory is available
if [ ! -d "$BACKUP_DIR" ]; then
    log "Backup directory not available: $BACKUP_DIR"
    exit 1
fi

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    log "Source directory not found: $SOURCE_DIR"
    exit 1
fi

# Initialize checkpoint file if it doesn't exist
if [ ! -f "$CHECKPOINT_FILE" ]; then
    log "Initializing new checkpoint file"
    touch "$CHECKPOINT_FILE"
fi

# Perform the backup
log "Starting backup from $SOURCE_DIR to $BACKUP_DIR"

# Correct rsync command - simplified approach
rsync -avh --exclude=.DS_Store --progress --delete "$SOURCE_DIR" "$BACKUP_DIR" 2>&1 | tee -a "$LOG_FILE"

# Check rsync exit status
if [ $? -eq 0 ]; then
    log "Rsync completed successfully"
else
    log "Rsync failed with error code $?"
fi

# Update checkpoint file with current timestamp and file list
log "Updating checkpoint file"
echo "Last backup: $(date)" > "$CHECKPOINT_FILE"
find "$SOURCE_DIR" -type f -print0 | while IFS= read -r -d '' file; do
    echo "${file#$SOURCE_DIR}" >> "$CHECKPOINT_FILE"
done

log "Backup process completed"
