#!/usr/bin/env bash

set -euo pipefail

PROJECT_PATH="$(pwd)"
MAGENTO_PATH="$PROJECT_PATH/magento"
SCANNER_PATH="$PROJECT_PATH/magento-malware-scanner"
VENV_PATH="/tmp/mwscan-venv"

echo "currently in $PROJECT_PATH"

cd "$MAGENTO_PATH"

# Check whether the current Composer version can resolve the project.
if /usr/local/bin/composer install --dry-run --prefer-dist --no-progress >/dev/null 2>&1; then
    COMPOSER_COMPATIBILITY=0
else
    COMPOSER_COMPATIBILITY=$?
fi

echo "Composer compatibility: $COMPOSER_COMPATIBILITY"

if [ "$COMPOSER_COMPATIBILITY" -eq 0 ]; then
    /usr/local/bin/composer install --prefer-dist --no-progress
else
    echo "using composer v1"

    php7.2 /usr/local/bin/composer self-update --1
    /usr/local/bin/composer install --prefer-dist --no-progress
fi

# ---------------------------------------------------------------------------
# Magento malware scanner
#
# The old implementation bootstrapped Python 2.7 using get-pip.py.
# Debian Bookworm provides Python 3, so use an isolated Python 3 virtualenv.
# ---------------------------------------------------------------------------

rm -rf "$VENV_PATH"

python3 -m venv "$VENV_PATH"

# Upgrade packaging tools inside the virtual environment.
"$VENV_PATH/bin/python" -m pip install --upgrade pip setuptools wheel

# Clone the MAD-I-T scanner fork.
rm -rf "$SCANNER_PATH"

git clone --depth 1 \
    https://github.com/seyuf/magento-malware-scanner \
    "$SCANNER_PATH"

cd "$SCANNER_PATH"

# Install the scanner and its declared dependencies.
"$VENV_PATH/bin/python" -m pip install .

cd "$MAGENTO_PATH"

# Make the scanner executable available to the rest of the script.
export PATH="$VENV_PATH/bin:$PATH"

echo "Using Python: $(python --version)"
echo "Using pip: $(python -m pip --version)"
echo "Using mwscan: $(command -v mwscan)"

# Keep the generated file list used by the action.
mwscan --ruleset madit . > /dev/null

# Preserve the scanner installation only for the duration of this process.
rm -rf "$SCANNER_PATH"
