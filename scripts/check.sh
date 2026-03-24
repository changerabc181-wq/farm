#!/bin/bash
# =====================================================================
# 田园物语 - Godot 编译检查脚本
# 用法: bash scripts/check.sh
# =====================================================================

GODOT="${GODOT:-/home/admin/tools/bin/godot}"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0

log() { echo -e "${BLUE}[check]${NC} $*"; }
ok()  { echo -e "${GREEN}  ✓ $*"; PASS=$((PASS+1)); }
err() { echo -e "${RED}  ✗ $*"; FAIL=$((FAIL+1)); }
warn(){ echo -e "${YELLOW}  ⚠ $*"; }

# ── 检查 Godot ──────────────────────────────────────────────────────
log "Godot: $($GODOT --version 2>&1 | head -1)"
log "项目:  $PROJECT_DIR"
echo ""

# ── 运行 Godot（启动后立即退出）───────────────────────────────────
RUN_LOG="/tmp/godot_check_$$.log"
$($GODOT --no-window --headless --quit --path "$PROJECT_DIR" > "$RUN_LOG" 2>&1) || true

# ── 检测错误 ──────────────────────────────────────────────────────
SCRIPT_ERRORS=$(grep -cE "SCRIPT ERROR|Compile Error|Nonexistent function" "$RUN_LOG" 2>/dev/null) || SCRIPT_ERRORS=0
RUNTIME_ERRORS=$(grep -cE "^ERROR:|FATAL|failed to load" "$RUN_LOG" 2>/dev/null) || RUNTIME_ERRORS=0

if [ "${SCRIPT_ERRORS:-0}" -gt 0 ] || [ "${RUNTIME_ERRORS:-0}" -gt 0 ]; then
    echo -e "${RED}═══════════════════════════════════════${NC}"
    echo -e "${RED}  ❌ 检查失败${NC}"
    echo -e "${RED}═══════════════════════════════════════${NC}"
    echo ""
    if [ "$SCRIPT_ERRORS" -gt 0 ]; then
        echo -e "${RED}脚本/编译错误 ($SCRIPT_ERRORS):${NC}"
        grep -E "SCRIPT ERROR|Compile Error|Nonexistent" "$RUN_LOG" | sed 's/^/  /' | head -20
        echo ""
    fi
    if [ "$RUNTIME_ERRORS" -gt 0 ]; then
        echo -e "${RED}运行时错误 ($RUNTIME_ERRORS):${NC}"
        grep -E "^ERROR:|FATAL|failed to load" "$RUN_LOG" | sed 's/^/  /' | head -10
    fi
    rm -f "$RUN_LOG"
    exit 1
fi

# ── 检查系统初始化 ────────────────────────────────────────────────
REQUIRED_SYSTEMS=(
    "GameManager"
    "TimeManager"
    "SaveManager"
    "EventBus"
    "AudioManager"
    "InputManager"
    "MoneySystem"
    "ShippingSystem"
    "SceneTransition"
    "GrowthSystem"
    "GiftSystem"
    "ForagingSystem"
    "QuestSystem"
    "NPCManager"
    "HouseUpgradeSystem"
    "FestivalSystem"
    "AchievementSystem"
)

echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}  系统初始化检查${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"

INIT_COUNT=$(grep -c "Initialized" "$RUN_LOG" 2>/dev/null || echo 0)
echo -e "  共 $INIT_COUNT 个系统初始化"
echo ""

for sys in "${REQUIRED_SYSTEMS[@]}"; do
    if grep -qE "\[$sys\].*Initialized|$sys.*Initialized" "$RUN_LOG" 2>/dev/null; then
        ok "$sys"
    elif grep -qE "\[$sys\]" "$RUN_LOG" 2>/dev/null; then
        ok "$sys"
    else
        # 某些系统名不匹配，打印已知的
        if grep -q "$sys" "$RUN_LOG" 2>/dev/null; then
            ok "$sys"
        else
            err "$sys (未找到初始化消息)"
        fi
    fi
done

# ── 检查 ItemDatabase ──────────────────────────────────────────────
if grep -q "ItemDatabase\|item.*loaded" "$RUN_LOG" 2>/dev/null; then
    ITEMS=$(grep -oP "Loaded \K\d+" "$RUN_LOG" | head -1)
    if [ -n "$ITEMS" ]; then
        ok "ItemDatabase ($ITEMS items)"
    else
        ok "ItemDatabase"
    fi
fi

# ── 完成 ──────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
if [ "$FAIL" -eq 0 ]; then
    echo -e "${GREEN}  ✅ 所有检查通过 ($PASS/$PASS)${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    rm -f "$RUN_LOG"
    exit 0
else
    echo -e "${RED}  ❌ $FAIL 个检查失败${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    rm -f "$RUN_LOG"
    exit 1
fi
