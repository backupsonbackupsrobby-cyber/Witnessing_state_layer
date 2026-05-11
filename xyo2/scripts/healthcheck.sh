#!/bin/bash

# ENGINE2 Health Check Script
# Validates Flower of Life cycle completion

set -e

OPERATOR_HOST="${OPERATOR_HOST:-localhost}"
OPERATOR_PORT="${OPERATOR_PORT:-5000}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "ENGINE2 Health Check - Flower of Life Cycle Validation"
echo "======================================================"
echo ""

# Check operator-sovereign
echo -e "${YELLOW}Checking Operator-Sovereign (Center)...${NC}"
if curl -s -f http://${OPERATOR_HOST}:${OPERATOR_PORT}/health > /dev/null; then
    echo -e "${GREEN}✓ Operator-Sovereign is healthy${NC}"
else
    echo -e "${RED}✗ Operator-Sovereign is unhealthy${NC}"
    exit 1
fi
echo ""

# Check petal engines
PETALS=(
    ("Tesla" 5001 5006)
    ("Einstein" 5010 5015)
    ("Newton" 5020 5025)
    ("Heke" 5030 5035)
    ("Cook" 5040 5045)
    ("Support" 5050 5055)
)

HEALTHY_COUNT=0
UNHEALTHY_COUNT=0

for petal_info in "${PETALS[@]}"; do
    IFS=' ' read -r petal_name start_port end_port <<< "$petal_info"
    
    echo -e "${YELLOW}Checking ${petal_name} Petal (ports ${start_port}-${end_port})...${NC}"
    
    for port in $(seq $start_port $end_port); do
        if curl -s -f http://localhost:${port}/health > /dev/null 2>&1; then
            echo -e "${GREEN}  ✓ Port ${port}${NC}"
            HEALTHY_COUNT=$((HEALTHY_COUNT + 1))
        else
            echo -e "${RED}  ✗ Port ${port}${NC}"
            UNHEALTHY_COUNT=$((UNHEALTHY_COUNT + 1))
        fi
    done
    echo ""
done

echo "======================================================"
echo "Health Check Summary:"
echo -e "${GREEN}Healthy Engines: ${HEALTHY_COUNT}${NC}"
echo -e "${RED}Unhealthy Engines: ${UNHEALTHY_COUNT}${NC}"
echo "Total Engines Checked: $((HEALTHY_COUNT + UNHEALTHY_COUNT))"
echo ""

if [ $UNHEALTHY_COUNT -eq 0 ]; then
    echo -e "${GREEN}All engines are healthy!${NC}"
    exit 0
else
    echo -e "${YELLOW}Some engines are still starting. Wait and retry.${NC}"
    exit 1
fi
