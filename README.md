# Shell Bookmarks

A fast, terminal-based bookmark manager for quick website navigation. Navigate your bookmarks using interactive menus and open URLs directly in your browser.

## Features

- Interactive menu navigation with bash `select`
- Two-level bookmark organization (folders and sites)
- Quick bookmark addition from command line
- Fast CSV-based storage with in-memory caching
- Color-customizable interface
- No external dependencies (pure bash)

## Installation

```bash
cd ~
git clone https://github.com/natejswenson/shell_bookmarks.git
cd shell_bookmarks
chmod +x nav.sh help.sh
```

### Setup Alias

For **bash**:
```bash
echo 'alias nav=~/shell_bookmarks/nav.sh' >> ~/.bashrc
source ~/.bashrc
```

For **zsh**:
```bash
echo 'alias nav=~/shell_bookmarks/nav.sh' >> ~/.zshrc
source ~/.zshrc
```

## Usage

### Navigate Bookmarks
```bash
nav              # Open interactive navigation menu
```
![](/img/nav.png)

### Add Bookmarks
```bash
nav -fav         # Add a bookmark or folder
nav add          # Same as -fav
```

#### Add a Top-Level Bookmark:
![](/img/addtoplevelsite.png)

#### Create a Folder:
![](/img/addfolder.png)

#### Add Bookmark to a Folder:
![](/img/addtofolder.png)

### Get Help
```bash
nav -h           # Show help menu
nav help         # Same as -h
```

## Data Format

Bookmarks are stored in `sites.csv` with three format types:

1. **Top-level sites**: `site_name,site_url`
2. **Folders**: `📁(folder_name),folder`
3. **Sites in folders**: `,📁(folder_name),site_name,site_url`

Example:
```csv
📁(github),folder
,📁(github),Profile,https://www.github.com
,📁(github),shell_bookmarks,https://github.com/natejswenson/shell_bookmarks
Google,https://www.google.com
```

## Configuration

Edit `.config` to customize colors and UI text. Main configuration variables:

- `pcolor` - Primary color (using `tput setaf`)
- `scolor` - Secondary color
- `boldcolor`, `blinkcolor` - Text styling
- Navigation prompts and menu text

## Development

### Running Tests
```bash
./run_tests.sh                    # Run all tests
./run_tests.sh test_nav_functions # Run specific test suite
./run_tests.sh test_integration   # Integration tests
./run_tests.sh test_help          # Help script tests
```

All tests pass with comprehensive coverage:
- Unit tests for CSV parsing functions
- Integration tests for workflows
- Configuration and error handling validation

### Project Structure

```
shell_bookmarks/
├── nav.sh          # Main navigation script
├── help.sh         # Help menu
├── sites.csv       # Bookmark data
├── .config         # Color and UI configuration
├── tests/          # Unit and integration tests
│   ├── test_utils.sh
│   ├── test_nav_functions.sh
│   ├── test_integration.sh
│   └── test_help.sh
└── run_tests.sh    # Test runner
```

## Performance

Recent optimizations provide significant speed improvements:

- **Memory-cached CSV parsing** - Read once, parse in-memory
- **Eliminated subprocess overhead** - Native bash instead of awk/cut/sed pipelines
- **Pre-computed data structures** - Built at startup for instant access

Perfect for large bookmark collections.

## Requirements

- Bash 4.0+
- `xdg-open` (Linux) for opening URLs
- Terminal with color support (optional)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Run tests: `./run_tests.sh`
4. Submit a pull request

## License

Open source - feel free to use and modify.

## Author

Created by NateJSwenson
GitHub: [@natejswenson](https://github.com/natejswenson)
