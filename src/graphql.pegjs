/*

user("1573736868737623") {
  id,
  name,
  birthdate {
    month,
    day
  },
  friends.after(3).first(1) {
    cursor,
    user {
      name
    }
  }
}

user(1573736868737623) {
  id,
  name,
  birthdate {
    month,
    day
  },
  friends.first(1) {
    cursor,
    user {
      name
    }
  }
}

*/


/* // This is the main start rule. */
NODES = (node)*

ws "whitespace" = [ \t\n\r]*
block_begin     = ws "{" ws
block_end       = ws "}" ws
call_begin      = ws "(" ws
call_end        = ws ")" ws
ident           = ws chars:[a-zA-Z]+ ws { return chars.join(""); }
ident_sep       = ws "." ws
member_sep      = ws "," ws
arg_sep         = ws "," ws

member = member_node / member_cursor / member_ident

member_cursor = value:"cursor"i {return {type: "CURSOR", value: true}; }
member_node = value:node {return {type: "NODE", value: value}; }
member_ident = value:ident {return {type: "FIELD", value: value}; }

node_ident_prop = ident_sep propname:ident call_begin propargs:arguments call_end
  {
    return {propname: propname, propargs:propargs};
  }

node_ident_id = call_begin id:value? call_end { return id != null ? id : null; }

arg = ident / value

arguments
  = args:(
    first:arg
    rest:(arg_sep a:arg { return a; })*
    {
      var i, results = [first];

      for (i = 0; i < rest.length; i++) {
        results.push(rest[i]);
      }
      return results;
    }
  )?
  { return args !== null ? args : []; }

node_ident = name:ident args:(call_begin a:arguments call_end { return a != null ? a : []; })?
    props:(
    props_all:(p:node_ident_prop { return p; })*
    {
      var result = [], i;

      for (i = 0; i < props_all.length; i++) {
        result.push({
          name: props_all[i].propname,
          arguments: props_all[i].propargs
        });
      }
      return result;
    }
  )?
  {
    var ident = {
      name: name,
      arguments: args,
      calls: []
    };
    if (props !== null) {
      ident.calls = props;
    }
    return ident;
  }

node
  = node_meta:node_ident
    block_begin
    members:(
      first:member
      rest:(member_sep m:member { return m; })*
      {
        var member, result = {
          fields: [],
          nodes: [],
          needs_cursor: false
        }, i;

        switch (first.type) {
          case "FIELD":
            result.fields.push(first.value);
            break;
          case "NODE":
            result.nodes.push(first.value);
            break;
          case "CURSOR":
            result.needs_cursor = true
            break;
        }

        for (i = 0; i < rest.length; i++) {
          member = rest[i];
          switch (member.type) {
            case "FIELD":
              result.fields.push(member.value);
              break;
            case "NODE":
              result.nodes.push(member.value);
              break;
            case "CURSOR":
              result.needs_cursor = true
              break;
          }
        }
        return result;
      }
    )?
    block_end
    {
      var result = node_meta;
      if (typeof members != 'undefined' && members != null) {
        result.fields = members.fields;
        result.nodes = members.nodes;
        result.needs_cursor = members.needs_cursor;
      } else {
        result.fields = [];
        result.nodes = [];
        result.needs_cursor = false;
      }
      return result;
    }


value
  = false
  / null
  / true
  / number
  / string

false = "false" { return false; }
null  = "null"  { return null;  }
true  = "true"  { return true;  }

number "number"
  = minus? int frac? exp? { return parseFloat(text()); }

decimal_point = ","
digit1_9      = [1-9]
e             = [eE]
exp           = e (minus / plus)? DIGIT+
frac          = decimal_point DIGIT+
int           = zero / (digit1_9 DIGIT*)
minus         = "-"
plus          = "+"
zero          = "0"


string "string"
  = quotation_mark chars:char* quotation_mark
  {
    return chars != null ? chars.join("") : "";
  }

char
  = unescaped
  / escape
    sequence:(
        '"'
      / "\\"
      / "/"
      / "b" { return "\b"; }
      / "f" { return "\f"; }
      / "n" { return "\n"; }
      / "r" { return "\r"; }
      / "t" { return "\t"; }
      / "u" digits:$(HEXDIG HEXDIG HEXDIG HEXDIG) {
          return String.fromCharCode(parseInt(digits, 16));
        }
    )
    { return sequence; }

escape         = "\\"
quotation_mark = '"'
unescaped      = [\x20-\x21\x23-\x5B\x5D-\u10FFFF]

/* ----- Core ABNF Rules ----- */

/* See RFC 4234, Appendix B (http://tools.ietf.org/html/rfc4627). */
DIGIT  = [0-9]
HEXDIG = [0-9a-f]i

