assert = require 'power-assert'
index = require '../src/'

describe 'index', ->
  it 'works', ->
    assert index(1) is 2
