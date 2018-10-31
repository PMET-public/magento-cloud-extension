// generated on 2018-05-08 using generator-chrome-extension 0.7.1
import gulp from 'gulp';
import gulpLoadPlugins from 'gulp-load-plugins';
import del from 'del';
import runSequence from 'run-sequence';
import {stream as wiredep} from 'wiredep';

const $ = gulpLoadPlugins();

const jqueryDeps = [
  'app/vendor/jquery-3.3.1.min.js',
  'app/vendor/jquery-ui-1.12.1.min.js'
  
]

const imageDownloader = [
  'app/image-downloader/lib/zepto.js',
  'app/image-downloader/lib/jquery.nouislider/jquery.nouislider.js',
  'app/image-downloader/lib/jss.js',
  'app/image-downloader/scripts/defaults.js',
  'app/image-downloader/scripts/popup.js'
]

const mcmExt = [
  'app/scripts/custom-autocomplete.js',
  'app/scripts/lib-for-extension.js',
  'app/scripts/css-injector/1.js',
  'app/scripts/css-injector/delete-button.js',
  'app/scripts/css-injector/input-field.js',
  'app/scripts/css-injector/name-dialog.js',
  'app/scripts/css-injector/css-injector.js',
  'app/scripts/commands.js',
  'app/scripts/popup.js'
]

gulp.task('extras', () => {
  return gulp.src([
    'app/*.*',
    'app/_locales/**',
    '!app/*.json',
    '!app/*.html',
    '!app/styles.scss',
    'app/image-downloader/**/*'
  ], {
    base: 'app',
    dot: true
  }).pipe(gulp.dest('dist'));
});

function lint(files, options) {
  return () => {
    return gulp.src(files)
      .pipe($.eslint(options))
      .pipe($.eslint.format());
  };
}

function concatWithSourceMap(srcs, outputFile) {
  return gulp.src(srcs)
    .pipe($.sourcemaps.init())
    .pipe($.concat(outputFile))
    .pipe(gulp.dest("app/combined"))
    .pipe($.sourcemaps.write())
    .pipe(gulp.dest("app/combined"));
}

gulp.task('lint', lint(mcmExt, {
  env: {es6: true}
}));

gulp.task('js-jquery-deps', () => {
  return concatWithSourceMap(jqueryDeps, '1-js-jquery-deps.js')
})

gulp.task('js-image-downloader', () => {
  return concatWithSourceMap(imageDownloader, '2-js-image-downloader.js')
})

gulp.task('js-mcm-ext', () => {
  return concatWithSourceMap(mcmExt, '3-js-mcm-ext.js')
})

gulp.task('images', () => {
  return gulp.src('app/images/**/*')
    .pipe($.if($.if.isFile, $.cache($.imagemin({
      progressive: true,
      interlaced: true,
      // don't remove IDs from SVGs, they are often used
      // as hooks for embedding and styling
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
    .pipe(gulp.dest('app/styles'));
});

gulp.task('html', ['styles'], () => {
  return gulp.src('app/*.html')
    .pipe($.useref({searchPath: ['.tmp', 'app', '.']}))
    .pipe($.if('*.css', $.cleanCss({compatibility: '*'})))
    .pipe($.if('*.html', $.htmlmin({
      collapseWhitespace: true,
      minifyCSS: true,
      minifyJS: true,
      removeComments: true
    })))
    .pipe(gulp.dest('dist'));
});

gulp.task('chromeManifest', () => {
  return gulp.src('app/manifest.json')
    .pipe($.chromeManifest({
      buildnumber: true,
      background: {
        target: 'scripts/background.js',
        exclude: [
          'crx-hotreload/hot-reload.js'
        ]
      }
  }))
  .pipe($.if('*.css', $.cleanCss({compatibility: '*'})))
  .pipe(gulp.dest('dist'));
});

gulp.task('clean', del.bind(null, ['.tmp', 'dist']));

gulp.task('watch', ['lint', 'styles', 'js-jquery-deps', 'js-image-downloader', 'js-mcm-ext'], () => {
  gulp.watch('app/scripts/**/*.js', ['lint']);
  gulp.watch('app/styles.scss/**/*.scss', ['styles']);
  gulp.watch(mcmExt, ['js-mcm-ext']);
});

gulp.task('size', () => {
  return gulp.src('dist/**/*').pipe($.size({title: 'build', gzip: true}));
});

gulp.task('wiredep', () => {
  gulp.src('app/*.html')
    .pipe(wiredep({
      ignorePath: /^(\.\.\/)*\.\./
    }))
    .pipe(gulp.dest('app'));
});

gulp.task('package', function () {
  var manifest = require('./dist/manifest.json');
  return gulp.src('dist/**')
      .pipe($.zip('mcm-chrome-ext-' + manifest.version + '.zip'))
      .pipe(gulp.dest('package'));
});

gulp.task('build', cb => {
  runSequence(['lint', 'chromeManifest', 'html', 'images', 'extras'], cb);
});

gulp.task('default', ['clean'], cb => {
  runSequence('build', cb);
});
