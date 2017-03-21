# Description
#   A hubot script for managing salt minions
#
# Configuration:
#   SALT_API_URL - The primary entry point to Salt's REST API
#   SALT_X_TOKEN - A session token from Salt API Login
#   SALT_LISTEN - Channel name where to listen command from
#   SALT_OUTPUT_CHANNEL - Channel name where to send command output
#
# Commands:
#   hubot salt <target> <function> [arguments]
#
# Notes:
#   Salt REST API needs to be up and running
#   <https://docs.saltstack.com/en/latest/ref/netapi/all/salt.netapi.rest_cherrypy.html>

salt_api_url = process.env.SALT_API_URL
salt_token = process.env.SALT_X_TOKEN

saltlog_channel = process.env.SALT_OUTPUT_CHANNEL
salt_listen = process.env.SALT_LISTEN

missingEnvironment = (msg) ->
  missingData = false
  unless salt_api_url?
    msg.send "You need to set SALT_API_URL"
    missingData |= true
  unless salt_token?
    msg.send "You need to set SALT_X_TOKEN"
    missingData |= true
  unless saltlog_channel?
    msg.send "You need to set SALT_OUTPUT_CHANNEL"
    missingData |= true
  unless salt_listen?
    msg.send "You need to set SALT_LISTEN"
    missingData |= true
  missingData

module.exports = (robot) ->

  saltApi = (data, callback) ->
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"
    robot.http(salt_api_url)
      .headers('Content-Type': 'application/json', 'X-Auth-Token': salt_token)
      .post(data) (err, res, body) ->
        if res.statusCode == 401
          callback("Unauthorized Request, This might be a permission issue or the Token is expired.")
        else
          try
            jsonBody = JSON.parse(body)
            textBody = JSON.stringify(jsonBody, null, 2)
            callback(textBody, res)

  robot.hear /^salt\s+([\w-\.\*\']+)\s([\w-.]+)\s*(.*)$/i, (msg) ->
    unless (missingEnvironment msg)
      roomname = robot.adapter.client.rtm.dataStore.getChannelGroupOrDMById msg.message.room
      if roomname.name == salt_listen
        salt_function = msg.match[2].trim()
        salt_target = msg.match[1].trim()
        salt_args = msg.match[3].trim()

        salt_target = salt_target.replace /\'/g, ''
        orgcmd = msg.message.text.replace /@salty /, ''
        msg.send "Executing [#{orgcmd}]. Result sent to  ##{saltlog_channel}"

        tmpdata =
          client: 'local',
          fun: salt_function,
          tgt: salt_target

        if salt_args
          tmpdata['arg'] = salt_args

        saltApi JSON.stringify(tmpdata), (result) ->
          robot.messageRoom '#' + saltlog_channel, '[' + orgcmd + '] triggered by ' + msg.message.user.real_name + '\n' + result

      else
        msg.reply "Nice try.. Command are only allowed from " + salt_listen

  robot.respond /help/, (msg) ->
    msg.reply "salt <target> <function> [arguments]"
