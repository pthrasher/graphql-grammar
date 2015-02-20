module.exports = function(grunt) {
  grunt.initConfig({
    concat: {
      options: {
        separator: '\n// -----------------------------\n',
      },
      main: {
        'build/number.pegjs': [
          'src/abnf.pegjs',
          'src/number.pegjs'
        ],
        'build/string.pegjs': [
          'src/abnf.pegjs',
          'src/string.pegjs'
        ],
        'dist/grammar.pegjs': [
          'src/graphql.pegjs',
          'src/number.pegjs',
          'src/string.pegjs',
          'src/abnf.pegjs'
        ]
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-concat');
};
