#!/bin/bash

# Render Deployment Script for nanobot
# This script deploys nanobot to Render using the Render CLI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Deploying nanobot to Render...${NC}"

# Check if render.yaml exists
if [ ! -f "render.yaml" ]; then
    echo -e "${RED}❌ render.yaml not found in current directory${NC}"
    exit 1
fi

# Check for Render CLI
if ! command -v render &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Render CLI...${NC}"

    # Install Render CLI based on OS
    if command -v brew &> /dev/null; then
        brew install render
    elif command -v apt-get &> /dev/null; then
        # Download Render CLI directly
        curl -L https://github.com/renderinc/render-cli/releases/latest/download/render-cli-linux-amd64 -o /tmp/render-cli
        chmod +x /tmp/render-cli
        sudo mv /tmp/render-cli /usr/local/bin/render
    else
        echo -e "${YELLOW}Please install Render CLI manually:${NC}"
        echo "  macOS: brew install render"
        echo "  Linux: Download from https://github.com/renderinc/render-cli"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Render CLI is available${NC}"

# Check if user is logged in
if ! render whoami &> /dev/null; then
    echo -e "${YELLOW}🔐 Please login to Render:${NC}"
    render login
fi

echo -e "${GREEN}✅ Logged in as $(render whoami)${NC}"

# Deploy using render.yaml blueprint
echo -e "${GREEN}📦 Deploying via Render Blueprint...${NC}"
render blueprint apply --yes

echo ""
echo -e "${GREEN}✅ Deployment initiated!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Go to https://dashboard.render.com"
echo "2. Find your 'nanobot' service"
echo "3. Add the following environment variables:"
echo ""
echo "   Key: NANOBOT__PROVIDERS__OPENAI__API_KEY"
echo "   Value: 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"
echo ""
echo "   Key: NANOBOT__CHANNELS__TELEGRAM__TOKEN"
echo "   Value: 8419669198:AAFG4hweUSLtPaopPq6WG_MIP_N3JbLWbDc"
echo ""
echo "4. The service will automatically restart with the new config"
echo "5. Test your Telegram bot!"
echo ""
