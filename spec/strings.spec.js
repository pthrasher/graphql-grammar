var fs  = require('fs');
var helpers = require('../test-helpers.js');

describe('Strings', function() {
  var parser, grammarText;

  beforeEach(function(){
    grammarText = fs.readFileSync('build/string.pegjs', 'utf8');
    parser = helpers.getParser(grammarText, ['string']);
  })

  afterEach(function(){
    parser = null;
  });

  it('parses normal latin-1 just fine', function() {
    var expectedA = 'abcdefghikjlmnopqrstuvwxyz';
    var expectedB = 'ABCDEFGHIKJLMNOPQRSTUVWXYZ';
    var expectedC = '1234567890';
    var expectedD = '!@#$%^&*()-=_+';
    var expectedE = ',./<>?;\':\\"[]{}\\\\|`~';

    var testStrA = '"' + expectedA + '"';
    var testStrB = '"' + expectedB + '"';
    var testStrC = '"' + expectedC + '"';
    var testStrD = '"' + expectedD + '"';
    var testStrE = '"' + expectedE + '"';

    var resultA = parser.parse(testStrA);
    var resultB = parser.parse(testStrB);
    var resultC = parser.parse(testStrC);
    var resultD = parser.parse(testStrD);
    var resultE = parser.parse(testStrE);

    expect(resultA).toBe(expectedA);
    expect(resultB).toBe(expectedB);
    expect(resultC).toBe(expectedC);
    expect(resultD).toBe(expectedD);
    expect(resultE).toBe(expectedE.replace('\\"', '"').replace('\\\\', '\\'));

  });
});
