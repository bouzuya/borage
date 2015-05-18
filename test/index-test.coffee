assert = require 'power-assert'
sinon = require 'sinon'
borage = require '../src/'
exec = require '../src/exec'

describe 'borage', ->
  beforeEach ->
    @sinon = sinon.sandbox.create()
    @execute = @sinon.stub exec.Executor.prototype, 'execute', ->
      Promise.resolve stdout: '', stderr: ''

  afterEach ->
    @sinon.restore()

  it 'works', ->
    borage
      configs: [
        name: 'user.name'
        value: 'bouzuya'
      ,
        name: 'user.email'
        value: 'm@bouzuya.net'
      ]
      error: ->
      log: ->
      message: 'hello'
      repository: 'https://github.com/bouzuya/borage'
    .then =>
      commands = [
        'git clone --branch gh-pages https://github.com/bouzuya/borage public'
        'git add --all'
        'git config --local user.name \'bouzuya\''
        'git config --local user.email \'m@bouzuya.net\''
        'git commit --allow-empty --message \'hello\''
        'git push \'https://github.com/bouzuya/borage\' gh-pages:gh-pages'
      ]
      assert @execute.callCount is commands.length
      commands.forEach (command, index) =>
        assert @execute.getCall(index).args[0] is command
