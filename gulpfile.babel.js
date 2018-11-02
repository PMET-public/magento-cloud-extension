// generated on 2018-05-08 using generator-chrome-extension 0.7.1
import gulp from 'gulp';
import gulpLoadPlugins from 'gulp-load-plugins';
import del from 'del';
import runSequence from 'run-sequence';
import {stream as wiredep} from 'wiredep';

const $ = gulpLoadPlugins();

const jqueryDeps = [
  'app/vendor/jquery-3.3.1.min.js',
  'app/vendor/jquery-ui-1.12.1.min.js',
  'app/vendor/jquery.tablesorter.js'
]

const imageDownloader = [
  'app/image-downloader/lib/zepto.js',
  'app/image-downloader/lib/jquery.nouislider/jquery.nouislider.js',
  'app/image-downloader/lib/jss.js',
  'app/image-downloader/scripts/defaults.js',
  'app/image-downloader/scripts/popup.js'
]

const mcmExt = [
  'app/scripts/popup/custom-autocomplete.js',
  'app/scripts/lib/lib.js',
  'app/scripts/popup/css-injector/*.js',
  'app/scripts/popup/commands.js',
  'app/scripts/popup/popup.js'
]

const contentScripts = [
  'app/scripts/content/lib-for-document.js',
  'app/scripts/content/document-start.js'
]

const distBackgroundScripts = [
  'app/scripts/lib/lib.js',
  'app/scripts/background/my-background.js',
  'app/image-downloader/scripts/defaults.js'
]

const devBackgroundScripts = ['app/crx-hotreload/hot-reload.js', ...distBackgroundScripts]

function lint(files, options) {
  return () => {
    return gulp.src(files)
      .pipe($.eslint(options))
      .pipe($.eslint.format());
  };
}

function processJS(srcs, opts) {
  const defaultOpts = {
    sourcemaps: 1, 
    concat: 1, 
    minify: 0, 
    uglify: 0, 
    dest: 'dist/scripts',
    file: 'out.js'
  }
  const combinedOpts = Object.assign(defaultOpts, opts)
  return gulp.src(srcs)
    .pipe($.if(combinedOpts.sourcemaps, $.sourcemaps.init()))
    .pipe($.if(combinedOpts.concat, $.concat(combinedOpts.file)))
    .pipe($.if(combinedOpts.minify, $.minify({noSource: true, ext: {min: '.js'}})))
    .pipe($.if(combinedOpts.uglify, $.uglify()))
    .pipe(gulp.dest(combinedOpts.dest))
    .pipe($.if(combinedOpts.sourcemaps, $.sourcemaps.write()))
    .pipe(gulp.dest(combinedOpts.dest));
}

gulp.task('copy-remaining-to-dist', () => {
  return gulp.src([
    'app/manifest.json',
    'app/_locales/**',
    'app/image-downloader/**/*'
  ], {
    base: 'app',
    dot: true
  }).pipe(gulp.dest('dist'));
});

gulp.task('lint', lint(mcmExt, {
  env: {es6: true}
}));

gulp.task('dev-js', () => {
  processJS(devBackgroundScripts, {
    file: 'background/main.processed.js',
    sourcemaps: 1,
    minify: 0
  })
  processJS(contentScripts, {
    file: 'content/main.processed.js',
    sourcemaps: 1,
    minify: 0
  })
  processJS([...jqueryDeps, ...imageDownloader, ...mcmExt], {
    file: 'popup/main.processed.js',
    sourcemaps: 1,
    minify: 0
  })
})

gulp.task('dist-js', () => {
  processJS(distBackgroundScripts, {
    file: 'background/main.processed.js',
    sourcemaps: 0,
    minify: 1
  })
  processJS(contentScripts, {
    file: 'content/main.processed.js',
    sourcemaps: 0,
    minify: 1
  })
  processJS([...jqueryDeps, ...imageDownloader, ...mcmExt], {
    file: 'popup/main.processed.js',
    sourcemaps: 0,
    minify: 1
  })
})

gulp.task('images', () => {
  return gulp.src('app/images/**/*')
    .pipe($.if($.if.isFile, $.cache($.imagemin({
      progressive: true,
      interlaced: true,
      // don't remove IDs from SVGs, they are often used as hooks for embedding and styling
      svgoPlugins: [{cleanupIDs: false}]
    }))
    .on('error', function (err) {
      console.log(err);
      this.end();
    })))
    .pipe(gulp.dest('dist/images'));
});

gulp.task('styles', () => {
  return gulp.src('app/styles.scss/main.scss')
    .pipe($.plumber())
    .pipe($.sourcemaps.init())
    .pipe($.sass.sync({
      outputStyle: 'expanded',
      precision: 10,
      includePaths: ['.']
    }).on('error', $.sass.logError))
    .pipe($.sourcemaps.write())
    .pipe(gulp.dest('dist/styles'));
});

gulp.task('html', () => {
  return gulp.src('app/html/popup.html')
    .pipe($.fileInclude())
    .pipe($.htmlmin({
      collapseWhitespace: true,
      minifyCSS: true,
      minifyJS: true,
      removeComments: true
    }))
    .pipe(gulp.dest('dist/html/'));
});

gulp.task('clean', del.bind(null, ['.tmp', 'dist']));

gulp.task('watch', ['lint', 'styles', 'dev-js'], () => {
  gulp.watch('app/scripts/**/*.js', ['lint', 'dev-js']);
  gulp.watch('app/styles.scss/**/*.scss', ['styles']);
});

gulp.task('wiredep', () => {
  gulp.src('app/*.html')
    .pipe(wiredep({
      ignorePath: /^(\.\.\/)*\.\./
    }))
    .pipe(gulp.dest('app'));
});

gulp.task('build', cb => {
  runSequence(['lint', 'dev-js', 'styles', 'html', 'images'], 'copy-remaining-to-dist', cb);
});

gulp.task('package', function () {
  var manifest = require('./dist/manifest.json');
  return gulp.src([
      'dist/**'
    ])
    .pipe($.zip('mcm-chrome-ext-' + manifest.version + '.zip'))
    .pipe(gulp.dest('package'));
});

gulp.task('default', cb => {
  runSequence('clean', 'build', cb);
});
