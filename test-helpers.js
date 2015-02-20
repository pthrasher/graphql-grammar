var PEG = require('pegjs');

/*
cache — if true, makes the parser cache results, avoiding exponential parsing time in pathological cases but making the parser slower (default: false)
allowedStartRules — rules the parser will be allowed to start parsing from (default: the first rule in the grammar)
output — if set to "parser", the method will return generated parser object; if set to "source", it will return parser source code as a string (default: "parser")
optimize— selects between optimizing the generated parser for parsing speed ("speed") or code size ("size") (default: "speed")
plugins — plugins to use
*/

var getParser = function(grammarText, start) {
  var opts = {
    allowedStartRules: start,
  };

  var parser = PEG.buildParser(grammarText, opts);
  return parser;
};

module.exports = {
  getParser: getParser
}
