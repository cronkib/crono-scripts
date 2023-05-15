#!/usr/bin/env bash

source "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/configure.sh"

BAT_STATUS=0

SUITE_NAME=""
SUITE_COUNT=0
SUITE_PASS_COUNT=0
SUITE_FAIL_COUNT=0
FAILED_SUITES=()

CASE_WIDTH=30
TEST_INDENT=""
CASE_INDENT="    "
SUMMARY_INDENT="    "

print_divider() {
    echo "__________________________________________________"
}

start_suite() {
    SUITE_NAME="$1"
    SUITE_STATUS=0
    SUITE_COUNT=$((SUITE_COUNT + 1))

    TEST_STATUS=0
    TEST_COUNT=0
    TEST_PASS_COUNT=0
    TEST_FAIL_COUNT=0
    FAILED_TESTS=()

    CASE_PASS_COUNT=0
    CASE_FAIL_COUNT=0

    CASE_DESC=""

    print_divider
    fancy_print -s bold -c yellow "> $SUITE_NAME"
    # fancy_print -s bold " $SUITE_NAME"
    echo ""
}

run_test() {
    TEST_COUNT=$((TEST_COUNT + 1))
    TEST_STATUS=0

    local test_func="$1"
    local name="$2"

    fancy_print -n -s bold -c cyan "Running: "
    fancy_print -s bold "$name"

    "$test_func"

    if [ "$TEST_STATUS" -gt 0 ]; then
        TEST_FAIL_COUNT=$((TEST_FAIL_COUNT + 1))
        FAILED_TESTS+=("${name// /_}")
    else
        TEST_PASS_COUNT=$((TEST_PASS_COUNT + 1))
    fi

    echo ""
}

case_set() {
    CASE_DESC="$@"
}

case_pass() {
    fancy_print -n -s bold -c green "$CASE_INDENT[PASS] "
    fancy_print -s bold "$CASE_DESC"

    CASE_PASS_COUNT=$((CASE_PASS_COUNT + 1))
    return 0
}

case_fail() {
    local extra_notes="$1"

    fancy_print -n -s bold -c red "$CASE_INDENT[FAIL] "
    fancy_print -n -s bold "$CASE_DESC"

    if [[ "$extra_notes" == "" ]]; then
        echo ""
    else
        pack_type_width=${#pack_type}
        name_width=$((6 + pack_type_width))
        notes_indent=$((CASE_WIDTH - name_width))
        spacing=$(printf "%${notes_indent}s")
        echo "$spacing -- $extra_notes"
    fi

    SUITE_STATUS=1
    TEST_STATUS=1
    BAT_STATUS=1

    CASE_FAIL_COUNT=$((CASE_FAIL_COUNT + 1))

    return 1
}

end_suite() {
    # fancy_print -s bold -c magenta "Summary"

    # fancy_print -s bold "    Tests:       $SUITE_TEST_COUNT"

    local pass_color="-c green"
    local fail_color=""

    if [ "$TEST_FAIL_COUNT" -gt 0 ]; then
        fail_color="-c red"
        pass_color=""
    fi

    fancy_print -n -s bold "Total Tests: "
    echo " $TEST_COUNT"

    fancy_print -n -s bold $pass_color "${SUMMARY_INDENT}Passed: "
    echo "  $TEST_PASS_COUNT"

    fancy_print -n -s bold $fail_color "${SUMMARY_INDENT}Failed: "
    echo "  $TEST_FAIL_COUNT"


    if [ "$TEST_FAIL_COUNT" -gt 0 ]; then
        echo "" 
        fancy_print -s bold -s red "Failed Tests:"
        for t in "${FAILED_TESTS[@]}"; do
            echo "${SUMMARY_INDENT}${t//_/ }"
        done | sort
    fi

    echo ""

    if [ "$SUITE_STATUS" -gt 0 ]; then
        BAT_STATUS=1
        SUITE_FAIL_COUNT=$((SUITE_FAIL_COUNT + 1))
        FAILED_SUITES+=("$SUITE_NAME")
    else
        SUITE_PASS_COUNT=$((SUITE_PASS_COUNT + 1))
    fi
    return $SUITE_STATUS
}

bat_summary() {
    local pass_color="-c green"
    local fail_color=""

    print_divider
    fancy_print -s bold -c magenta "> Grand Summary:"
    echo ""

    if [ "$SUITE_FAIL_COUNT" -gt 0 ]; then
        fail_color="-c red"
        pass_color=""
    fi

    fancy_print -n -s bold "Total Suites: "
    echo "$SUITE_COUNT"

    fancy_print -n -s bold $pass_color "${SUMMARY_INDENT}Passed: "
    echo "  $SUITE_PASS_COUNT"

    fancy_print -n -s bold $fail_color "${SUMMARY_INDENT}Failed: "
    echo "  $SUITE_FAIL_COUNT"

    if [ "$SUITE_FAIL_COUNT" -gt 0 ]; then
        echo "" 
        fancy_print -s bold -s red "Failed Suites:"
        for t in "${FAILED_SUITES[@]}"; do
            echo "${SUMMARY_INDENT}${SUMMARY_INDENT}${t//_/ }"
        done | sort
    fi

    echo ""
}