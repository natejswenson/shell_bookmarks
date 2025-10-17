#!/bin/bash
# Tests for help.sh

# Get the directory of this test script
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$TEST_DIR")"

# Source test utilities
source "$TEST_DIR/test_utils.sh"

# Create temporary test environment
TEMP_DIR=$(create_test_dir)
TEST_SITES="$TEMP_DIR/sites.csv"
TEST_CONFIG="$TEMP_DIR/.config"
TEST_HELP="$TEMP_DIR/help.sh"
TEST_NAV="$TEMP_DIR/nav.sh"

# Setup test environment
setup_test_env() {
    create_test_csv "$TEST_SITES"
    create_test_config "$TEST_CONFIG"

    # Copy scripts to temp dir
    cp "$PROJECT_DIR/help.sh" "$TEST_HELP"
    cp "$PROJECT_DIR/nav.sh" "$TEST_NAV"
    chmod +x "$TEST_HELP"
    chmod +x "$TEST_NAV"
}

# Run tests
run_tests() {
    setup_test_env

    start_suite "Help Script Validation"

    # Test that help.sh exists
    assert_file_exists "$PROJECT_DIR/help.sh" "help.sh should exist"

    # Test syntax check
    bash -n "$PROJECT_DIR/help.sh" 2>/dev/null
    assert_true "$?" "help.sh should have valid bash syntax"

    end_suite

    start_suite "Help Script Path Resolution"

    # Test that help.sh uses $my_dir instead of hardcoded paths
    grep -q '$HOME/local_repo/shell_favorites' "$PROJECT_DIR/help.sh"
    assert_false "$?" "help.sh should not contain hardcoded paths"

    # Test that help.sh uses $my_dir variable
    grep -q '$my_dir' "$PROJECT_DIR/help.sh"
    assert_true "$?" "help.sh should use \$my_dir variable"

    # Test that help.sh references nav.sh correctly
    grep -q '"$my_dir/nav.sh"' "$PROJECT_DIR/help.sh"
    assert_true "$?" "help.sh should reference nav.sh with proper quoting"

    end_suite

    start_suite "Help Script EDITOR Variable"

    # Test that help.sh respects EDITOR variable
    grep -q 'EDITOR' "$PROJECT_DIR/help.sh"
    assert_true "$?" "help.sh should check EDITOR variable"

    # Test default to vi
    grep -q 'EDITOR:-vi' "$PROJECT_DIR/help.sh"
    assert_true "$?" "help.sh should default to vi when EDITOR not set"

    end_suite

    start_suite "Help Script Menu Options"

    # Read help.sh content
    help_content=$(cat "$PROJECT_DIR/help.sh")

    # Test that menu options exist
    assert_contains "add a favorite" "$help_content" "Should have 'add a favorite' option"
    assert_contains "open a bookmarked site" "$help_content" "Should have 'open a bookmarked site' option"
    assert_contains "edit sites.csv" "$help_content" "Should have 'edit sites.csv' option"
    assert_contains "leave" "$help_content" "Should have 'leave' option"

    # Test that .leave typo is fixed
    grep -q '".leave"' "$PROJECT_DIR/help.sh"
    assert_false "$?" "Should not have .leave typo (should be 'leave')"

    end_suite

    start_suite "Configuration Loading"

    # Test that help.sh sources .config
    grep -q 'source.*\.config' "$PROJECT_DIR/help.sh"
    assert_true "$?" "help.sh should source .config file"

    # Test that my_dir is set correctly
    grep -q 'my_dir=' "$PROJECT_DIR/help.sh"
    assert_true "$?" "help.sh should set my_dir variable"

    end_suite
}

# Run tests and cleanup
run_tests
cleanup_test_dir "$TEMP_DIR"
print_summary
exit $?
