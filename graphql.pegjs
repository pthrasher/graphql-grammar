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




