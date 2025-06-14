#!/bin/bash

# Flutter App Renamer
# This script renames your Flutter app and updates package names across all platforms
# -----------------------------------------------------------------------------

# Set text colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}      Flutter App Renamer Script      ${NC}"
echo -e "${BLUE}=======================================${NC}"
echo

# Function to display usage information
show_usage() {
    echo -e "Usage: $0 [options]"
    echo -e "\nOptions:"
    echo -e "  --app-name \"New App Name\"   Set the new app display name (required)"
    echo -e "  --package-name com.example.newapp   Set the new package name (required)"
    echo -e "  --help                      Show this help message"
    echo
    echo -e "Examples:"
    echo -e "  $0 --app-name \"My Amazing App\" --package-name com.mycompany.amazingapp"
    echo
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --app-name)
            NEW_APP_NAME="$2"
            shift 2
            ;;
        --package-name)
            NEW_PACKAGE_NAME="$2"
            shift 2
            ;;
        --help)
            show_usage
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            show_usage
            ;;
    esac
done

# Validate required arguments
if [ -z "$NEW_APP_NAME" ] || [ -z "$NEW_PACKAGE_NAME" ]; then
    echo -e "${RED}Error: Both --app-name and --package-name are required${NC}"
    show_usage
fi

# Validate package name format (com.example.app)
if ! [[ $NEW_PACKAGE_NAME =~ ^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+[0-9a-z_]$ ]]; then
    echo -e "${RED}Error: Package name must be in valid format (e.g., com.example.app)${NC}"
    exit 1
fi

# Get current app information
CURRENT_DIR=$(pwd)
PUBSPEC_PATH="$CURRENT_DIR/pubspec.yaml"

if [ ! -f "$PUBSPEC_PATH" ]; then
    echo -e "${RED}Error: pubspec.yaml not found. Please run this script from the root of your Flutter project.${NC}"
    exit 1
fi

# Get current app name and package name
CURRENT_APP_NAME=$(grep "name:" "$PUBSPEC_PATH" | head -n 1 | awk -F': ' '{print $2}' | tr -d ' ')
echo -e "${YELLOW}Current app name identifier:${NC} $CURRENT_APP_NAME"
echo -e "${YELLOW}New app display name:${NC} $NEW_APP_NAME"
echo -e "${YELLOW}New package name:${NC} $NEW_PACKAGE_NAME"

# Confirm with user
echo
read -p "Do you want to proceed with renaming? This operation cannot be easily undone. (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Operation canceled.${NC}"
    exit 0
fi

echo -e "${BLUE}Starting renaming process...${NC}"

# Function to count files in a directory recursively
count_files() {
    find "$1" -type f | wc -l | tr -d ' '
}

# Calculate total number of steps
TOTAL_STEPS=8
CURRENT_STEP=0

# Function to update progress
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP+1))
    echo -e "${BLUE}[$CURRENT_STEP/$TOTAL_STEPS] $1${NC}"
}

# 1. Update Android files
update_progress "Updating Android files"

# Android app name in strings.xml
if [ -f "android/app/src/main/res/values/strings.xml" ]; then
    sed -i '' "s/<string name=\"app_name\">.*<\/string>/<string name=\"app_name\">$NEW_APP_NAME<\/string>/g" "android/app/src/main/res/values/strings.xml"
elif [ -d "android/app/src/main/res/values" ]; then
    mkdir -p "android/app/src/main/res/values"
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<resources>
    <string name=\"app_name\">$NEW_APP_NAME</string>
</resources>" > "android/app/src/main/res/values/strings.xml"
fi

# Android package name in build.gradle or build.gradle.kts
if [ -f "android/app/build.gradle" ]; then
    sed -i '' "s/applicationId \".*\"/applicationId \"$NEW_PACKAGE_NAME\"/g" "android/app/build.gradle"
elif [ -f "android/app/build.gradle.kts" ]; then
    # Handle Kotlin DSL format which uses = instead of space
    sed -i '' "s/applicationId = \".*\"/applicationId = \"$NEW_PACKAGE_NAME\"/g" "android/app/build.gradle.kts"
    sed -i '' "s/namespace = \".*\"/namespace = \"$NEW_PACKAGE_NAME\"/g" "android/app/build.gradle.kts"
fi

# Android manifest
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    OLD_PACKAGE_NAME=$(grep "package=" "android/app/src/main/AndroidManifest.xml" | sed 's/.*package="\(.*\)".*/\1/')
    sed -i '' "s/package=\"$OLD_PACKAGE_NAME\"/package=\"$NEW_PACKAGE_NAME\"/g" "android/app/src/main/AndroidManifest.xml"
fi

