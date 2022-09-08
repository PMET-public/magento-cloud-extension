#! /usr/bin/env node

/* eslint-disable one-var */

import gulp from 'gulp'
const { series, parallel, src, dest, task } = gulp
import imagemin, {gifsicle, mozjpeg, optipng, svgo} from 'gulp-imagemin'
import {deleteSync} from 'del'
import gulpPlumber from 'gulp-plumber'
import sourcemaps from 'gulp-sourcemaps'
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

  injectedScripts = [
    'app/scripts/injected/rundeck.js'
  ],

  distBackgroundScripts = [
    'app/scripts/lib/lib-open.js',
    'app/scripts/lib/init.js',
    'app/scripts/background/my-background.js',
    'app/image-downloader/scripts/defaults.js',
    'app/scripts/lib/lib-close.js'
  ],

  devBackgroundScripts = ['app/crx-hotreload/hot-reload.js', ...distBackgroundScripts],

  devOpts = {
    sourcemaps: 1,
    minify: 0
  },

  distOpts = {
    sourcemaps: 0,
    minify: 1
  }

export const copyRemainingToDist = () => gulp.src([
    'app/manifest.json',
    'app/_locales/**',
    'app/image-downloader/**'
  ], {
    base: 'app',
    dot: true
  }).pipe(gulp.dest('dist'))
copyRemainingToDist.displayName = 'copy-remaining-to-dist'

export const clean = function clean(cb) {
  deleteSync(['.tmp', 'dist'])
  cb()
}

export const html = () => gulp.src('app/html/*.html')
  .pipe(fileinclude())
  .pipe(htmlmin({
    collapseWhitespace: true,
    minifyCSS: true,
    minifyJS: true,
    removeComments: true
  }))
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

export const devJs = gulp.series(
    () => gulp.src(devBackgroundScripts)
      .pipe(sourcemaps.init())
      .pipe(concat('background.processed.js'))
      .pipe(gulp.dest('dist/scripts'))
      .pipe(sourcemaps.write())
      .pipe(gulp.dest('dist/scripts')),
    () => gulp.src([jqueryPath, ...contentScripts])
      .pipe(sourcemaps.init())
      .pipe(concat('content.processed.js'))
      .pipe(gulp.dest('dist/scripts'))
      .pipe(sourcemaps.write())
      .pipe(gulp.dest('dist/scripts')),
    () => gulp.src([jqueryPath, jqueryUIPath, ...imageDownloader, 'app/scripts/popup/ga-dev-mode.js', ...mcmExt,])
      .pipe(sourcemaps.init())
      .pipe(concat('popup.processed.js'))
      .pipe(gulp.dest('dist/scripts'))
      .pipe(sourcemaps.write())
      .pipe(gulp.dest('dist/scripts')),
    () => gulp.src([jqueryPath, ...injectedScripts])
      .pipe(sourcemaps.init())
      .pipe(concat('injected.processed.js'))
      .pipe(gulp.dest('dist/scripts'))
      .pipe(sourcemaps.write())
      .pipe(gulp.dest('dist/scripts'))
  )
devJs.displayName = 'dev-js'

export const devStyles = () => gulp.src([
    'app/styles.scss/vendor.scss',
    'app/styles.scss/main.scss',
    'app/styles.scss/content.scss',
    'app/styles.scss/import-cloud-ui.scss',
  ])
    .pipe(gulpPlumber())
    .pipe(sourcemaps.init())
    .pipe(sass().on('error', sass.logError))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('dist/styles'))
devStyles.displayName = 'dev-styles'

export const devBuild = gulp.series(copyRemainingToDist, devJs, devStyles, html, images)
devBuild.displayName = 'dev-build'

export const distJs = gulp.series(
  () => gulp.src(distBackgroundScripts)
    .pipe(concat('background.processed.js'))
    .pipe(minify({noSource: true, ext: {min: '.js'}}))
    .pipe(gulp.dest('dist/scripts')),
  () => gulp.src([jqueryPath, ...contentScripts])
    .pipe(concat('content.processed.js'))
    .pipe(minify({noSource: true, ext: {min: '.js'}}))
    .pipe(gulp.dest('dist/scripts')),
  () => gulp.src([jqueryPath, jqueryUIPath, ...imageDownloader, ...mcmExt])
    .pipe(concat('popup.processed.js'))
    .pipe(minify({noSource: true, ext: {min: '.js'}}))
    .pipe(gulp.dest('dist/scripts')),
  () => gulp.src([jqueryPath, ...injectedScripts])
    .pipe(concat('injected.processed.js'))
    .pipe(minify({noSource: true, ext: {min: '.js'}}))
    .pipe(gulp.dest('dist/scripts'))
)
distJs.displayName = 'dist-js'

export const distStyles = () => gulp.src([
    'app/styles.scss/vendor.scss',
    'app/styles.scss/main.scss',
    'app/styles.scss/content.scss',
    'app/styles.scss/import-cloud-ui.scss',
  ])
  .pipe(gulpPlumber())
  .pipe(sass().on('error', sass.logError))
  .pipe(gulp.dest('dist/styles'))
distStyles.displayName = 'dist-styles'

// gulp.task('watch', gulp.series('html', 'lint', 'dev-js', 'dev-styles', 'copy-remaining-to-dist', () => {
//   gulp.watch('app/html/**', gulp.series('html'))
//   gulp.watch('app/scripts/**/*.js', gulp.series('lint', 'dev-js'))
//   gulp.watch('app/styles.scss/**/*.scss', gulp.series('dev-styles'))
//   gulp.watch('app/image-downloader/**', gulp.series('copy-remaining-to-dist'))
// }))

export const distBuild = gulp.series(clean, copyRemainingToDist, distJs, distStyles, html, images)
distBuild.displayName = 'dist-build'

export const zip = gulp.series(
  distBuild,
  () => gulp.src([
      'dist/**',
      'sh-scripts/*.sh',
      'sh-scripts/**/*.sh'
    ])
    .pipe(GulpZip('mcm-chrome-ext.zip'))
    .pipe(gulp.dest('package'))
)

// // gulp.task('default', ['dev-build'])
