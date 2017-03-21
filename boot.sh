#!/bin/sh

# hubot module to load
echo [\"hubot-redis-brain\"] > external-scripts.json

# SLACK
export HUBOT_SLACK_TOKEN=xoxb-152882513120-WmQsCFJDGUI5P40XaaG7oy8r

# SALT api config
export SALT_API_URL=http://localhost:8000
export SALT_X_TOKEN=$(curl -sS $SALT_API_URL""/login -H 'Accept: application/x-yaml' -d username='testuser' -d password='agadou11' -d eauth='pam' |grep -oP 'token: (\w+)' |awk '{print $2}')

# bot config
export SALT_OUTPUT_CHANNEL=saltstack_log
export SALT_LISTEN=saltstack
export HUBOT_SLACK_CHANNELS="saltstack,saltstack_log"

# Setup environment
set -e
npm install
export PATH="node_modules/.bin:node_modules/hubot/node_modules/.bin:$PATH"

# startup the bot
exec node_modules/.bin/hubot --name "salty" --adapter slack
