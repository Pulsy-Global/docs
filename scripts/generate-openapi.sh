#!/usr/bin/env bash
set -euo pipefail

API_URL="${1:-https://api.pulsy.app}"
OUTPUT="${2:-xflow/api-reference/openapi.json}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMP_FILE="$(mktemp)"

cleanup() {
  rm -f "${TMP_FILE}"
}
trap cleanup EXIT

curl -fsSL "${API_URL}/swagger/ExternalAPI/swagger.json" -o "${TMP_FILE}"

python3 - "${TMP_FILE}" "${REPO_ROOT}/${OUTPUT}" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    spec = json.load(f)

spec["servers"] = [
    {
        "url": "https://api.pulsy.app",
        "description": "XFlow Production API",
    }
]

with open(sys.argv[2], "w") as f:
    json.dump(spec, f, indent=2)
    f.write("\n")
PY

echo "Generated ${OUTPUT} from ${API_URL}"
