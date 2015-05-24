fs = require 'fs'
{Promise} = require 'es6-promise'
{S3} = require 'aws-sdk'
mime = require 'mime'

class MyS3
  constructor: (options) ->
    options.apiVersion = '2006-03-01'
    @_client = new S3 options

  listAllObjects: (options, result = []) ->
    @_listObjects options
    .then (data) =>
      contents = data.Contents
      result = result.concat contents
      return result unless data.IsTruncated
      options.Marker = data.NextMarker || contents[contents.length - 1].Key
      @listAllObjects options, result

  putAllObjects: (files, { Bucket }) ->
    files.reduce (promise, { key, path }) =>
      promise
      .then =>
        @_putObject
          Bucket: Bucket
          Key: key
          Body: fs.readFileSync path
          ContentType: mime.lookup path
    , Promise.resolve()

  _putObject: (options) ->
    new Promise (resolve, reject) =>
      @_client.putObject options, (err) ->
        return reject(err) if err?
        resolve()

  _listObjects: (options) ->
    new Promise (resolve, reject) =>
      @_client.listObjects options, (err, data) ->
        return reject(err) if err?
        resolve data

module.exports = (options) ->
  new MyS3 options
