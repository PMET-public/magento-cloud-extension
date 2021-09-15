// generated on 2018-05-08 using generator-chrome-extension 0.7.1

const gulp = require('gulp'),
  gulpLoadPlugins = require('gulp-load-plugins')
const $ = gulpLoadPlugins()
const del = require('del')
const wiredep = require('wiredep').stream
const runSequence = require('gulp4-run-sequence')

const jqueryDeps = [
    'app/bower_components/jquery/dist/jquery.js',
    'app/bower_components/jquery-ui/jquery-ui.js'
  ],

  imageDownloader = [
    'app/image-downloader/lib/zepto.js',
    'app/image-downloader/lib/jquery.nouislider/jquery.nouislider.js',
    'app/image-downloader/lib/jss.js',
    'app/image-downloader/scripts/defaults.js',
    'app/image-downloader/scripts/popup.js'
  ],

  mcmExt = [
    'app/scripts/popup/analytics.js',
    'app/scripts/popup/custom-autocomplete.js',
    'app/scripts/lib/lib-open.js',
    'app/scripts/popup/css-injector/*.js',
    'app/scripts/popup/commands-data.js',
    'app/scripts/popup/commands.js',
    'app/scripts/popup/mce-popup.js',
    'app/scripts/lib/lib-close.js'
  ],

  contentScripts = [
  // 'app/bower_components/tablesorter/dist/js/jquery.tablesorter.combined.js',
  // app/scripts/content/index.js',
    'app/scripts/content/lib-for-document.js',
    'app/scripts/content/document-start.js'
  ],

  distBackgroundScripts = [
    'app/scripts/lib/lib-open.js',
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

function lint(files, options) {
  return () =>
    gulp.src(files)
      .pipe($.eslint(options))
      .pipe($.eslint.format())
}

gulp.task('copy-remaining-to-dist', () =>
  gulp.src([
    'app/manifest.json',
    'app/_locales/**',
    'app/image-downloader/**'
  ], {
    base: 'app',
    dot: true
  }).pipe(gulp.dest('dist'))
)

gulp.task('lint', lint(mcmExt, {
  env: {es6: true}
}))

gulp.task('clean', del.bind(null, ['.tmp', 'dist']))

gulp.task('dev-js', gulp.series((done) => {
  gulp.src(devBackgroundScripts)
    .pipe($.sourcemaps.init())
    .pipe($.concat('background.processed.js'))
    .pipe(gulp.dest('dist/scripts'))
    .pipe($.sourcemaps.write())
    .pipe(gulp.dest('dist/scripts'))
  gulp.src(contentScripts)
    .pipe($.sourcemaps.init())
    .pipe($.concat('content.processed.js'))
    .pipe(gulp.dest('dist/scripts'))
    .pipe($.sourcemaps.write())
    .pipe(gulp.dest('dist/scripts'))
  gulp.src([...jqueryDeps, ...imageDownloader, ...mcmExt])
    .pipe($.sourcemaps.init())
    .pipe($.concat('popup.processed.js'))
    .pipe(gulp.dest('dist/scripts'))
    .pipe($.sourcemaps.write())
    .pipe(gulp.dest('dist/scripts'))
  done()
}))

gulp.task('dev-styles', () =>
  gulp.src([
    'app/styles.scss/vendor.scss',
    'app/styles.scss/main.scss',
    'app/styles.scss/content.scss',
    'app/styles.scss/import-cloud-ui.scss',
  ])
    .pipe($.plumber())
    .pipe($.sourcemaps.init())
    .pipe($.sass.sync({
      outputStyle: 'expanded',
      precision: 10,
      includePaths: ['.']
    }).on('error', $.sass.logError))
    .pipe($.sourcemaps.write())
    .pipe(gulp.dest('dist/styles'))
)

gulp.task('dev-build', gulp.series('clean', (cb) => {
  runSequence('copy-remaining-to-dist', 'lint', 'dev-js', 'dev-styles', 'html', 'images', cb)
}))

gulp.task('dist-js', gulp.series((done) => {
  gulp.src(distBackgroundScripts)
    .pipe($.concat('background.processed.js'))
    .pipe($.minify({noSource: true, ext: {min: '.js'}}))
    .pipe(gulp.dest('dist/scripts'))
  gulp.src(contentScripts)
    .pipe($.concat('content.processed.js'))
    .pipe($.minify({noSource: true, ext: {min: '.js'}}))
    .pipe(gulp.dest('dist/scripts'))
  gulp.src([...jqueryDeps, ...imageDownloader, ...mcmExt])
    .pipe($.concat('popup.processed.js'))
    .pipe($.minify({noSource: true, ext: {min: '.js'}}))
    .pipe(gulp.dest('dist/scripts'))
  done()
}))

gulp.task('dist-styles', () =>
  gulp.src([
    'app/styles.scss/vendor.scss',
    'app/styles.scss/main.scss',
    'app/styles.scss/content.scss',
    'app/styles.scss/import-cloud-ui.scss',
  ])
  .pipe($.plumber())
  .pipe($.sass.sync({
    outputStyle: 'expanded',
    precision: 10,
    includePaths: ['.']
  }).on('error', $.sass.logError))
  .pipe(gulp.dest('dist/styles'))
)

gulp.task('images', () =>
  gulp.src('app/images/**/*')
    .pipe($.if($.if.isFile, $.imagemin({
      progressive: true,
      interlaced: true,
      // don't remove IDs from SVGs, they are often used as hooks for embedding and styling
      svgoPlugins: [{cleanupIDs: false}]
    })
    .on('error', function (err) {
      console.log(err)
      this.end()
    })))
    .pipe(gulp.dest('dist/images'))
)

gulp.task('html', () =>
  gulp.src('app/html/popup.html')
    .pipe($.fileInclude())
    .pipe($.htmlmin({
      collapseWhitespace: true,
      minifyCSS: true,
      minifyJS: true,
      removeComments: true
    }))
    .pipe(gulp.dest('dist/html/'))
)

gulp.task('watch', gulp.series('html', 'lint', 'dev-js', 'dev-styles', 'copy-remaining-to-dist', () => {
  gulp.watch('app/html/**', gulp.series('html'))
  gulp.watch('app/scripts/**/*.js', gulp.series('lint', 'dev-js'))
  gulp.watch('app/styles.scss/**/*.scss', gulp.series('dev-styles'))
  gulp.watch('app/image-downloader/**', gulp.series('copy-remaining-to-dist'))
}))

gulp.task('wiredep', () =>
  gulp.src('app/*.html')
    .pipe(wiredep({
      ignorePath: /^(\.\.\/)*\.\./
    }))
    .pipe(gulp.dest('app'))
)

gulp.task('dist-build', gulp.series('clean', 'copy-remaining-to-dist', 'lint', 'dist-js', 'dist-styles', 'html', 'images'))

gulp.task('package', gulp.series('dist-build', (done) => {
  const manifest = require('./dist/manifest.json')
  gulp.src([
    'dist/**',
    'sh-scripts/*.sh',
    'sh-scripts/**/*.sh'
  ])
    .pipe($.zip('mcm-chrome-ext.zip'))
    .pipe(gulp.dest('package'))
  done()
}))

// gulp.task('default', ['dev-build'])