# Android package directories
if [ -n "$OLD_PACKAGE_NAME" ]; then
    OLD_PACKAGE_PATH=$(echo "$OLD_PACKAGE_NAME" | tr '.' '/')
    NEW_PACKAGE_PATH=$(echo "$NEW_PACKAGE_NAME" | tr '.' '/')
    
    # Only attempt this if the directories exist
    if [ -d "android/app/src/main/kotlin/$OLD_PACKAGE_PATH" ]; then
        mkdir -p "android/app/src/main/kotlin/$NEW_PACKAGE_PATH"
        mv "android/app/src/main/kotlin/$OLD_PACKAGE_PATH"/* "android/app/src/main/kotlin/$NEW_PACKAGE_PATH/"
        
        # Update package name in Kotlin files
        find "android/app/src/main/kotlin/$NEW_PACKAGE_PATH" -name "*.kt" -type f -exec sed -i '' "s/package $OLD_PACKAGE_NAME/package $NEW_PACKAGE_NAME/g" {} \;
        
        # Clean up old directories
        rm -rf "android/app/src/main/kotlin/$OLD_PACKAGE_PATH"
    fi
fi

# 2. Update iOS files
update_progress "Updating iOS files"

# iOS app name in Info.plist
if [ -f "ios/Runner/Info.plist" ]; then
    FOUND_BUNDLE_NAME=$(grep -A 1 "CFBundleName" "ios/Runner/Info.plist")
    if [ -n "$FOUND_BUNDLE_NAME" ]; then
        sed -i '' "s/<key>CFBundleName<\/key>.*/<key>CFBundleName<\/key>\\
	<string>$NEW_APP_NAME<\/string>/g" "ios/Runner/Info.plist"
    else
        # If CFBundleName doesn't exist, add it just after CFBundleDisplayName
        sed -i '' "/<key>CFBundleDisplayName<\/key>/a\\
	<key>CFBundleName<\/key>\\
	<string>$NEW_APP_NAME<\/string>" "ios/Runner/Info.plist"
    fi
    
    # Also update CFBundleDisplayName
    FOUND_DISPLAY_NAME=$(grep -A 1 "CFBundleDisplayName" "ios/Runner/Info.plist")
    if [ -n "$FOUND_DISPLAY_NAME" ]; then
        sed -i '' "s/<key>CFBundleDisplayName<\/key>.*/<key>CFBundleDisplayName<\/key>\\
	<string>$NEW_APP_NAME<\/string>/g" "ios/Runner/Info.plist"
    fi
    
    # Update bundle identifier
    sed -i '' "s/<key>CFBundleIdentifier<\/key>.*/<key>CFBundleIdentifier<\/key>\\
	<string>$NEW_PACKAGE_NAME<\/string>/g" "ios/Runner/Info.plist"
fi

# Update iOS project file
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = .*;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME;/g" "ios/Runner.xcodeproj/project.pbxproj"
fi

# 3. Update macOS files
update_progress "Updating macOS files"

if [ -d "macos" ]; then
    # macOS app name in Info.plist
    if [ -f "macos/Runner/Info.plist" ]; then
        FOUND_BUNDLE_NAME=$(grep -A 1 "CFBundleName" "macos/Runner/Info.plist")
        if [ -n "$FOUND_BUNDLE_NAME" ]; then
            sed -i '' "s/<key>CFBundleName<\/key>.*/<key>CFBundleName<\/key>\\
	<string>$NEW_APP_NAME<\/string>/g" "macos/Runner/Info.plist"
        fi
        
        # Also update CFBundleDisplayName
        FOUND_DISPLAY_NAME=$(grep -A 1 "CFBundleDisplayName" "macos/Runner/Info.plist")
        if [ -n "$FOUND_DISPLAY_NAME" ]; then
            sed -i '' "s/<key>CFBundleDisplayName<\/key>.*/<key>CFBundleDisplayName<\/key>\\
	<string>$NEW_APP_NAME<\/string>/g" "macos/Runner/Info.plist"
        fi
        
        # Update bundle identifier
        sed -i '' "s/<key>CFBundleIdentifier<\/key>.*/<key>CFBundleIdentifier<\/key>\\
	<string>$NEW_PACKAGE_NAME<\/string>/g" "macos/Runner/Info.plist"
    fi
    
    # Update macOS project file
    if [ -f "macos/Runner.xcodeproj/project.pbxproj" ]; then
        sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = .*;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME;/g" "macos/Runner.xcodeproj/project.pbxproj"
    fi
fi

# 4. Update Windows files
update_progress "Updating Windows files"

