#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <project-directory>"
  exit 1
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: required dependency '$1' is not installed."
    exit 2
  fi
}

PASS_COUNT=0
SKIP_COUNT=0
FAIL_COUNT=0

check() {
  local name="$1"
  local condition="$2"
  local skip_condition="${3:-}"

  if [[ -n "$skip_condition" ]] && eval "$skip_condition"; then
    echo "⏭️  SKIP ${name}"
    SKIP_COUNT=$((SKIP_COUNT + 1))
    return
  fi

  if eval "$condition"; then
    echo "✅ PASS ${name}"
    PASS_COUNT=$((PASS_COUNT + 1))
    return
  fi

  echo "❌ FAIL ${name}"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

if [[ $# -ne 1 ]]; then
  usage
fi

TARGET_DIR="$1"
if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "ERROR: directory '${TARGET_DIR}' does not exist."
  exit 1
fi

require_command jq
require_command curl

TARGET_DIR="$(cd "${TARGET_DIR}" && pwd)"

check "package.json has authors and engine fields" "jq -e '.author and (.engines.node // .volta.node // empty)' '${TARGET_DIR}/package.json' >/dev/null 2>&1" "[[ ! -f '${TARGET_DIR}/package.json' ]]"

check "Dockerfile uses DHI images" "grep -Eiq '^(FROM|FROM\\s+--platform=.+)\\s+.*dhi' '${TARGET_DIR}/Dockerfile'" "[[ ! -f '${TARGET_DIR}/Dockerfile' ]]"

check "SonarQube config exists" "[[ -f '${TARGET_DIR}/sonar-project.properties' ]]"

check "next.config.ts defines headers()" "grep -Eq 'headers\s*\(' '${TARGET_DIR}/next.config.ts'" "[[ ! -f '${TARGET_DIR}/next.config.ts' ]]"

check ".dockerignore exists" "[[ -f '${TARGET_DIR}/.dockerignore' ]]"

check ".husky/pre-commit exists" "[[ -f '${TARGET_DIR}/.husky/pre-commit' ]]"

check "README follows template (more than 4 lines)" "[[ \$(wc -l < '${TARGET_DIR}/README.md') -gt 4 ]]" "[[ ! -f '${TARGET_DIR}/README.md' ]]"

PIPELINE_CHECK=1
if [[ -d "${TARGET_DIR}/.github/workflows" ]]; then
  workflow_files=("${TARGET_DIR}/.github/workflows"/*)
  if [[ ${#workflow_files[@]} -gt 0 ]]; then
    latest_release_json="$(curl -fsSL https://api.github.com/repos/soulsbros/CICD-template/releases/latest 2>/dev/null || true)"
    latest_release_tag="$(printf '%s' "$latest_release_json" | jq -r '.tag_name // empty' 2>/dev/null || true)"
    if [[ -n "$latest_release_tag" ]]; then
      release_comment_version="${latest_release_tag#v}"
      if grep -R -nE "soulsbros/CICD-template/\.github/workflows/[^[:space:]]+@[^[:space:]]+ # ${release_comment_version}" "${TARGET_DIR}/.github/workflows" >/dev/null 2>&1; then
        PIPELINE_CHECK=0
      fi
    fi
  fi
fi

check "GitHub Actions uses latest CICD-template release (${latest_release_tag})" "[[ $PIPELINE_CHECK -eq 0 ]]" "[[ ! -d '${TARGET_DIR}/.github/workflows' ]]"

check "src/app/layout.tsx has metadata fields" "grep -Eq 'description\s*:' '${TARGET_DIR}/src/app/layout.tsx' && grep -Eq 'authors\s*:' '${TARGET_DIR}/src/app/layout.tsx'" "[[ ! -f '${TARGET_DIR}/src/app/layout.tsx' ]]"

check "src/app has error.tsx, not-found.tsx, and loading.tsx" "[[ -f '${TARGET_DIR}/src/app/error.tsx' ]] && [[ -f '${TARGET_DIR}/src/app/not-found.tsx' ]] && [[ -f '${TARGET_DIR}/src/app/loading.tsx' ]]" "[[ ! -d '${TARGET_DIR}/src/app' ]]"

echo
echo "Summary: ${PASS_COUNT} passed, ${SKIP_COUNT} skipped, ${FAIL_COUNT} failed"

if [[ $FAIL_COUNT -eq 0 ]]; then
  exit 0
fi

exit 1
