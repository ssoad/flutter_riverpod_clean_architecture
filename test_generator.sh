#!/bin/bash

# Flutter Riverpod Clean Architecture - Test Generator
# This script generates and runs tests with coverage

# Colors for pretty output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}      Test Generator & Runner         ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Default values
COVERAGE="yes"
REPORT="yes"
TARGET=""

# Function to display usage information
usage() {
    echo -e "Usage: $0 [options]"
    echo -e "\nOptions:"
    echo -e "  --no-coverage         Run tests without coverage"
    echo -e "  --no-report           Don't generate coverage report"
    echo -e "  --target <path>       Run tests in specific path only"
    echo -e "  --help                Display this help message"
    echo -e "\nExamples:"
    echo -e "  $0                                # Run all tests with coverage"
    echo -e "  $0 --target test/features/auth/   # Run only auth feature tests"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-coverage)
            COVERAGE="no"
            shift
            ;;
        --no-report)
            REPORT="no"
            shift
            ;;
        --target)
            TARGET="$2"
            shift 2
            ;;
        --help)
            usage
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter command not found.${NC}"
    exit 1
fi

# Run tests
if [ "$COVERAGE" = "yes" ]; then
    echo -e "\n${YELLOW}Running tests with coverage...${NC}"
    
    if [ -n "$TARGET" ]; then
        flutter test --coverage "$TARGET"
    else
        flutter test --coverage
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "\n${RED}Tests failed!${NC}"
        exit 1
    fi
    
    # Generate coverage report if requested
    if [ "$REPORT" = "yes" ]; then
        echo -e "\n${YELLOW}Generating coverage report...${NC}"
        
        if command -v lcov &> /dev/null; then
            # Generate HTML report using lcov
            genhtml coverage/lcov.info -o coverage/html
            
            if [ $? -eq 0 ]; then
                echo -e "\n${GREEN}Coverage report generated!${NC}"
                echo -e "Open ${YELLOW}coverage/html/index.html${NC} in your browser to view it."
                
                # Try to open the report in the default browser
                if command -v open &> /dev/null; then
                    open coverage/html/index.html
                elif command -v xdg-open &> /dev/null; then
                    xdg-open coverage/html/index.html
                elif command -v start &> /dev/null; then
                    start coverage/html/index.html
                else
                    echo -e "Please open the report manually in your browser."
                fi
            else
                echo -e "\n${RED}Failed to generate HTML coverage report.${NC}"
                echo -e "Please make sure lcov is installed correctly."
            fi
        else
            echo -e "\n${YELLOW}lcov is not installed. Cannot generate HTML coverage report.${NC}"
            echo -e "You can install it with:"
            echo -e "  - On macOS: brew install lcov"
            echo -e "  - On Ubuntu/Debian: apt-get install lcov"
            echo -e "  - On Windows: choco install lcov"
            echo -e "\nAlternatively, you can view the raw coverage data in ${YELLOW}coverage/lcov.info${NC}"
        fi
    fi
else
    echo -e "\n${YELLOW}Running tests without coverage...${NC}"
    
    if [ -n "$TARGET" ]; then
        flutter test "$TARGET"
    else
        flutter test
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "\n${RED}Tests failed!${NC}"
        exit 1
    fi
fi

echo -e "\n${GREEN}✅ Tests completed successfully!${NC}"
exit 0
