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
EXPECTED_OUTPUT="✅ SUCCESS: Your commit message follows the correct format."
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 2: Valid commit message without body
INPUT="fix(Database): Fix DB connection issue

Refs: #CU-67890"
EXPECTED_OUTPUT="✅ SUCCESS: Your commit message follows the correct format."
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 3: Valid commit message with long description
INPUT="chore(Backend): Update dependencies

Updated all project dependencies to the latest versions to ensure compatibility with the new security patch and improve performance.

Refs: #CU-112233"
EXPECTED_OUTPUT="✅ SUCCESS: Your commit message follows the correct format."
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 4: Invalid commit message with missing scope
INPUT="feat: Add new feature

Refs: #CU-98765"
EXPECTED_OUTPUT="❌ ERROR: Commit message does not follow the required format."
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 5: Invalid commit message with unrecognized type
INPUT="wip(API): Work in progress on API endpoint

Refs: #CU-54321"
EXPECTED_OUTPUT="❌ ERROR: Commit message does not follow the required format."
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 6: Valid commit message with correct footer format
INPUT="fix(API): Fix bug in API response

Refs: #12345"
EXPECTED_OUTPUT="✅ SUCCESS: Your commit message follows the correct format."
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 7: Commit message with description exceeding character limit
INPUT="fix(Authentication): This is an excessively long description that should fail validation because it exceeds the character limit allowed for commit messages by the script's standards

Refs: #CU-99999"
EXPECTED_OUTPUT="❌ ERROR: Short description exceeds limit characters."
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 8: Invalid commit message with missing Refs footer
INPUT="feat(Database): Add database migration script"
EXPECTED_OUTPUT="❌ ERROR: Commit message does not follow the required format."
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 9: Invalid commit message with an unrecognized scope
INPUT="fix(Network): Fix connectivity issue

Refs: #CU-77777"
EXPECTED_OUTPUT="❌ ERROR: Commit message does not follow the required format."
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Test 10: Commit message with multiple line breaks in body
INPUT="chore(Backend): Update testing framework

Updated the testing framework to the latest version. This ensures compatibility with the new codebase.

Refs: #CU-12345"
EXPECTED_OUTPUT="✅ SUCCESS: Your commit message follows the correct format."
EXPECTED_EXIT_CODE="0"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

INPUT="fix(@PI): Incorrect scope formatting

Refs: #CU-12345"
EXPECTED_OUTPUT="❌ ERROR: Commit message does not follow the required format."
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"


INPUT=""
EXPECTED_OUTPUT="❌ ERROR: Commit message is empty."
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"


INPUT="feat(API): Add new API endpoint

Updated API to handle user data more efficiently.
Footer without Refs"
EXPECTED_OUTPUT="❌ ERROR: Commit message does not follow the required format."
EXPECTED_EXIT_CODE="1"
run_test "$INPUT" "$EXPECTED_OUTPUT" "$EXPECTED_EXIT_CODE"

# Add more tests as needed...
