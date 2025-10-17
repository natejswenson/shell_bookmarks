# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Shell-based bookmark manager for opening websites via terminal. Users navigate bookmarks using interactive select menus and open URLs in their default browser.

## Architecture

### Core Components

- **nav.sh**: Main entry point and navigation logic
  - Reads and parses sites.csv to build hierarchical bookmark structure
  - Handles two-level navigation: top-level sites and folder-based subsites
  - Uses bash `select` for interactive menu navigation
  - Opens URLs via `xdg-open`

- **sites.csv**: Data store for all bookmarks
  - Format varies by entry type:
    - Top-level sites: `site_name,site_url`
    - Folders: `📁(folder_name),folder`
    - Sites in folders: `,📁(folder_name),site_name,site_url`
  - New entries are prepended (added at top) or appended based on operation

- **help.sh**: Help menu that provides options to navigate, add favorites, or edit sites.csv

- **.config**: Configuration variables for colors, prompts, and UI text using `tput`

### Key Functions (nav.sh)

- `selected_main_site()`: Gets site name from row number
- `subsites_of_selected_main_site()`: Extracts subsites for a given folder
- `folders()`: Lists all bookmark folders (entries where column 2 == "folder")
- `selected_subsite_url()`: Gets URL for a subsite by folder and selection
- `nav()`: Main navigation flow with two-level select menus
- `fav()`: Add bookmarks workflow (top-level, folder, or to-folder)

### Data Flow

1. User runs `nav` or `nav.sh`
2. Script sources .config for styling variables
3. Parses sites.csv to build menu options
4. User navigates via select menus (folder → site or direct site)
5. Selected URL opens in browser via `xdg-open`

## Development Commands

### Testing
```bash
./run_tests.sh                    # Run all unit and integration tests
./run_tests.sh test_nav_functions # Run specific test suite
./run_tests.sh test_integration   # Run integration tests
./run_tests.sh test_help          # Run help.sh tests
```

**Test Structure:**
- `tests/test_utils.sh` - Assertion framework and test utilities
- `tests/test_nav_functions.sh` - Unit tests for nav.sh parsing functions
- `tests/test_integration.sh` - Integration tests for full workflow
- `tests/test_help.sh` - Tests for help.sh functionality

Tests automatically create temporary environments and clean up after themselves.

### Running
```bash
./nav.sh          # Open navigation menu
./nav.sh -fav     # Add a favorite
./nav.sh -h       # Show help
```

### Editing Data
```bash
vi sites.csv      # Direct edit of bookmarks (also accessible via help menu)
```

## Performance Optimizations

- **Memory-cached CSV parsing**: sites.csv is read once into `CSV_LINES` array at startup
- **Eliminated subprocess spawning**: Replaced multiple awk/cut/sed pipelines with native bash loops
- **Pre-computed main sites list**: Built during initialization rather than on-demand
- This approach is significantly faster, especially with larger bookmark files

## Important Notes

- The script uses `xdg-open` which is Linux-specific for opening URLs
- Folder entries are prefixed with 📁 emoji for visual identification
- CSV parsing now uses in-memory arrays instead of repeated awk/cut/sed calls
- Color configuration uses tput commands (pcolor, scolor, boldcolor, etc.)
- All paths use `$my_dir` variable for portability (no hardcoded paths)
- Scripts include error handling for missing files and invalid input
