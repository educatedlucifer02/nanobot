# Deploy nanobot to Render

## Option 1: One-Click Deploy (Recommended)

Click this link to deploy directly to Render:

**[Deploy to Render](https://dashboard.render.com/blueprints/connect?repo=https://github.com/educatedlucifer02/nanobot)**

## Option 2: Manual Deployment

### Step 1: Go to Render Dashboard
Visit: https://dashboard.render.com

### Step 2: Create Blueprint
1. Click **"New"** → **"Blueprint"**
2. Connect your GitHub: `educatedlucifer02/nanobot`
3. Render will detect `render.yaml`
4. Click **"Apply"**

### Step 3: Configure Environment Variables
Add these in your Render service → **Environment Variables**:

| Key | Value |
|-----|-------|
| `NANOBOT__PROVIDERS__OPENAI__API_KEY` | `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` |
| `NANOBOT__CHANNELS__TELEGRAM__TOKEN` | `8419669198:AAFG4hweUSLtPaopPq6WG_MIP_N3JbLWbDc` |
| `NANOBOT__PROVIDERS__OPENAI__API_BASE` | `https://integrate.api.nvidia.com/v1` |
| `NANOBOT__AGENTS__DEFAULTS__MODEL` | `minimaxai/minimax-m2.1` |
| `NANOBOT__CHANNELS__TELEGRAM__ENABLED` | `true` |

### Step 4: Verify Deployment
1. Check **Logs** tab for startup messages
2. Look for: `✓ Channels enabled: telegram`
3. Start chatting with your Telegram bot!

## Current Configuration
- **Model**: MiniMax M2.1 via NVIDIA API
- **Channel**: Telegram (enabled)
- **Port**: 18790

## Troubleshooting
- If deployment fails, check logs for error messages
- Ensure API keys are correct
- Restart service after adding environment variables

## Testing Your Bot
1. Open Telegram and search for your bot username
2. Send `/start` or any message
3. Bot should respond using MiniMax M2.1 model
