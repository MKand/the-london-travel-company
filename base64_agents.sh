#!/bin/bash

# Directory containing agents
AGENTS_DIR="agents"

# Find all agent directories
for agent_path in "$AGENTS_DIR"/*; do
    if [ -d "$agent_path" ]; then
        agent_name=$(basename "$agent_path")
        
        # Skip hidden directories and __pycache__
        if [[ "$agent_name" == .* ]] || [[ "$agent_name" == "__"* ]]; then
            continue
        fi
        
        echo "Processing agent: $agent_name"
        
        # Clear old artifacts
        rm -f "$agent_path"/.*.tar.gz
        rm -f "$agent_path"/.*.tar.gz.b64
        
        # Create tarball in parent directory, excluding large/unnecessary directories
        # Using -C to avoid full paths in tarball
        tar --exclude=".venv" --exclude="__pycache__" --exclude=".adk" -czf "$AGENTS_DIR/.$agent_name.tar.gz" -C "$AGENTS_DIR" "$agent_name"
        
        # Base64 encode
        base64 -w 0 "$AGENTS_DIR/.$agent_name.tar.gz" > "$agent_path/.$agent_name.tar.gz.b64"
        
        # Clean up temporary tarball
        rm -f "$AGENTS_DIR/.$agent_name.tar.gz"
        
        echo "Created $agent_path/.$agent_name.tar.gz.b64"
    fi
done
