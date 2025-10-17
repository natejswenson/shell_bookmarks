#!/bin/bash
# Unit tests for nav.sh functions

# Get the directory of this test script
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$TEST_DIR")"

# Source test utilities
source "$TEST_DIR/test_utils.sh"

# Create temporary test environment
TEMP_DIR=$(create_test_dir)
TEST_SITES="$TEMP_DIR/sites.csv"
TEST_CONFIG="$TEMP_DIR/.config"

# Setup test environment
setup_test_env() {
    create_test_csv "$TEST_SITES"
    create_test_config "$TEST_CONFIG"
}

# Source the nav.sh script functions (but not execute main logic)
setup_nav_functions() {
    # Set up required variables
    my_dir="$TEMP_DIR"
    sites="$TEST_SITES"
    source "$TEST_CONFIG"

    # Mock colors for testing
    pcolor=""
    scolor=""
    rcolor=""
    boldcolor=""
    blinkcolor=""

    # Load CSV data into memory (from nav.sh)
    mapfile -t CSV_LINES < "$sites"

    # Pre-compute main sites list
    main_sites=""
    for line in "${CSV_LINES[@]}"; do
        IFS=',' read -r col1 col2 col3 col4 <<< "$line"
        if [[ -n "$col1" ]]; then
            main_sites+="$col1"$'\n'
        fi
    done

    # Source the functions from nav.sh
    source <(sed -n '/^selected_main_site()/,/^}/p' "$PROJECT_DIR/nav.sh")
    source <(sed -n '/^column_2_row_selected()/,/^}/p' "$PROJECT_DIR/nav.sh")
    source <(sed -n '/^subsites_of_selected_main_site()/,/^}/p' "$PROJECT_DIR/nav.sh")
    source <(sed -n '/^folders()/,/^}/p' "$PROJECT_DIR/nav.sh")
    source <(sed -n '/^selected_subsite_url()/,/^}/p' "$PROJECT_DIR/nav.sh")
    source <(sed -n '/^smc()/,/^}/p' "$PROJECT_DIR/nav.sh")
}

# Run tests
run_tests() {
    setup_test_env
    setup_nav_functions

    start_suite "CSV Parsing Functions"

    # Test selected_main_site
    result=$(selected_main_site 1)
    assert_equals "📁(aws)" "$result" "selected_main_site(1) should return first site"

    result=$(selected_main_site 2)
    assert_equals "📁(github)" "$result" "selected_main_site(2) should return second site"

    result=$(selected_main_site 10)
    assert_equals "Test Site" "$result" "selected_main_site(10) should return last site"

    # Test column_2_row_selected
    result=$(column_2_row_selected 1)
    assert_equals "folder" "$result" "column_2_row_selected(1) should return 'folder'"

    result=$(column_2_row_selected 4)
    assert_equals "📁(github)" "$result" "column_2_row_selected(4) should return folder name"

    # Test folders function
    result=$(folders)
    assert_contains "📁(aws)" "$result" "folders() should contain aws folder"
    assert_contains "📁(github)" "$result" "folders() should contain github folder"
    assert_contains "📁(google)" "$result" "folders() should contain google folder"

    # Count number of folders
    folder_count=$(folders | wc -l)
    assert_equals "3" "$folder_count" "folders() should return 3 folders"

    # Test subsites_of_selected_main_site
    result=$(subsites_of_selected_main_site "📁(github)")
    assert_contains "Profile" "$result" "subsites should contain Profile"
    assert_contains "shell_bookmarks" "$result" "subsites should contain shell_bookmarks"

    github_count=$(subsites_of_selected_main_site "📁(github)" | wc -l)
    assert_equals "2" "$github_count" "github folder should have 2 subsites"

    google_count=$(subsites_of_selected_main_site "📁(google)" | wc -l)
    assert_equals "2" "$google_count" "google folder should have 2 subsites"

    aws_count=$(subsites_of_selected_main_site "📁(aws)" | wc -l)
    assert_equals "2" "$aws_count" "aws folder should have 2 subsites"

    # Test selected_subsite_url
    result=$(selected_subsite_url "📁(github)" 1)
    assert_equals "https://www.github.com" "$result" "First github subsite URL should be correct"

    result=$(selected_subsite_url "📁(github)" 2)
    assert_equals "https://github.com/natejswenson/shell_bookmarks" "$result" "Second github subsite URL should be correct"

    result=$(selected_subsite_url "📁(google)" 1)
    assert_equals "https://www.google.com" "$result" "First google subsite URL should be correct"

    result=$(selected_subsite_url "📁(aws)" 2)
    assert_equals "https://console.aws.amazon.com/ec2/" "$result" "Second aws subsite URL should be correct"

    # Test smc function (checks if main site has subsites)
    result=$(smc "📁(github)")
    assert_not_equals "" "$result" "github folder should have subsites"

    result=$(smc "Test Site")
    assert_equals "" "$result" "Test Site should not have subsites"

    end_suite

    start_suite "Edge Cases"

    # Test with invalid index
    result=$(selected_main_site 999)
    assert_equals "" "$result" "Invalid index should return empty"

    # Test with non-existent folder
    result=$(subsites_of_selected_main_site "NonExistent")
    assert_equals "" "$result" "Non-existent folder should return empty"

    result=$(selected_subsite_url "NonExistent" 1)
    assert_equals "" "$result" "Non-existent folder URL should return empty"

    end_suite
}

# Run tests and cleanup
run_tests
cleanup_test_dir "$TEMP_DIR"
print_summary
exit $?