if [ -d "windows" ]; then
    # Update app name in CMakeLists.txt
    if [ -f "windows/CMakeLists.txt" ]; then
        # For project name (which should use snake_case)
        sed -i '' "s/project(.*)/project($PUBSPEC_APP_NAME LANGUAGES CXX)/g" "windows/CMakeLists.txt"
        
        # For binary name
        sed -i '' "s/set(BINARY_NAME \".*\")/set(BINARY_NAME \"$PUBSPEC_APP_NAME\")/g" "windows/CMakeLists.txt"
    fi
    
    # Update app name in runner.rc
    if [ -f "windows/runner/Runner.rc" ]; then
        sed -i '' "s/VALUE \"FileDescription\", \".*\"/VALUE \"FileDescription\", \"$NEW_APP_NAME\"/g" "windows/runner/Runner.rc"
        sed -i '' "s/VALUE \"ProductName\", \".*\"/VALUE \"ProductName\", \"$NEW_APP_NAME\"/g" "windows/runner/Runner.rc"
    fi
fi

# 5. Update Linux files
update_progress "Updating Linux files"

if [ -d "linux" ]; then
    # Update app name and binary name in CMakeLists.txt
    if [ -f "linux/CMakeLists.txt" ]; then
        # For project name
        sed -i '' "s/project(.*)/project($PUBSPEC_APP_NAME LANGUAGES CXX)/g" "linux/CMakeLists.txt"
        
        # For binary name
        sed -i '' "s/set(BINARY_NAME \".*\")/set(BINARY_NAME \"$PUBSPEC_APP_NAME\")/g" "linux/CMakeLists.txt"
        
        # For application ID
        sed -i '' "s/set(APPLICATION_ID \".*\")/set(APPLICATION_ID \"$NEW_PACKAGE_NAME\")/g" "linux/CMakeLists.txt"
    fi
    
    # Update desktop entry
    if [ -f "linux/my_application.cc" ]; then
        sed -i '' "s/g_application_set_application_id (application, \".*\");/g_application_set_application_id (application, \"$NEW_PACKAGE_NAME\");/g" "linux/my_application.cc"
    fi
fi

# 6. Update web files
update_progress "Updating web files"

if [ -d "web" ]; then
    # Update title in index.html
    if [ -f "web/index.html" ]; then
        sed -i '' "s/<title>.*<\/title>/<title>$NEW_APP_NAME<\/title>/g" "web/index.html"
    fi
    
    # Update manifest.json
    if [ -f "web/manifest.json" ]; then
        sed -i '' "s/\"name\": \".*\"/\"name\": \"$NEW_APP_NAME\"/g" "web/manifest.json"
        sed -i '' "s/\"short_name\": \".*\"/\"short_name\": \"$NEW_APP_NAME\"/g" "web/manifest.json"
    fi
fi

# 7. Update pubspec.yaml
update_progress "Updating pubspec.yaml"

# Update name in pubspec.yaml - this should be a valid Dart package name
PUBSPEC_APP_NAME=$(echo "$NEW_APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr '-' '_')
sed -i '' "s/^name: .*/name: $PUBSPEC_APP_NAME/g" "$PUBSPEC_PATH"

# Update description in pubspec.yaml
sed -i '' "s/^description: .*/description: \"$NEW_APP_NAME - A Flutter application.\"/g" "$PUBSPEC_PATH"

# 8. Update constants and main files
update_progress "Updating app constants and main files"

# Check if there's an app_constants.dart file
APP_CONSTANTS_FILES=$(find . -path "*/lib/*" -name "*constants*.dart" | grep -i "app")
if [ -n "$APP_CONSTANTS_FILES" ]; then
    for constants_file in $APP_CONSTANTS_FILES; do
        if grep -q "appName" "$constants_file"; then
            sed -i '' "s/static const String appName = '.*'/static const String appName = '$NEW_APP_NAME'/g" "$constants_file"
            sed -i '' "s/static const String appName = \".*\"/static const String appName = \"$NEW_APP_NAME\"/g" "$constants_file"
        fi
    done
fi

# Update imports in dart files
find ./lib -type f -name "*.dart" -exec sed -i '' "s/import 'package:$CURRENT_APP_NAME/import 'package:$PUBSPEC_APP_NAME/g" {} \;

# Success message
echo 
echo -e "${GREEN}✅ App successfully renamed!${NC}"
echo -e "   - Display Name: ${YELLOW}$NEW_APP_NAME${NC}"
echo -e "   - Package/Bundle ID: ${YELLOW}$NEW_PACKAGE_NAME${NC}"
echo -e "   - Dart Package Name: ${YELLOW}$PUBSPEC_APP_NAME${NC}"
echo

echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Run ${YELLOW}flutter clean${NC}"
echo -e "2. Run ${YELLOW}flutter pub get${NC}"
echo -e "3. Re-run ${YELLOW}flutter build${NC} for each platform you're targeting"
echo
echo -e "${YELLOW}Note:${NC} You may need to manually update some references if you have complex platform-specific code."
echo

exit 0
