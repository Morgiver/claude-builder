#!/usr/bin/env python3
"""
Example notification hook
This hook sends system notifications
"""

import sys
import os
import json
from datetime import datetime

def send_notification(title, message):
    """Send cross-platform system notification"""
    try:
        # Windows
        if os.name == 'nt':
            import subprocess
            cmd = f'powershell.exe -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show(\'{message}\', \'{title}\')"'
            subprocess.run(cmd, shell=True, capture_output=True)
        
        # macOS
        elif sys.platform == 'darwin':
            import subprocess
            subprocess.run(['osascript', '-e', f'display notification "{message}" with title "{title}"'])
        
        # Linux
        else:
            import subprocess
            subprocess.run(['notify-send', title, message])
            
    except Exception as e:
        print(f"⚠️  Cannot send notification: {e}", file=sys.stderr)

def main():
    """Main hook entry point"""
    
    # Read data from stdin or arguments
    data = ""
    if not sys.stdin.isatty():
        data = sys.stdin.read()
    elif len(sys.argv) > 1:
        data = " ".join(sys.argv[1:])
    
    # Timestamp
    timestamp = datetime.now().strftime("%H:%M:%S")
    
    # Send notification
    title = "Claude Code Hook"
    message = f"[{timestamp}] Activity detected"
    
    if data:
        # Limit message length
        if len(data) > 100:
            data = data[:97] + "..."
        message += f"\n{data}"
    
    send_notification(title, message)
    
    # Log vers stderr
    print(f"🔔 Hook: Notification sent - {title}", file=sys.stderr)
    
    return 0

if __name__ == "__main__":
    sys.exit(main())