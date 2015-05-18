assert = require 'power-assert'
exec = require '../src/exec'

describe 'exec', ->
  describe 'error', ->
    it 'works', ->
      exec '/bin/ls no-exist-file'
      .catch (e) ->
        assert e

  describe 'stdout', ->
    it 'works', ->
      exec '/bin/echo 123'
      .then ({ stdout, stderr }) ->
        assert stdout is '123\n'
        assert stderr is ''

  describe 'stderr', ->
    it 'works', ->
      exec '/bin/echo 123 1>&2'
      .then ({ stdout, stderr }) ->
        assert stdout is ''
        assert stderr is '123\n'

  describe 'options', ->
    it 'works', ->
      exec '/bin/echo $hoge', env: { hoge: 'fuga' }
      .then ({ stdout, stderr }) ->
        assert stdout is 'fuga\n'
        assert stderr is ''
