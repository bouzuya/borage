{exec} = require 'child_process'
{Promise} = require 'es6-promise'

class Executor
  execute: (command, options = {}) ->
    # FIXME
    options.maxBuffer = 1024 * 1024 unless options.maxBuffer?
    new Promise (resolve, reject) ->
      exec command, options, (err, stdout, stderr) ->
        return reject(err) if err?
        resolve { stdout, stderr }

module.exports = (command, options = {}) ->
  new Executor().execute(command, options)

module.exports.Executor = Executor
