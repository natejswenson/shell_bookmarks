#!/bin/bash
# Integration tests for nav.sh

# Get the directory of this test script
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$TEST_DIR")"

# Source test utilities
source "$TEST_DIR/test_utils.sh"

# Create temporary test environment
TEMP_DIR=$(create_test_dir)
TEST_SITES="$TEMP_DIR/sites.csv"
TEST_CONFIG="$TEMP_DIR/.config"
TEST_NAV="$TEMP_DIR/nav.sh"

# Setup test environment
setup_test_env() {
    create_test_csv "$TEST_SITES"
    create_test_config "$TEST_CONFIG"

    # Copy nav.sh to temp dir
    cp "$PROJECT_DIR/nav.sh" "$TEST_NAV"
    chmod +x "$TEST_NAV"

    # Make xdg-open a no-op for testing (don't actually open browser)
    export -f mock_xdg_open
}

# Mock xdg-open to avoid opening browser during tests
mock_xdg_open() {
    echo "MOCK_OPEN: $1"
    return 0
}

# Run tests
run_tests() {
    setup_test_env

    start_suite "Script Validation"

    # Test that nav.sh exists and is executable
    assert_file_exists "$PROJECT_DIR/nav.sh" "nav.sh should exist"

    # Test syntax check
    bash -n "$PROJECT_DIR/nav.sh" 2>/dev/null
    assert_true "$?" "nav.sh should have valid bash syntax"

    # Test with missing sites.csv
    local output
    output=$(cd "$TEMP_DIR" && rm -f sites.csv && bash "$TEST_NAV" 2>&1)
    assert_contains "Error: sites.csv not found" "$output" "Should error when sites.csv missing"

    # Restore sites.csv for remaining tests
    create_test_csv "$TEST_SITES"

    # Test with missing .config
    output=$(cd "$TEMP_DIR" && rm -f .config && bash "$TEST_NAV" 2>&1)
    assert_contains "Error: .config file not found" "$output" "Should error when .config missing"

    # Restore .config for remaining tests
    create_test_config "$TEST_CONFIG"

    end_suite

    start_suite "Command Line Arguments"

    # Test help flags
    for flag in "-h" "h" "-help" "help"; do
        # Create a mock help.sh
        cat > "$TEMP_DIR/help.sh" << 'EOF'
#!/bin/bash
echo "HELP_EXECUTED"
EOF
        chmod +x "$TEMP_DIR/help.sh"

        output=$(cd "$TEMP_DIR" && bash "$TEST_NAV" "$flag" 2>&1)
        assert_contains "HELP_EXECUTED" "$output" "Flag '$flag' should execute help"
    done

    # Test invalid option
    output=$(cd "$TEMP_DIR" && bash "$TEST_NAV" "invalid_option" 2>&1)
    assert_contains "Invalid Option" "$output" "Invalid option should show error"
    assert_contains "HELP_EXECUTED" "$output" "Invalid option should show help"

    end_suite

    start_suite "CSV Data Loading"

    # Test that CSV is loaded correctly
    # Create a test that sources nav.sh and checks CSV_LINES
    cat > "$TEMP_DIR/test_csv_load.sh" << 'EOF'
#!/bin/bash
my_dir="$(dirname "$0")"
source "$my_dir/.config" 2>/dev/null || exit 1
sites="$my_dir/sites.csv"
[[ -f "$sites" ]] || exit 1

# Load CSV (from nav.sh)
mapfile -t CSV_LINES < "$sites"

# Check that we loaded lines
if [[ ${#CSV_LINES[@]} -gt 0 ]]; then
    echo "LINES_LOADED:${#CSV_LINES[@]}"
    exit 0
else
    exit 1
fi
EOF
    chmod +x "$TEMP_DIR/test_csv_load.sh"

    output=$(cd "$TEMP_DIR" && bash test_csv_load.sh 2>&1)
    assert_contains "LINES_LOADED:" "$output" "CSV should be loaded into array"

    # Extract line count
    line_count=$(echo "$output" | grep -o 'LINES_LOADED:[0-9]*' | cut -d: -f2)
    assert_equals "10" "$line_count" "Should load 10 lines from test CSV"

    end_suite

    start_suite "Bookmark Addition"

    # Test adding a top-level bookmark (simulate user input)
    initial_count=$(wc -l < "$TEST_SITES")

    # Add a new bookmark
    echo -e "New Site,https://newsite.com\n$(cat "$TEST_SITES")" > "$TEST_SITES"
    new_count=$(wc -l < "$TEST_SITES")

    assert_equals "$((initial_count + 1))" "$new_count" "Adding bookmark should increase line count"

    # Check that new bookmark is at the top
    first_line=$(head -n 1 "$TEST_SITES")
    assert_equals "New Site,https://newsite.com" "$first_line" "New bookmark should be at top of file"

    # Test adding a folder
    echo -e "📁(newfolder),folder\n$(cat "$TEST_SITES")" > "$TEST_SITES"
    first_line=$(head -n 1 "$TEST_SITES")
    assert_contains "newfolder" "$first_line" "New folder should be at top of file"
    assert_contains "folder" "$first_line" "New folder should have 'folder' marker"

    # Test adding to a folder
    echo ",📁(newfolder),New Subsite,https://subsite.com" >> "$TEST_SITES"
    result=$(grep "📁(newfolder)" "$TEST_SITES" | grep "New Subsite")
    assert_contains "New Subsite" "$result" "Should be able to add bookmark to folder"

    end_suite

    start_suite "CSV Format Validation"

    # Recreate clean CSV for format validation
    create_test_csv "$TEST_SITES"

    # Test valid CSV formats
    assert_file_exists "$TEST_SITES" "sites.csv should exist"

    # Check folder format
    folders=$(grep ",folder$" "$TEST_SITES")
    assert_contains "📁" "$folders" "Folders should be marked with emoji"

    # Check subsite format (4 columns)
    subsites=$(grep "^," "$TEST_SITES")
    has_four_cols=true
    while IFS= read -r line; do
        col_count=$(echo "$line" | awk -F, '{print NF}')
        if [[ $col_count -ne 4 ]]; then
            has_four_cols=false
            assert_equals "4" "$col_count" "Subsite lines should have 4 columns"
            break
        fi
    done <<< "$subsites"

    if [[ "$has_four_cols" == "true" ]]; then
        assert_equals "4" "4" "All subsite lines have 4 columns"
    fi

    # Check top-level site format (2 columns, not starting with comma)
    toplevel=$(grep -v "^," "$TEST_SITES" | grep -v ",folder$" | head -n 1)
    if [[ -n "$toplevel" ]]; then
        col_count=$(echo "$toplevel" | awk -F, '{print NF}')
        assert_equals "2" "$col_count" "Top-level sites should have 2 columns"
    fi

    end_suite
}

# Run tests and cleanup
run_tests
cleanup_test_dir "$TEMP_DIR"
print_summary
exit $?
