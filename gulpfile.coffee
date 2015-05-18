coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
del = require 'del'
espower = require 'gulp-espower'
gulp = require 'gulp'
gutil = require 'gulp-util'
mocha = require 'gulp-mocha'
run = require 'run-sequence'
sourcemaps = require 'gulp-sourcemaps'
uglify = require 'gulp-uglify'
watch = require 'gulp-watch'

ignoreError = (stream) ->
  stream.on 'error', (e) ->
    gutil.log e
    @emit 'end'

gulp.task 'build', ->
  gulp.src './src/**/*.coffee'
  .pipe coffee()
  .pipe uglify()
  .pipe gulp.dest './lib/'

gulp.task 'build-dev', ->
  gulp.src './src/**/*.coffee'
  .pipe sourcemaps.init()
  .pipe ignoreError coffee()
  .pipe sourcemaps.write()
  .pipe gulp.dest './.tmp/src/'

gulp.task 'build-test', ->
  gulp.src './test/**/*.coffee'
  .pipe sourcemaps.init()
  .pipe coffee()
  .pipe espower()
  .pipe sourcemaps.write()
  .pipe gulp.dest './.tmp/test/'

gulp.task 'build-test-dev', ->
  gulp.src './test/**/*.coffee'
  .pipe sourcemaps.init()
  .pipe ignoreError coffee()
  .pipe ignoreError espower()
  .pipe sourcemaps.write()
  .pipe gulp.dest './.tmp/test/'

gulp.task 'clean', (done) ->
  del [
    './.tmp/'
    './lib/'
  ], done
  null

gulp.task 'default', ['clean', 'build']

gulp.task 'test', ['build-test'], ->
  gulp.src './.tmp/test/**/*.js'
  .pipe mocha()

gulp.task 'test-dev', ['build-test-dev'], ->
  gulp.src './.tmp/test/**/*.js'
  .pipe ignoreError mocha()

gulp.task 'watch', ['build-dev'], ->
  watch [
    './src/**/*.coffee'
    './test/**/*.coffee'
  ], ->
    run.apply run, [
      'build-dev'
      'test-dev'
      ->
    ]

