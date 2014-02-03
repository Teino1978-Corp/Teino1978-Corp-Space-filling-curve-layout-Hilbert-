### read flare-imports data and provide it in form of tree (for the package hierarchy) and links (for the imports) ###
### code adapted from http://bl.ocks.org/mbostock/4341134 ###
`
window.flare_reader = {
 
  // Lazily construct the package hierarchy from class names.
  tree: function(classes) {
    var map = {};
 
    function find(name, data) {
      var node = map[name], i;
      if (!node) {
        node = map[name] = data || {name: name, children: []};
        if (name.length) {
          node.parent = find(name.substring(0, i = name.lastIndexOf(".")));
          node.parent.children.push(node);
          node.key = name.substring(i + 1);
        }
      }
      return node;
    }
 
    classes.forEach(function(d) {
      find(d.name, d);
    });
    var flare = map['flare'];
    delete flare.parent; // CHANGED root node is not ""
    return flare;
  },
 
  // Return a list of imports for the given array of nodes.
  imports: function(nodes) {
    var map = {},
        imports = [];
 
    // Compute a map from name to node.
    nodes.forEach(function(d) {
      map[d.name] = d;
    });
 
    // For each import, construct a link from the source to target node.
    nodes.forEach(function(d) {
      if (d.imports) d.imports.forEach(function(i) {
        imports.push({source: map[d.name], target: map[i]});
      });
    });
 
    return imports;
  }
};
`