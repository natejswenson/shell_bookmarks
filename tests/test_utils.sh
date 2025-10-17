#!/bin/bash
# Test utilities and assertion framework

# Color codes for test output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test suite tracking
CURRENT_SUITE=""

# Start a test suite
start_suite() {
    CURRENT_SUITE="$1"
    echo ""
    echo "=========================================="
    echo "Test Suite: $CURRENT_SUITE"
    echo "=========================================="
}

# End a test suite
end_suite() {
    echo ""
}

# Assert functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    ((TESTS_RUN++))

    if [[ "$expected" == "$actual" ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: $message"
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        return 1
    fi
}

assert_not_equals() {
    local not_expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    ((TESTS_RUN++))

    if [[ "$not_expected" != "$actual" ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: $message"
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: $message"
        echo "  Should not equal: '$not_expected'"
        echo "  Actual:           '$actual'"
        return 1
    fi
}

assert_contains() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    ((TESTS_RUN++))

    if [[ "$actual" == *"$expected"* ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: $message"
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: $message"
        echo "  Expected to contain: '$expected'"
        echo "  Actual:              '$actual'"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"

    ((TESTS_RUN++))

    if [[ -f "$file" ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: $message"
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: $message"
        return 1
    fi
}

assert_file_not_exists() {
    local file="$1"
    local message="${2:-File should not exist: $file}"

    ((TESTS_RUN++))

    if [[ ! -f "$file" ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: $message"
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: $message"
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-Condition should be true}"

    ((TESTS_RUN++))

    if [[ "$condition" == "0" ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: $message"
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: $message"
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-Condition should be false}"

    ((TESTS_RUN++))

    if [[ "$condition" != "0" ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: $message"
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: $message"
        return 1
    fi
}

# Print test summary
print_summary() {
    echo ""
    echo "=========================================="
    echo "Test Summary"
    echo "=========================================="
    echo "Total tests:  $TESTS_RUN"
    echo -e "${GREEN}Passed:       $TESTS_PASSED${NC}"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${RED}Failed:       $TESTS_FAILED${NC}"
        return 1
    else
        echo "Failed:       $TESTS_FAILED"
        return 0
    fi
}

# Create a temporary test directory
create_test_dir() {
    local test_dir=$(mktemp -d)
    echo "$test_dir"
}

# Clean up test directory
cleanup_test_dir() {
    local test_dir="$1"
    if [[ -d "$test_dir" ]]; then
        rm -rf "$test_dir"
    fi
}

# Create a test CSV file
create_test_csv() {
    local file="$1"
    cat > "$file" << 'EOF'
📁(aws),folder
📁(github),folder
📁(google),folder
,📁(github),Profile,https://www.github.com
,📁(github),shell_bookmarks,https://github.com/natejswenson/shell_bookmarks
,📁(google),google,https://www.google.com
,📁(google),gmail,https://mail.google.com/
,📁(aws),Profile,https://console.aws.amazon.com/
,📁(aws),EC2,https://console.aws.amazon.com/ec2/
Test Site,https://test.com
EOF
}

# Create a minimal .config file for testing
create_test_config() {
    local file="$1"
    cat > "$file" << 'EOF'
pcolor=""
scolor=""
rcolor=""
boldcolor=""
blinkcolor=""
bmt=('add a top level bookmark' 'create a bookmark folder' 'add bookmark to a folder')
bmth=("adding a top level bookmark..." "creating a bookmark folder...." "adding bookmark to a folder...")
nav1h="choose a site to open in browser..."
nav2h="choose bookmarked site..."
nav3h="choose a folder to add a site too..."
nav4h="choose a mehtod to append your sites.csv..."
bookmark="Enter folder or site name you would like to add..."
array=('BOOKMARK NAVIGATION' 'Created by NateJSwenson' 'github:@natejswenson')
hba="has been added to sites.csv!"
folder="folder"
hash="#"
EOF
}
