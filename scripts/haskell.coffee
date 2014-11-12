# Description:
#   Evaluate one line of Haskell
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot haskell <script> - Evaluate one line of Haskell
#
# Author:
#   edwardgeorge, slightly modified from code by jingweno
 
HASKELLJSON=""
 
module.exports = (robot) ->
  robot.hear /(haskell)\s+(.*)/i, (msg)->
    script = msg.match[2]
 
    msg.http("http://tryhaskell.org/eval")
      .query({exp: script})
      .headers(Cookie: "HASKELLJSON=#{HASKELLJSON}")
      .get() (err, res, body) ->
        switch res.statusCode
          when 200
            if res.headers["set-cookie"]
              HASKELLJSON = res.headers["set-cookie"][0].match(/HASKELLJSON=([-a-z0-9]+);/)[1]
            result = JSON.parse(body)
 
            if result.error
              msg.send result.error
            else
              if result.success
                msg.send [
                  "\`\`\`",
                  result.success.stdout.join(''),
                  result.success.value,
                  result.success.type,
                  "\`\`\`"].filter((x) -> x.length > 0).join('\n')
          else
            msg.send "Unable to evaluate script: #{script}. Request returned with the status code: #{res.statusCode}"
