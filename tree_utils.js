(function() {
  var rsort, tcmp;

  tcmp = function(a, b) {
    var ai, bi, children_a, children_b, ci, _i, _len, _ref, _ref2;
    children_a = (a.children != null ? a.children : []);
    children_b = (b.children != null ? b.children : []);
    _ref = zip(children_a, children_b);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      _ref2 = _ref[_i], ai = _ref2[0], bi = _ref2[1];
      ci = tcmp(ai, bi);
      if (ci !== 0) return ci;
    }
    return children_b.length - children_a.length;
  };

  rsort = function(t) {
    var c, children, _i, _len;
    children = (t.children != null ? t.children : []);
    for (_i = 0, _len = children.length; _i < _len; _i++) {
      c = children[_i];
      rsort(c);
    }
    return children.sort(tcmp);
  };

  window.tree_utils = {
    /* sort the given unordered tree using a canonical ordering
    */
    /* see Constant time generation of free trees - Wright et al. 1986
    */
    canonical_sort: function(tree) {
      return rsort(tree);
    },
    /* return the ordered sequence of leaves of a given tree
    */
    get_leaves: function(tree) {
      var parse_leaves, seq;
      seq = [];
      parse_leaves = function(node) {
        var c, _i, _len, _ref, _results;
        if (!(node.children != null)) {
          return seq.push(node);
        } else {
          _ref = node.children;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            c = _ref[_i];
            _results.push(parse_leaves(c));
          }
          return _results;
        }
      };
      parse_leaves(tree);
      return seq;
    }
  };

}).call(this);
