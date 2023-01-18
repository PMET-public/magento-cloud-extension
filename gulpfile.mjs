/* eslint-disable one-var */

import gulp from 'gulp'
const { series, parallel, src, dest, task } = gulp
import imagemin, {gifsicle, mozjpeg, optipng, svgo} from 'gulp-imagemin'
import {deleteSync} from 'del'
import gulpif from 'gulp-if'
import htmlmin from 'gulp-htmlmin'
import dartSass from 'sass'
import gulpSass from 'gulp-sass'
import concat from 'gulp-concat'
import minify from 'gulp-minify'
import GulpZip from 'gulp-zip'
import fileinclude from 'gulp-file-include'

const sass = gulpSass(dartSass)

const jqueryPath = 'node_modules/jquery/dist/jquery.js',
  jqueryUIPath = 'node_modules/jquery-ui-dist/jquery-ui.js',

  imageDownloader = [
    'app/image-downloader/lib/zepto.js',
    'app/image-downloader/lib/jquery.nouislider/jquery.nouislider.js',
    'app/image-downloader/lib/jss.js',
    'app/image-downloader/scripts/defaults.js',
    'app/image-downloader/scripts/popup.js'
  ],

  mcmExt = [
    'app/scripts/popup/ga-lib.js',
    'app/scripts/popup/analytics.js',
    'app/scripts/popup/custom-autocomplete.js',
    'app/scripts/lib/lib-open.js',
    'app/scripts/lib/init.js',
    'app/scripts/popup/css-injector/*.js',
    'app/scripts/popup/commands-data.js',
    'app/scripts/popup/commands.js',
    'app/scripts/popup/mce-popup.js',
    'app/scripts/lib/lib-close.js'
  ],

  contentScripts = [
    'app/scripts/content/lib-for-document.js',
    'app/scripts/content/document-start.js',
  ],

  distBackgroundScripts = [
    'app/scripts/lib/lib-open.js',
    'app/scripts/lib/init.js',
    'app/scripts/background/my-background.js',
    'app/image-downloader/scripts/defaults.js',
    'app/scripts/lib/lib-close.js'
  ],

  appScss = [
    'app/styles.scss/vendor.scss',
    'app/styles.scss/main.scss',
    'app/styles.scss/content.scss',
    'app/styles.scss/import-cloud-ui.scss',
  ],

  devOpts = {
    mode: "dev",
    backgroundScripts: distBackgroundScripts,
    popupScripts: [jqueryPath, jqueryUIPath, ...imageDownloader, 'app/scripts/popup/ga-dev-mode.js', ...mcmExt],
    sourcemaps: true,
    minify: false
  },

  distOpts = {
    mode: "dist",
    backgroundScripts: distBackgroundScripts,
    popupScripts: [jqueryPath, jqueryUIPath, ...imageDownloader, ...mcmExt],
    // sourcemaps: false,
    sourcemaps: true,
    minify: false
  }

let gulpOpts = distOpts

export const setDevMode = (cb) => {
  gulpOpts = devOpts
  cb()
}

export const setDistMode = (cb) => {
  gulpOpts = distOpts
  cb()
}

export const copyRemainingToDist = () => gulp.src([
    'app/manifest.json',
    'app/_locales/**',
    'app/image-downloader/**'
  ], {
    base: 'app',
    dot: true
  }).pipe(gulp.dest('dist'))

export const clean = function clean(cb) {
  deleteSync(['.tmp', 'dist'])
  cb()
}

export const html = () => gulp.src('app/html/*.html')
  .pipe(fileinclude())
  .pipe(gulpif(gulpOpts.minify, htmlmin({
    collapseWhitespace: true,
    minifyCSS: true,
    minifyJS: true,
    removeComments: true
  })))
  .pipe(gulp.dest('dist/html/'))

export const images = () => gulp.src('app/images/**/*')
  .pipe(imagemin([
    gifsicle({interlaced: true}),
    mozjpeg({quality: 75, progressive: true}),
    optipng({optimizationLevel: 5}),
    // usage diff from README; see https://github.com/sindresorhus/gulp-imagemin/pull/359
    svgo({
      plugins: [
        {
          name: "preset-default",
          params: { overrides: { removeViewBox: false, cleanupIDs: false } }
        }
      ]
    })
  ]))
  .pipe(gulp.dest('dist/images'))

export const styles = () => gulp.src(appScss, {sourcemaps: gulpOpts.sourcemaps})
  .pipe(sass().on('error', sass.logError))
  .pipe(gulp.dest('dist/styles', {sourcemaps: gulpOpts.sourcemaps}))

export const js = gulp.series(
  () => gulp.src(gulpOpts.backgroundScripts, {sourcemaps: gulpOpts.sourcemaps})
    .pipe(concat('background.processed.js'))
    .pipe(gulpif(gulpOpts.minify, minify({noSource: true, ext: {min: '.js'}})))
    .pipe(gulp.dest('dist/scripts', {sourcemaps: gulpOpts.sourcemaps})),
  () => gulp.src([jqueryPath, ...contentScripts], {sourcemaps: gulpOpts.sourcemaps})
    .pipe(concat('content.processed.js'))
    .pipe(gulpif(gulpOpts.minify, minify({noSource: true, ext: {min: '.js'}})))
    .pipe(gulp.dest('dist/scripts', {sourcemaps: gulpOpts.sourcemaps})),
  () => gulp.src(gulpOpts.popupScripts, {sourcemaps: gulpOpts.sourcemaps})
    .pipe(concat('popup.processed.js'))
    .pipe(gulpif(gulpOpts.minify, minify({noSource: true, ext: {min: '.js'}})))
    .pipe(gulp.dest('dist/scripts', {sourcemaps: gulpOpts.sourcemaps}))
)

let sharedTasks = [copyRemainingToDist, js, styles, html, images]
export const dev = gulp.series(setDevMode, ...sharedTasks)
export const dist = gulp.series(setDistMode, clean, ...sharedTasks)

export const zip = gulp.series(
  dist,
  () => gulp.src([
      'dist/**',
      'sh-scripts/*.sh',
      'sh-scripts/**/*.sh'
    ])
    .pipe(GulpZip('mcm-chrome-ext.zip'))
    .pipe(gulp.dest('package'))
)

export const watcher = function() {
  gulp.watch('app/html/**/*.html', html)
  gulp.watch('app/**/*.js', js)
  gulp.watch('app/styles.scss/*.scss', styles)
}
