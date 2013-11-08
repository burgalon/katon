require 'shelljs/global'
shout = require 'shoutjs'
logan = require 'logan'
eco   = require 'eco'

logan.set
  info: ['%', 'green']

# This module is the katon CLI.
# It just creates/removes files, symlinks, etc...
# The daemon will be responsible of starting/stopping apps.
module.exports = 
  # Pow and Katon paths
  powPath: "#{env.HOME}/.pow"
  katonPath: "#{env.HOME}/.katon"
  launchAgentsPath: "#{env.HOME}/Library/LaunchAgents"

  # Link:
  # Creates a pow proxy and a symlink into katon path.
  link: (path = pwd())->
    name = path.split('/').pop()
    shout.to "#{@powPath}/#{name}", "4000"
    shout.mkdir "#{@katonPath}" unless test '-d', "#{@katonPath}"
    shout.exec "ln -s #{path} #{@katonPath}"
    logan.info "Application is now available at http://#{name}.dev"

  # Unlink:
  # Destroys what was created by link.
  unlink: (path = pwd()) ->
    name = path.split('/').pop()
    shout.rm '-f', "#{@powPath}/#{name}", "#{@katonPath}/#{name}"
    logan.info "Successfully removed #{name}"

  # Load:
  # Renders katon.plist.eco with the good env variables and
  # put it in $HOME/Library/LaunchAgents/
  load: ->
    template = cat "#{__dirname}/../plist/katon.plist.eco"
    plistContent = eco.render template,
      nodePath: which 'node'
      daemonPath: "#{__dirname}/../lib/daemon.js"
    shout.to "#{@launchAgentsPath}/katon.plist", plistContent
    shout.exec "launchctl load -Fw #{@launchAgentsPath}/katon.plist"
    logan.info 'Katon daemon was successfully set up'

  # Unload:
  # Removes katon.plist from $HOME/Library/LaunchAgents/
  unload: ->
    shout.exec "launchctl unload #{@launchAgentsPath}/katon.plist"
    shout.rm "#{@launchAgentsPath}/katon.plist"

  installPow: ->
    logan.info 'Installing Pow'
    shout.exec 'curl get.pow.cx | sh'
