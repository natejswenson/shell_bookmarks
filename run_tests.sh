#!/bin/bash
# Main test runner script

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/tests"

# Color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall results
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

echo ""
echo "=========================================="
echo "  Shell Bookmarks Test Suite"
echo "=========================================="
echo ""

# Function to run a test file
run_test_file() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .sh)

    ((TOTAL_SUITES++))

    echo -e "${BLUE}Running: $test_name${NC}"
    echo ""

    if bash "$test_file"; then
        ((PASSED_SUITES++))
        echo -e "${GREEN}✓ $test_name completed successfully${NC}"
    else
        ((FAILED_SUITES++))
        echo -e "${RED}✗ $test_name failed${NC}"
    fi

    echo ""
}

# Check if test directory exists
if [[ ! -d "$TEST_DIR" ]]; then
    echo -e "${RED}Error: Test directory not found at $TEST_DIR${NC}"
    exit 1
fi

# Make all test files executable
chmod +x "$TEST_DIR"/*.sh 2>/dev/null

# Run specific test if provided as argument
if [[ -n "$1" ]]; then
    test_file="$TEST_DIR/$1"
    if [[ ! -f "$test_file" ]]; then
        test_file="$TEST_DIR/${1}.sh"
    fi

    if [[ -f "$test_file" ]]; then
        run_test_file "$test_file"
    else
        echo -e "${RED}Error: Test file not found: $1${NC}"
        echo ""
        echo "Available tests:"
        for f in "$TEST_DIR"/test_*.sh; do
            echo "  - $(basename "$f" .sh)"
        done
        exit 1
    fi
else
    # Run all test files
    for test_file in "$TEST_DIR"/test_*.sh; do
        if [[ -f "$test_file" ]]; then
            run_test_file "$test_file"
        fi
    done
fi

# Print overall summary
echo "=========================================="
echo "  Overall Test Summary"
echo "=========================================="
echo "Test suites run:    $TOTAL_SUITES"
echo -e "${GREEN}Suites passed:      $PASSED_SUITES${NC}"

if [[ $FAILED_SUITES -gt 0 ]]; then
    echo -e "${RED}Suites failed:      $FAILED_SUITES${NC}"
    echo ""
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
else
    echo "Suites failed:      $FAILED_SUITES"
    echo ""
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
