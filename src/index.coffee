{Promise} = require 'es6-promise'
moment = require 'moment'
exec = require './exec'

addAll = ({ directory }) ->
  command = 'git add --all'
  exec command, cwd: directory

clone = ({ branchName, directory, repository }) ->
  command = "git clone --branch #{branchName} #{repository} #{directory}"
  exec command

commit = ({ directory, message }) ->
  command = "git commit --allow-empty --message '#{message}'"
  exec command, cwd: directory

config = ({ directory, name, value }) ->
  command = "git config --local #{name} '#{value}'"
  exec command, cwd: directory

configAll = ({ configs, directory, error, log }) ->
  configs.reduce (promise, { name, value }) ->
    promise
    .then ->
      config { directory, name, value }
    .then ({ stdout, stderr }) ->
      log stdout
      error stderr
      null
  , Promise.resolve()

push = ({ directory, dst, repository, src }) ->
  command = "git push '#{repository}' #{src}:#{dst}"
  exec command, cwd: directory

# options:
#   branchName : branch name       'gh-pages'
#   configs    : configs           [{ name: 'user.name', value: 'bouzuya' }]
#   directory  : working directory 'public'
#   error      : stderr output     console.error.bind(console)
#   log        : stdout output     console.log.bind(console)
#   message    : commit message    moment().format()
#   repository : repository url    'https://github.com/bouzuya/borage'
module.exports = (options) ->
  branchName = options.branchName ? 'gh-pages'
  configs = options.configs ? []
  directory = options.directory ? 'public'
  error = options.error ? console.error.bind(console)
  log = options.log ? console.log.bind(console)
  message = options.message ? moment().format()
  repository = options.repository

  dst = branchName
  src = branchName

  clone { branchName, directory, repository }
  .then ({ stdout, stderr }) ->
    log stdout
    error stderr
  .then ->
    addAll { directory }
  .then ({ stdout, stderr }) ->
    log stdout
    error stderr
  .then ->
    configAll { configs, directory, error, log }
  .then ->
    commit { directory, message }
  .then ({ stdout, stderr }) ->
    log stdout
    error stderr
  .then ->
    push { repository, src, dst }
  .then ({ stdout, stderr }) ->
    log stdout
    error stderr
    null
