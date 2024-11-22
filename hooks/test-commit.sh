#!/bin/bash

# Define styled output helpers
RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
MAGENTA="\033[1;35m"
WHITE="\033[1;37m"
RESET="\033[0m"
BOLD="\033[1m"

# Path to the script under test
SCRIPT_PATH="./commit-msg"
TERMINAL_WIDTH=$(tput cols)


printf "Running tests...\n\n"


SUCCESS_MSG="✅ SUCCESS: Your commit message follows the correct format."
ERROR_MSG="❌ ERROR: Commit message does not follow the required format."
EMPTY_MSG="❌ ERROR: Commit message is empty."
TIP_MSG="💡 Tip: Use \`git commit --amend\` to modify your commit message."
MISSING_SHORT_DESC="❌ ERROR: Short description is missing or improperly formatted."
SHORT_DESC_LIMIT="❌ ERROR: Short description exceeds limit characters."
INVALID_COMMIT_TYPE="❌ ERROR: Invalid commit type."
INVALID_COMMIT_SCOPE="❌ ERROR: Invalid commit scope."
INVALID_REFS_ID="❌ ERROR: Invalid 'Refs' line."
INVALID_SHORT_DESC_CAPITAL="❌ ERROR: Short description should start with a capital letter."
SHORT_DESC_TIP_MSG="💡 Tip: Consider shortening your description to fit within the limit."

print_line() {
  local length=$1
  printf "${WHITE}%*s\n" $((length )) | tr " " "="
}

# Function to run each test case
run_test() {
    INPUT="$1"
    EXPECTED_OUTPUT="$2"
    EXPECTED_EXIT_CODE="$3"

    # Create a temporary file for the commit message
    TMP_FILE=$(mktemp)
    echo -e "$INPUT" > "$TMP_FILE"

    # Run the script with the temp file as input
    OUTPUT=$(bash "$SCRIPT_PATH" "$TMP_FILE" 2>&1)
    EXIT_CODE=$?

    # Remove the temp file
    rm -f "$TMP_FILE"

    # Check results
    if [[ "$OUTPUT" == *"$EXPECTED_OUTPUT"* && "$EXIT_CODE" == "$EXPECTED_EXIT_CODE" ]]; then
        echo -e "${GREEN}✔ Test passed for input:${RESET} \"$INPUT\""
        print_line $TERMINAL_WIDTH
        printf "\n"
    else
        echo -e "${RED}✘ Test failed for input:${RESET} \"$INPUT\""
        echo -e "${RED}  Expected: $EXPECTED_OUTPUT ($EXPECTED_EXIT_CODE)${RESET}"
        echo -e "${RED}  Got: $OUTPUT ($EXIT_CODE)${RESET}"
        exit 1
    fi
}

# Test 1: Valid commit message with body and footer
INPUT="feat(API): Add new API endpoint

This adds a new API endpoint to handle user data.

Refs: #CU-12345"
EXPECTED_OUTPUT=$SUCCESS_MSG
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 2: Valid commit message without body
INPUT="fix(Database): Fix DB connection issue

Refs: #CU-67890"
EXPECTED_OUTPUT=$SUCCESS_MSG
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 3: Valid commit message with long description
INPUT="chore(Backend): Update dependencies

Updated all project dependencies to the latest versions to ensure compatibility with the new security patch and improve performance.

Refs: #CU-112233"
EXPECTED_OUTPUT=$SUCCESS_MSG
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 4: Invalid commit message with missing scope
INPUT="feat: Add new feature

Refs: #CU-98765"
EXPECTED_OUTPUT=$INVALID_COMMIT_TYPE
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 5: Invalid commit message with unrecognized type
INPUT="wip(API): Work in progress on API endpoint

Refs: #CU-54321"
EXPECTED_OUTPUT=$INVALID_COMMIT_TYPE
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 6: Valid commit message with correct footer format
INPUT="fix(API): Fix bug in API response

Refs: #12345"
EXPECTED_OUTPUT=$SUCCESS_MSG
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 7: Commit message with description exceeding character limit
INPUT="fix(Authentication): This is an excessively long description that should fail validation because it exceeds the character limit allowed for commit messages by the script's standards

