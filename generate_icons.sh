#!/bin/bash

# App Icon Generator
# This script generates app icons for all platforms using flutter_launcher_icons
# -----------------------------------------------------------------------------

# Set text colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}    Flutter App Icon Generator        ${NC}"
echo -e "${BLUE}=======================================${NC}"
echo

# Check if flutter_launcher_icons.yaml exists
if [ ! -f "flutter_launcher_icons.yaml" ]; then
    echo -e "${RED}Error: flutter_launcher_icons.yaml not found!${NC}"
    echo -e "${YELLOW}Please make sure you have the configuration file in the root directory.${NC}"
    exit 1
fi

# Check if the source icon exists
# Extract image_path from yaml (simple grep, might fail on complex yaml but good enough for standard config)
ICON_PATH=$(grep "image_path:" flutter_launcher_icons.yaml | head -n 1 | awk -F': ' '{print $2}' | tr -d '"' | tr -d "'")

if [ ! -f "$ICON_PATH" ]; then
    echo -e "${YELLOW}Warning: Source icon ($ICON_PATH) not found.${NC}"
    echo -e "Please ensure you have an icon at ${GREEN}$ICON_PATH${NC} before running this script."
    echo -e "Recommended size: 1024x1024 png"
    echo
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Operation canceled.${NC}"
        exit 0
    fi
else
    echo -e "${GREEN}Found source icon at: $ICON_PATH${NC}"
fi

echo -e "${BLUE}Generating icons for all platforms...${NC}"
echo

# Run the generator
dart run flutter_launcher_icons

if [ $? -eq 0 ]; then
    echo
    echo -e "${GREEN}✅ Icons generated successfully!${NC}"
    echo -e "   - Android: mipmap resources updated"
    echo -e "   - iOS: Assets.xcassets updated"
    echo -e "   - Web: icons and manifest updated"
    echo -e "   - Windows/macOS: icon files updated"
else
    echo
    echo -e "${RED}❌ Error generating icons.${NC}"
    exit 1
fi
