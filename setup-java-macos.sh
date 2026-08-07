#!/bin/bash

# macOS Java Web Start Setup Script for PTT KEP e-imza
# Purpose: Configure Java environment and JNLP file handling

echo ""
echo "========== macOS JAVA WEB START SETUP ==========="
echo "Configuring Java for PTT KEP e-imza"
echo ""

# ===== STEP 1: Detect Java Installation =====
echo "[STEP 1] Detecting Java Installation..."

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "✗ Java NOT found on system"
    echo ""
    echo "Options to install Java on macOS:"
    echo ""
    echo "Option 1: Using Homebrew (Recommended)"
    echo "  1. Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "  2. Then: brew install openjdk@8"
    echo ""
    echo "Option 2: Direct Download"
    echo "  1. Visit: https://www.oracle.com/java/technologies/downloads/#java8"
    echo "  2. Download JDK 8 for macOS"
    echo "  3. Run installer"
    echo ""
    echo "Option 3: Using MacPorts"
    echo "  sudo port install openjdk8"
    echo ""
    echo "After installing, run this script again."
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1)
echo "✓ Java found:"
echo "$JAVA_VERSION"
echo ""

# ===== STEP 2: Find and Set JAVA_HOME =====
echo "[STEP 2] Finding and configuring JAVA_HOME..."

# macOS Java 8 paths
JAVA_HOME=""

# Try various macOS Java locations
if [ -d "/Library/Java/JavaVirtualMachines/jdk1.8.0_231.jdk/Contents/Home" ]; then
    JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_231.jdk/Contents/Home"
elif [ -d "/Library/Java/JavaVirtualMachines/openjdk-8.jdk/Contents/Home" ]; then
    JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk-8.jdk/Contents/Home"
elif [ -d "/usr/libexec/java_home" ]; then
    # Use the built-in /usr/libexec/java_home command
    JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
else
    # Try to find Java location
    JAVA_PATH=$(which java)
    JAVA_HOME=$(dirname "$(dirname "$JAVA_PATH")")
fi

if [ -z "$JAVA_HOME" ] || [ ! -d "$JAVA_HOME" ]; then
    echo "✗ Could not determine JAVA_HOME"
    echo "Try: /usr/libexec/java_home -v 1.8"
    exit 1
fi

echo "✓ JAVA_HOME: $JAVA_HOME"

# ===== STEP 3: Configure Shell Profile =====
echo ""
echo "[STEP 3] Configuring shell environment..."

# Detect shell
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_RC="$HOME/.bash_profile"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -z "$SHELL_RC" ]; then
    echo "✗ Could not find shell configuration file"
    exit 1
fi

echo "Using shell config: $SHELL_RC"

# Add JAVA_HOME to shell profile if not already there
if ! grep -q "JAVA_HOME" "$SHELL_RC"; then
    echo "" >> "$SHELL_RC"
    echo "# Java configuration for PTT KEP" >> "$SHELL_RC"
    echo "export JAVA_HOME=$JAVA_HOME" >> "$SHELL_RC"
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> "$SHELL_RC"
    echo "✓ Added JAVA_HOME to $SHELL_RC"
else
    echo "✓ JAVA_HOME already configured in $SHELL_RC"
fi

# Export for current session
export JAVA_HOME="$JAVA_HOME"
export PATH="$JAVA_HOME/bin:$PATH"

# ===== STEP 4: Find Java Web Start =====
echo ""
echo "[STEP 4] Locating Java Web Start..."

JAVAWS=""
if [ -f "$JAVA_HOME/bin/javaws" ]; then
    JAVAWS="$JAVA_HOME/bin/javaws"
elif command -v javaws &> /dev/null; then
    JAVAWS=$(which javaws)
else
    echo "✗ Java Web Start (javaws) not found"
    echo "You may need to install JDK instead of JRE"
fi

if [ -n "$JAVAWS" ]; then
    echo "✓ Java Web Start found: $JAVAWS"
    echo "✓ Testing javaws..."
    $JAVAWS -version 2>&1 | head -3
fi

# ===== STEP 5: Configure .jnlp File Association =====
echo ""
echo "[STEP 5] Configuring .jnlp file handling..."

# Create a LaunchAgent for .jnlp files (macOS specific)
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$LAUNCH_AGENT_DIR"

# Create a script to handle .jnlp files
JNLP_HANDLER="/usr/local/bin/jnlp-handler"

if [ -n "$JAVAWS" ]; then
    sudo tee "$JNLP_HANDLER" > /dev/null << EOF
#!/bin/bash
$JAVAWS "\$@"
EOF

    sudo chmod +x "$JNLP_HANDLER"
    echo "✓ Created JNLP handler at $JNLP_HANDLER"
fi

# ===== STEP 6: Summary =====
echo ""
echo "========== SETUP COMPLETE ==========="
echo ""
echo "Java Environment Summary:"
echo "  JAVA_HOME: $JAVA_HOME"
echo "  Java Bin: $JAVA_HOME/bin"
echo "  Java Web Start: $JAVAWS"
echo ""

echo "[HOW TO USE WITH PTT KEP]"
echo "1. Open Safari or Chrome browser"
echo "2. Navigate to: https://ptt.hs01.kep.tr"
echo "3. Login to your KEP account"
echo "4. When prompted to download .jnlp file, save it"
echo "5. Double-click the .jnlp file to launch Java Web Start"
echo ""

echo "[MANUAL EXECUTION]"
echo "If double-clicking doesn't work, run in Terminal:"
echo "  $JAVAWS ~/Downloads/yourfile.jnlp"
echo ""

echo "[IMPORTANT: Reload shell configuration]"
echo "Run this in Terminal to apply changes:"
echo "  source $SHELL_RC"
echo ""

echo "[TROUBLESHOOTING]"
echo "If still having issues:"
echo "1. Make sure Java 8 is installed: java -version"
echo "2. Reload shell: source $SHELL_RC"
echo "3. Try: $JAVAWS -version"
echo "4. Restart Terminal application"
echo "5. Check System Preferences > Security & Privacy"
echo ""

echo "Setup complete! You can now use PTT KEP e-imza."
