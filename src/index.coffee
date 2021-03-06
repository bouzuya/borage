crypto = require 'crypto'
fs = require 'fs'
path = require 'path'
{Promise} = require 'es6-promise'
glob = require 'glob'
s3 = require './s3'

digest = (content) ->
  md5 = crypto.createHash 'md5'
  md5.update content
  md5.digest 'hex'

# Array<{ key:string, path:string, digest:string }>
getLocalFiles = (pattern, { root }) ->
  # files: [{ cwd: '', src: ['key', ...] }, ...]
  new Promise (resolve, reject) ->
    glob pattern, (err, files) ->
      return reject(err) if err?
      localFiles = files.reduce (results, i) ->
        results.concat [
          key: path.relative(root, i)
          path: path.resolve(i)
        ]
      , []
      .filter (i) ->
        fs.statSync(i.path).isFile()
      .map ({ key, path }) ->
        { key, path, digest: digest(fs.readFileSync path, {}) }
      resolve localFiles

# Promise<Array<{ key:string, digest:string }>>
getRemoteFiles = ({ accessKeyId, bucketName, secretAccessKey, region }) ->
  client = s3 { accessKeyId, secretAccessKey, region }
  client.listAllObjects Bucket: bucketName
  .then (result) ->
    result.map (r) ->
      key: r.Key
      digest: JSON.parse r.ETag # bug ? remote.digest quoted by ". '"..."'

getUploadFiles = (localFiles, remoteFiles) ->
  localFiles.filter (local) ->
    remoteFiles.every (remote) ->
      local.key isnt remote.key or local.digest isnt remote.digest

uploadFiles = (
  files, { accessKeyId, bucketName, secretAccessKey, region, verbose }) ->
  client = s3 { accessKeyId, secretAccessKey, region, verbose }
  client.putAllObjects files, Bucket: bucketName

module.exports = (pattern, options) ->
  options.root ?= process.cwd()
  options.bucketName ?= null # required
  options.accessKeyId ?= process.env.AWS_ACCESS_KEY_ID # required
  options.secretAccessKey ?= process.env.AWS_SECRET_ACCESS_KEY # required
  options.region ?= process.env.AWS_REGION ? 'ap-northeast-1'
  options.verbose ?= false

  localFiles = []
  remoteFiles = []
  toUploadFiles = []

  Promise.resolve()
  .then -> getLocalFiles pattern, { root: options.root }
  .then (files) -> localFiles = files
  .then -> getRemoteFiles options
  .then (files) -> remoteFiles = files
  .then -> getUploadFiles localFiles, remoteFiles
  .then (files) -> toUploadFiles = files
  .then -> uploadFiles toUploadFiles, options
