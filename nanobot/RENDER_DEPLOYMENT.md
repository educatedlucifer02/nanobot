# Deploying nanobot on Render

This guide provides step-by-step instructions for deploying nanobot on Render as a Background Service. Render is an excellent platform for running long-running processes like a bot, offering automatic restarts, environment variable management, and seamless scaling options.

## Overview

Nanobot is an ultra-lightweight personal AI assistant that runs as a long-running gateway process, connecting to various chat platforms like Telegram, WhatsApp, and Feishu. On Render, we deploy this as a **Background Service** (worker) rather than a web service, since the application doesn't need to respond to HTTP requests but instead maintains persistent connections to messaging platforms.

The deployment consists of a single worker service that runs the `nanobot gateway` command, along with environment variables for configuration. Render's environment variable system supports nested configuration through double underscore notation, which maps directly to nanobot's Pydantic settings structure.

## Prerequisites

Before starting the deployment process, ensure you have the following prerequisites in place. First, you need a Render account, which you can create by visiting [render.com](https://render.com) and signing up using your GitHub account for seamless integration. Second, depending on which chat platforms you want to enable, you'll need the respective API credentials. For Telegram, you'll need a bot token from BotFather; for WhatsApp, you'll need a Meta developer account and WhatsApp Business API credentials; and for Feishu, you'll need an app ID and app secret from the Feishu Open Platform.

Additionally, you'll need an LLM API key from a supported provider. The recommended options include OpenRouter (which provides access to multiple models including Claude and GPT), Anthropic (for direct Claude access), OpenAI (for GPT models), or DeepSeek (for cost-effective reasoning models). Finally, if you plan to enable web search functionality, you'll need a Brave Search API key from [brave.com/search/api](https://brave.com/search/api/).

## Deployment Steps

### Step 1: Prepare Your Repository

Begin by forking or cloning the nanobot repository to your GitHub account. Render will need access to your repository to build and deploy the application. The repository already contains the necessary configuration files including `render.yaml` and `Procfile` for Render deployment.

If you haven't already, clone the repository and push it to your GitHub account:

```bash
git clone https://github.com/HKUDS/nanobot.git
cd nanobot
# Make any customizations if needed
git remote set-url origin your-github-repo-url
git add .
git commit -m "Prepare for Render deployment"
git push origin main
```

### Step 2: Create a New Web Service on Render

Navigate to the Render dashboard and click the "New" button in the top-right corner. From the dropdown menu, select "Web Service" (we'll configure it as a worker later). Connect your GitHub repository by clicking "Connect" next to your nanobot fork. Render will analyze your repository and detect the Python application.

In the configuration page that appears, set the following values. For the name, enter "nanobot" or your preferred service name. For the region, select the region closest to your primary users or where your chat platform webhooks perform best. For the branch, keep "main" or your default branch. For the build command, enter `pip install -e .` which will install nanobot in editable mode along with all dependencies defined in `pyproject.toml`. For the start command, enter `nanobot gateway` which launches the bot gateway process.

### Step 3: Configure as a Background Service

After creating the web service, go to the "Advanced" section at the bottom of the configuration page. Change the service type from "Web Service" to "Background Service". This is crucial because nanobot is a long-running process that maintains persistent connections to messaging platforms, not a traditional HTTP server that responds to requests.

Background services on Render automatically restart if they crash or if the underlying instance needs to be replaced. They also support health checks and graceful shutdown, which are essential for a bot that may be in the middle of processing messages.

### Step 4: Configure Environment Variables

Environment variables are the primary method for configuring nanobot on Render, since the service runs in an isolated container without access to your local filesystem where the config file would normally reside. Render's environment variable system supports nested configuration through double underscore notation, which maps directly to nanobot's Pydantic settings structure.

Add the following environment variables in the Render dashboard under the "Environment Variables" section:

**Core Configuration (Required):**

```
NANOBOT__PROVIDERS__OPENROUTER__API_KEY=your_openrouter_api_key
NANOBOT__PROVIDERS__OPENROUTER__API_BASE=https://openrouter.ai/api/v1
NANOBOT__AGENTS__DEFAULTS__MODEL=anthropic/claude-opus-4-5
```

**Telegram Channel (Optional):**

```
NANOBOT__CHANNELS__TELEGRAM__ENABLED=true
NANOBOT__CHANNELS__TELEGRAM__TOKEN=your_telegram_bot_token
NANOBOT__CHANNELS__TELEGRAM__ALLOW_FROM=["123456789", "@username"]
```

**WhatsApp Channel (Optional):**

```
NANOBOT__CHANNELS__WHATSAPP__ENABLED=true
NANOBOT__CHANNELS__WHATSAPP__BRIDGE_URL=wss://your-bridge-url.com
NANOBOT__CHANNELS__WHATSAPP__ALLOW_FROM=["+1234567890"]
```

**Feishu Channel (Optional):**

```
NANOBOT__CHANNELS__FEISHU__ENABLED=true
NANOBOT__CHANNELS__FEISHU__APP_ID=your_feishu_app_id
NANOBOT__CHANNELS__FEISHU__APP_SECRET=your_feishu_app_secret
NANOBOT__CHANNELS__FEISHU__ENCRYPT_KEY=your_encrypt_key
NANOBOT__CHANNELS__FEISHU__VERIFICATION_TOKEN=your_verification_token
```

**Web Search (Optional):**

```
NANOBOT__TOOLS__WEB__SEARCH__API_KEY=your_brave_search_api_key
NANOBOT__TOOLS__WEB__SEARCH__MAX_RESULTS=5
```

**Advanced Options:**

```
NANOBOT__AGENTS__DEFAULTS__MAX_TOOL_ITERATIONS=20
NANOBOT__AGENTS__DEFAULTS__TEMPERATURE=0.7
NANOBOT__GATEWAY__PORT=18790
```

The double underscore notation maps to nested configuration as follows: `NANOBOT__PROVIDERS__OPENROUTER__API_KEY` becomes `providers.openrouter.api_key` in the JSON configuration format. This mapping allows you to configure any option available in nanobot's configuration schema using environment variables.

### Step 5: Configure Persistent Storage (Optional)

If you want nanobot to persist data like cron jobs, memory files, and workspace data across deployments, you can attach a Render Disk. This is useful for maintaining conversation context, scheduled tasks, and other stateful information.

To add persistent storage, scroll down to the "Disks" section in the Render configuration and add a new disk with the following settings: name the disk "nanobot-data", allocate the desired storage size (the minimum is 1GB for free plans), and set the mount path to `/var/data`. Then update your environment variable:

```
NANOBOT__AGENTS__DEFAULTS__WORKSPACE=/var/data/.nanobot/workspace
```

This ensures that all persistent data is stored on the mounted disk rather than the ephemeral container filesystem.

### Step 6: Deploy and Monitor

Click "Create Web Service" (or "Create Background Service") to begin the deployment process. Render will clone your repository, install dependencies, and start the nanobot gateway. You can monitor the build process in the Render dashboard, where you'll see live logs showing the installation progress and startup messages.

Once the service is running, you should see output similar to:

```
   nanobot v0.1.3.post4
   Starting nanobot gateway on port 18790...
   ✓ Channels enabled: telegram
   ✓ Cron: 0 scheduled jobs
   ✓ Heartbeat: every 30m
```

If you encounter errors, check the logs for detailed error messages. Common issues include missing API keys, incorrect environment variable names, or network connectivity problems.

## Channel-Specific Setup

### Telegram Setup

To enable Telegram, you'll need to create a bot and configure it properly. First, open Telegram and search for @BotFather, which is Telegram's official bot for creating and managing bots. Send `/newbot` to BotFather and follow the prompts to give your bot a name and username. Once created, BotFather will provide you with an HTTP API token that looks like `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`.

In your Render environment variables, set `NANOBOT__CHANNELS__TELEGRAM__TOKEN` to this token and `NANOBOT__CHANNELS__TELEGRAM__ENABLED` to `true`. To restrict access to specific users, you can add user IDs or usernames to the `NANOBOT__CHANNELS__TELEGRAM__ALLOW_FROM` array. You can find your Telegram user ID by messaging @userinfobot.

Since Telegram uses webhooks to deliver messages, your bot needs to be accessible from Telegram's servers. Render provides a public URL for background services, which will be used as the webhook endpoint automatically.

### WhatsApp Setup

WhatsApp integration requires additional setup because WhatsApp uses a different authentication model than Telegram. The recommended approach is to use the WhatsApp Business API with a bridge service. You'll need to set up a WhatsApp bridge (such as the one included in nanobot's `bridge/` directory) that connects to your WhatsApp Business account.

For WhatsApp, you have two deployment options. The first option is to run the bridge separately and provide its URL to nanobot. Set `NANOBOT__CHANNELS__WHATSAPP__BRIDGE_URL` to your bridge's WebSocket URL (e.g., `wss://your-bridge.example.com`). The second option is to include the bridge in the same container, but this requires Node.js runtime which adds complexity to the deployment.

Note that for WhatsApp, you'll likely need to keep the QR code authentication active, which means the bridge needs to be accessible for scanning. Consider using a separate service for the WhatsApp bridge if you need to frequently re-authenticate.

### Feishu Setup

Feishu (also known as Lark) uses WebSocket long connections for receiving messages, which is ideal for Render's environment since it doesn't require a public IP or webhook configuration. To set up Feishu, visit the [Feishu Open Platform](https://open.feishu.cn/app) and create a new application. Enable the Bot capability in your app settings, then add the `im:message` permission for sending messages.

For receiving messages, add the `im.message.receive_v1` event subscription. When configuring the event subscription, select "Long Connection" mode rather than webhook mode, as this is what nanobot's Feishu implementation expects. After creating your app, obtain the App ID and App Secret from the "Credentials & Basic Info" section, and publish your app to make it available to users.

Set the following environment variables for Feishu: `NANOBOT__CHANNELS__FEISHU__APP_ID` to your App ID, `NANOBOT__CHANNELS__FEISHU__APP_SECRET` to your App Secret, and `NANOBOT__CHANNELS__FEISHU__ENABLED` to `true`. The `encryptKey` and `verificationToken` are optional for long connection mode.

## Using Render Blueprint

For repeatable deployments, you can use Render's Blueprint feature with the included `render.yaml` file. Blueprint allows you to define your entire infrastructure as code, including services, databases, and environment variables.

To use the Blueprint, go to the Render dashboard, click "New", and select "Blueprint". Connect your GitHub repository containing the `render.yaml` file. Render will parse the blueprint and show you a preview of the resources that will be created. Review the configuration and click "Apply" to deploy.

The included `render.yaml` defines a basic worker service with placeholder values. You'll need to update the environment variables with your actual API keys after deployment. For production use, consider using Render's secret files or environment variable groups to manage sensitive configuration.

## Troubleshooting

### Service Fails to Start

If the service fails to start, check the following common issues. First, verify that all required environment variables are set, particularly `NANOBOT__PROVIDERS__OPENROUTER__API_KEY`. Without an API key, the agent cannot communicate with the LLM and will exit with an error. Second, check that the start command is correct—it should be `nanobot gateway` not `python -m nanobot` or other variations.

Review the logs in the Render dashboard for specific error messages. Common startup errors include missing dependencies (though these should be caught during build), incorrect environment variable names, and port conflicts.

### Channel Not Connecting

If a specific channel (Telegram, WhatsApp, or Feishu) isn't connecting, verify the channel-specific configuration. For Telegram, ensure the bot token is valid and that the bot has been started via @BotFather. For WhatsApp, confirm that the bridge URL is correct and accessible. For Feishu, verify that the app has been published and that the correct permissions have been enabled.

Check the channel status using `nanobot channels status` if you have console access, or review the logs for channel-specific connection messages. Each channel should log its connection status on startup.

### Messages Not Being Processed

If the bot is running but not responding to messages, first verify that the channel is enabled in the environment variables. Then check that the agent has a valid model configured and can communicate with the LLM provider. Network issues between Render and the LLM API can cause timeouts or failures.

The agent also requires a workspace directory for memory and skill files. If `NANOBOT__AGENTS__DEFAULTS__WORKSPACE` points to a directory that doesn't exist and can't be created, the agent may fail silently. Ensure the workspace path is valid and writable.

### Memory and Resource Usage

Nanobot is designed to be ultra-lightweight, but the LLM provider API calls can consume significant memory depending on the model and context length. Monitor your Render service's memory usage in the dashboard. If you experience memory issues, consider reducing `NANOBOT__AGENTS__DEFAULTS__MAX_TOOL_ITERATIONS` or using a smaller model.

Free tier accounts have limited memory and compute, so complex agent operations may time out. For production use with heavy usage, consider upgrading to a paid plan with more resources.

## Updating Your Deployment

When you push changes to your GitHub repository, Render will automatically detect the update and trigger a new deployment. You can also manually trigger a redeploy from the Render dashboard by clicking the "Deploy" button.

For updates that change the `pyproject.toml` dependencies, Render will rebuild the container and reinstall dependencies. This may take a few minutes depending on the number of dependencies.

If you need to roll back to a previous version, you can deploy from a specific Git commit or tag using the Render dashboard's deployment options.

## Security Considerations

When deploying on Render, keep the following security considerations in mind. Never commit API keys or secrets to your GitHub repository—always use Render's environment variables for sensitive configuration. Render encrypts environment variables at rest and in transit, but treat them as sensitive data.

If using Telegram, be aware that Telegram bot tokens provide access to your bot's messages. Don't share your token in public repositories or chat logs. For WhatsApp and Feishu, similarly protect your app credentials and ensure that only authorized users can interact with your bot by using the `allowFrom` configuration.

Consider implementing additional validation for incoming messages if your bot is public-facing. The `allowFrom` setting provides basic access control, but you may want to add more sophisticated validation depending on your use case.

## Advanced Configuration

### Custom Models

You can configure nanobot to use different LLM models by changing the `NANOBOT__AGENTS__DEFAULTS__MODEL` environment variable. Some popular options include:

- `anthropic/claude-opus-4-5` for Claude 4 (high capability, higher cost)
- `anthropic/claude-sonnet-4-5` for Claude 4 Sonnet (balanced capability)
- `anthropic/claude-haiku-4-5` for Claude 4 Haiku (faster, lower cost)
- `openai/gpt-4o` for GPT-4 Omni
- `deepseek/deepseek-chat` for DeepSeek Chat (very cost-effective)
- `minimax/minimax-m2` for MiniMax M2 (ultra-low cost)

Ensure your API key has access to the model you select. OpenRouter provides a unified API for many models, while direct provider keys (Anthropic, OpenAI) only work with that provider's models.

### Custom Skills

Nanobot supports custom skills that extend its capabilities. Skills are Python modules placed in the `nanobot/skills/` directory. To add custom skills, include them in your repository and ensure they're importable. The agent will automatically discover and load available skills at runtime.

### Web Proxy Configuration

If you need to use a proxy for API calls (e.g., for accessing LLM providers from regions with network restrictions), you can configure it using environment variables. For Telegram proxy support, set `NANOBOT__CHANNELS__TELEGRAM__PROXY` to your proxy URL (e.g., `http://127.0.0.1:7890` or `socks5://127.0.0.1:1080`).

## Conclusion

Deploying nanobot on Render provides a reliable, scalable platform for running your personal AI assistant. The combination of Render's infrastructure and nanobot's lightweight design results in a cost-effective solution that can grow with your needs. With support for multiple chat platforms and flexible configuration through environment variables, you can customize nanobot to fit your specific use case.

If you encounter issues not covered in this guide, check the [nanobot GitHub repository](https://github.com/HKUDS/nanobot) for additional documentation, or open an issue for specific problems. The community is active and responsive to questions and feature requests.
