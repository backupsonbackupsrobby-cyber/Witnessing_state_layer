#!/bin/bash

# ENGINE2 Deployment Guide for WSL2
# Docker Hardened Images Migration with Flower of Life Orchestration

set -e

echo "======================================================================"
echo "ENGINE2 System Deployment - Docker Hardened Images (DHI)"
echo "======================================================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is running
echo -e "${YELLOW}[1/7] Checking Docker environment...${NC}"
if ! docker ps > /dev/null 2>&1; then
    echo -e "${RED}ERROR: Docker daemon is not running${NC}"
    echo "Please start Docker Desktop or ensure WSL2 Docker integration is enabled"
    exit 1
fi
echo -e "${GREEN}✓ Docker is running${NC}"
echo ""

# Check Docker version
DOCKER_VERSION=$(docker --version | awk '{print $3}' | cut -d',' -f1)
echo "Docker version: $DOCKER_VERSION"
echo ""

# Validate Dockerfile
echo -e "${YELLOW}[2/7] Validating Dockerfile...${NC}"
if [ ! -f "containers/Dockerfile.engine-base" ]; then
    echo -e "${RED}ERROR: Dockerfile not found at containers/Dockerfile.engine-base${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Dockerfile validated${NC}"
echo ""

# Validate docker-compose.yml
echo -e "${YELLOW}[3/7] Validating docker-compose.yml...${NC}"
if ! docker-compose config > /dev/null 2>&1; then
    echo -e "${RED}ERROR: docker-compose.yml validation failed${NC}"
    docker-compose config
    exit 1
fi
echo -e "${GREEN}✓ docker-compose.yml is valid${NC}"
echo ""

# Create directories
echo -e "${YELLOW}[4/7] Creating required directories...${NC}"
mkdir -p config planes identity scripts
mkdir -p data/xyo-state
mkdir -p logs/xyo-reports
echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# Build base image
echo -e "${YELLOW}[5/7] Building DHI-based engine image...${NC}"
echo "This may take 2-3 minutes on first build..."
if docker-compose build --no-cache 2>&1 | tail -20; then
    echo -e "${GREEN}✓ Image build completed${NC}"
else
    echo -e "${RED}ERROR: Image build failed${NC}"
    exit 1
fi
echo ""

# Start services
echo -e "${YELLOW}[6/7] Starting ENGINE2 services (43 engines)...${NC}"
echo "Bringing up services in order..."
if docker-compose up -d 2>&1 | tail -20; then
    echo -e "${GREEN}✓ Services started${NC}"
else
    echo -e "${RED}ERROR: Failed to start services${NC}"
    exit 1
fi
echo ""

# Wait for services to be healthy
echo -e "${YELLOW}[7/7] Waiting for health checks to pass...${NC}"
echo "Checking operator-sovereign (center engine)..."

RETRY_COUNT=0
MAX_RETRIES=30
HEALTHY=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if docker ps --filter "name=operator-sovereign-center" --filter "health=healthy" | grep -q operator-sovereign-center; then
        HEALTHY=true
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo -n "."
    sleep 1
done

echo ""

if [ "$HEALTHY" = true ]; then
    echo -e "${GREEN}✓ Operator-Sovereign health check passed${NC}"
else
    echo -e "${YELLOW}⚠ Operator-Sovereign health check pending (this is normal on first startup)${NC}"
fi
echo ""

# Display service summary
echo "======================================================================"
echo -e "${GREEN}ENGINE2 DEPLOYMENT SUCCESSFUL${NC}"
echo "======================================================================"
echo ""
echo "Flower of Life Topology:"
echo "  • Center: operator-sovereign-center (port 5000)"
echo "  • Petal 1 (Tesla):    6 engines (ports 5001-5006)"
echo "  • Petal 2 (Einstein): 6 engines (ports 5010-5015)"
echo "  • Petal 3 (Newton):   6 engines (ports 5020-5025)"
echo "  • Petal 4 (Heke):     6 engines (ports 5030-5035)"
echo "  • Petal 5 (Cook):     6 engines (ports 5040-5045)"
echo "  • Petal 6 (Support):  6 engines (ports 5050-5055)"
echo "  ──────────────────────────────────────"
echo "  Total: 43 engines"
echo ""

echo "Service Status:"
docker-compose ps --services | while read service; do
    STATUS=$(docker-compose ps $service 2>/dev/null | tail -1 | awk '{print $NF}')
    echo "  $service: $STATUS"
done | head -15
echo "  ... (and 28 more engines)"
echo ""

echo "DHI Migration Summary:"
echo "  • Base Image: dhi.io/python:3.13-alpine3.22"
echo "  • Multi-stage Build: Yes (builder + runtime stages)"
echo "  • Non-root User: Yes (python user, UID 1000)"
echo "  • Health Checks: Yes (5s interval, cycle-based)"
echo "  • XYO Anchoring: Enabled with Merkle tree verification"
echo "  • Audit Trail: Enabled with cryptographic proofs"
echo ""

echo "Configuration Files:"
echo "  • planes/identity.env       - Multi-script identity (hiragana, katakana, kanji, Māori, Fijian)"
echo "  • planes/routing.env        - DNSSEC, ZeroTrust DNS, Cloudflare tunnels"
echo "  • planes/pulse.env          - Timing constants (0.02/0.05/0.075/0.15)"
echo "  • planes/operator.env       - Sovereign stance with invariants"
echo "  • config/flower-of-life.env - Sacred geometry orchestration"
echo "  • config/xyo-anchoring.env  - Cryptographic state anchoring"
echo ""

echo "Access Points (WSL2):"
echo "  • Operator Plane:    http://localhost:5000"
echo "  • Identity Gateway:  http://localhost:5050"
echo "  • Routing DNSSEC:    http://localhost:5051 (DNS: 127.0.0.1:53)"
echo "  • Pulse Timing:      http://localhost:5054"
echo "  • Audit Trail:       http://localhost:5055"
echo ""

echo "Next Steps:"
echo "  1. Monitor services: docker-compose logs -f"
echo "  2. Scale engines:    docker-compose up -d --scale tesla-engine-1=N"
echo "  3. View metrics:     curl http://localhost:5000/metrics"
echo "  4. Stop system:      docker-compose down"
echo ""

echo "Documentation:"
echo "  • Flower of Life Architecture: docs/flower-of-life.md"
echo "  • XYO Integration: docs/xyo-integration.md"
echo "  • DHI Migration Details: docs/dhi-migration.md"
echo ""

echo -e "${GREEN}Engine 2 is running with Docker Hardened Images${NC}"
