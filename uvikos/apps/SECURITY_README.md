# UvikOS Security Information

## Why Windows Defender May Flag This Software

This software may be flagged by Windows Defender due to the following legitimate behaviors that can appear suspicious:

### 1. PowerShell Script Execution
- Uses PowerShell to create a custom desktop environment
- Bypasses execution policy for legitimate system customization
- **Note**: May require Windows Defender exclusions for smooth operation

### 2. Process Management
- Terminates and restarts processes to implement custom desktop
- Uses `taskkill` to manage Java applications
- **This is normal behavior** for desktop environment software

### 3. File System Operations
- Creates directories in system locations (C:\apps, C:\edit)
- Modifies system files for desktop customization
- **This is intentional** for the custom desktop environment

### 4. Native API Usage
- Uses Windows APIs for window management and system integration
- **This is standard** for desktop environment software

## How to Run Safely

1. **Add to Windows Defender Exclusions**:
   - Manually add the project folder to Windows Defender exclusions
   - Or run the software and allow it when Windows Defender prompts

2. **Run as Administrator** (required for system customization):
   - Right-click on `uvikos.cmd`
   - Select "Run as administrator"

3. **Verify File Integrity**:
   - All source code is available for inspection
   - No obfuscated or encrypted code
   - Transparent functionality

## What This Software Does

- Creates a custom desktop environment
- Manages wallpaper and desktop settings
- Provides custom taskbar and panel functionality
- Implements custom window management
- **No malicious behavior** - all operations are for desktop customization

## Contact

If you have security concerns, please review the source code or contact the developer.



