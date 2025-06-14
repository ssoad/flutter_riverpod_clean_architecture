#!/bin/bash

# Flutter Localization Helper Script
# This script helps manage language files for the Flutter app

# Colors for pretty output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}   Flutter Localization Helper Tool    ${NC}"
echo -e "${BLUE}=======================================${NC}"

BASE_ARB_DIR="lib/l10n/arb"
BASE_ARB_FILE="${BASE_ARB_DIR}/intl_en.arb"

# Check if flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter command not found.${NC}"
    exit 1
fi

# Function to generate localization files
generate_localization() {
    echo -e "${YELLOW}Generating localization files...${NC}"
    flutter gen-l10n
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Localization files generated successfully!${NC}"
    else
        echo -e "${RED}Failed to generate localization files!${NC}"
        exit 1
    fi
}

# Function to list all supported languages
list_languages() {
    echo -e "${YELLOW}Currently supported languages:${NC}"
    
    # Find all ARB files and extract language codes
    for file in ${BASE_ARB_DIR}/intl_*.arb; do
        lang_code=$(basename "$file" | sed 's/intl_\(.*\)\.arb/\1/')
        
        # Get language name from the ARB file if possible
        if [ -f "$file" ]; then
            lang_name=$(grep -o '"@@locale": "[^"]*"' "$file" | cut -d'"' -f4)
            if [ -z "$lang_name" ]; then
                lang_name=$lang_code
            fi
            echo -e " - ${GREEN}$lang_code${NC} ($lang_name)"
        fi
    done
}

# Function to create a new language file
create_language() {
    if [ -z "$1" ]; then
        echo -e "${RED}Error: No language code provided.${NC}"
        echo -e "Usage: $0 add-language <language_code>"
        exit 1
    fi
    
    lang_code=$1
    new_arb_file="${BASE_ARB_DIR}/intl_${lang_code}.arb"
    
    if [ -f "$new_arb_file" ]; then
        echo -e "${RED}Error: Language file for '${lang_code}' already exists.${NC}"
        exit 1
    fi
    
    if [ ! -f "$BASE_ARB_FILE" ]; then
        echo -e "${RED}Error: Base language file (${BASE_ARB_FILE}) not found.${NC}"
        exit 1
    fi
    
    # Copy the base language file and update the locale
    cp "$BASE_ARB_FILE" "$new_arb_file"
    
    # Update the locale in the new file
    sed -i '' "s/\"@@locale\": \"en\"/\"@@locale\": \"${lang_code}\"/" "$new_arb_file"
    
    echo -e "${GREEN}Created new language file: ${new_arb_file}${NC}"
    echo -e "${YELLOW}Please translate the strings in the new file.${NC}"
}

# Function to check for missing translations
check_missing() {
    echo -e "${YELLOW}Checking for missing translations...${NC}"
    
    if [ ! -f "$BASE_ARB_FILE" ]; then
        echo -e "${RED}Error: Base language file (${BASE_ARB_FILE}) not found.${NC}"
        exit 1
    fi
    
    # Get all keys from base file
    base_keys=$(grep -o '"[^"]*": "[^"]*"' "$BASE_ARB_FILE" | grep -v "@@" | cut -d'"' -f2)
    
    # Check each language file
    for file in ${BASE_ARB_DIR}/intl_*.arb; do
        if [ "$file" != "$BASE_ARB_FILE" ]; then
            lang_code=$(basename "$file" | sed 's/intl_\(.*\)\.arb/\1/')
            echo -e "\nChecking ${BLUE}${lang_code}${NC}:"
            
            missing=0
            for key in $base_keys; do
                if ! grep -q "\"$key\":" "$file"; then
                    echo -e " - Missing: ${RED}$key${NC}"
                    missing=$((missing + 1))
                fi
            done
            
            if [ $missing -eq 0 ]; then
                echo -e " ${GREEN}✓ All translations present${NC}"
            else
                echo -e " ${RED}$missing translation(s) missing${NC}"
            fi
        fi
    done
}

# Function to get usage information
usage() {
    echo -e "Usage: $0 <command>"
    echo -e "\nCommands:"
    echo -e "  ${GREEN}generate${NC}     - Generate localization files"
    echo -e "  ${GREEN}list${NC}         - List supported languages"
    echo -e "  ${GREEN}add${NC} <code>   - Add a new language (e.g., 'add fr' for French)"
    echo -e "  ${GREEN}check${NC}        - Check for missing translations"
    echo -e "  ${GREEN}help${NC}         - Show this help message"
}

# Main command parsing
case "$1" in
    generate)
        generate_localization
        ;;
    list)
        list_languages
        ;;
    add)
        create_language "$2"
        ;;
    check)
        check_missing
        ;;
    help)
        usage
        ;;
    *)
        usage
        exit 1
        ;;
esac

exit 0