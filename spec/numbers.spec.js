var fs  = require('fs');
var helpers = require('../test-helpers.js');

describe('Numbers', function() {
  var parser;
  var grammarText;

  beforeEach(function(){
    grammarText = fs.readFileSync('build/number.pegjs', 'utf8');
    parser = helpers.getParser(grammarText, ['number']);
  })

  afterEach(function(){
    parser = null;
    grammarText = null;
  });

  it('correctly parses negative numbers', function() {
    expect(parser.parse('-234')).toBe(-234)
  });

  it('correctly parses positive numbers', function() {
    expect(parser.parse('234')).toBe(234)
  });

  it('correctly parses floats', function() {
    expect(parser.parse('234.234')).toEqual(234.234)
  });
});