Refs: #CU-99999"
EXPECTED_OUTPUT=$SHORT_DESC_LIMIT
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 8: Invalid commit message with missing Refs footer
INPUT="feat(Database): Add database migration script"
EXPECTED_OUTPUT=$INVALID_REFS_ID
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 9: Invalid commit message with an unrecognized scope
INPUT="fix(Network): Fix connectivity issue

Refs: #CU-77777"
EXPECTED_OUTPUT=$INVALID_COMMIT_SCOPE
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 10: Commit message with multiple line breaks in body
INPUT="chore(Backend): Update testing framework

Updated the testing framework to the latest version. This ensures compatibility with the new codebase.

Refs: #CU-12345"
EXPECTED_OUTPUT=$SUCCESS_MSG
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

INPUT="fix(@PI): Incorrect scope formatting

Refs: #CU-12345"
EXPECTED_OUTPUT=$INVALID_COMMIT_SCOPE
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"


INPUT=""
EXPECTED_OUTPUT=$EMPTY_MSG
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"


INPUT="feat(API): Add new API endpoint

Updated API to handle user data more efficiently.
Footer without Refs"
EXPECTED_OUTPUT=$INVALID_REFS_ID
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"



INPUT="chore(Backend): Update testing framework

Updated the testing framework to the latest version. This ensures compatibility with the new codebase.

Refs: #CU-12345"
EXPECTED_OUTPUT=$SUCCESS_MSG
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 11: Commit message with a long multiline description exceeding the allowed character limit
INPUT="fix(Authentication): Fix multiple login issues. This update addresses multiple login-related issues, including: Fixing the broken redirect flow after login, Resolving the issue where users were not able to access their profiles after logging in

- Resolving the issue where users were not able to access their profiles after logging in
- Improving the performance of the login API to handle higher traffic loads

The fix also ensures that any edge cases related to user authentication and session management are covered.

Refs: #CU-123456"
EXPECTED_OUTPUT=$SHORT_DESC_LIMIT
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 12: Commit message with a valid multiline description
INPUT="feat(UI): Enhance user profile page

The profile page has been enhanced to include the following changes:
- Added a new section for displaying user achievements
- Improved the layout of the profile details
- Added interactive elements for better user engagement

These updates aim to make the profile page more visually appealing and user-friendly.

Refs: #CU-654321"


EXPECTED_OUTPUT=$SUCCESS_MSG
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"


# Test 13: Commit message with multiple paragraphs in the description
INPUT="docs(Readme): Update README for new API features

Updated the README to include documentation for the newly added features in the API.

The API now supports additional endpoints for managing user permissions, with improved error handling for invalid requests. Please refer to the updated section for detailed information on each endpoint.

Refs: #CU-987654"
EXPECTED_OUTPUT=$SUCCESS_MSG
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 14: Commit message with a description section that exceeds the limit
INPUT="fix(Dashboard): Fix chart rendering issue. The chart rendering on the dashboard had an issue where data points were not displayed correctly, especially for larger datasets. 
The issue was caused by a bug in the data-fetching logic, which resulted in incomplete data being sent to the frontend. The fix ensures that all data is fetched correctly, and the chart now renders without any errors or missing data points.

Refs: #CU-192837"
EXPECTED_OUTPUT=$SHORT_DESC_LIMIT
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"


# Test 15: Commit message with a short description and long body
INPUT="fix(UI): Fix layout bug

The layout bug on the settings page was causing the page to display incorrectly on smaller screens. After identifying the root cause, we applied several fixes to ensure that the layout adapts properly on all screen sizes, including mobile and tablet views.

This fix is part of the ongoing effort to improve the user experience across all platforms, ensuring that the app remains usable regardless of the screen size.

Refs: #CU-564738"
EXPECTED_OUTPUT=$SUCCESS_MSG
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"


# Test 16: Commit message with a valid structure but missing Refs footer
INPUT="chore(Tools): Update build tools

The build tools were updated to ensure compatibility with the latest version of the build system. Several deprecated tools were removed from the build pipeline, and new tools were added to improve the build speed and stability.

This update should result in faster build times and fewer issues during the build process in future releases.

"
EXPECTED_OUTPUT=$INVALID_REFS_ID
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Add more tests as needed...
