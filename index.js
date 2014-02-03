(function() {
  var height, map, svg, vis, width, zoom;

  width = 960;

  height = 500;

  /* create the SVG
  */

  svg = d3.select('body').append('svg').attr('width', width).attr('height', height);

  vis = svg.append('g');

  map = vis.append('g').attr('transform', "translate(" + (width / 2) + "," + (height / 2) + ")");

  /* define a zoom behavior
  */

  zoom = d3.behavior.zoom().scaleExtent([1, 10]).on('zoom', function() {
    /* whenever the user zooms,
    */
    /* modify translation and scale of the zoom group accordingly
    */    return vis.attr('transform', "translate(" + (zoom.translate()) + ")scale(" + (zoom.scale()) + ")");
  });

  /* bind the zoom behavior to the main SVG
  */

  svg.call(zoom);

  /* read flare data
  */

  d3.json('flare-imports.json', function(data) {
    /* package tree
    */
    var defs, depth_color, hierarchy, leaves, nodes, scale, tree;
    tree = flare_reader.tree(data);
    hierarchy = d3.layout.hierarchy();
    nodes = hierarchy(tree);
    /* imports links
    */
    /* this tree is unordered, we need a canonical ordering for it
    */
    tree_utils.canonical_sort(tree);
    /* obtain the sequence of leaves
    */
    leaves = tree_utils.get_leaves(tree);
    /* VISUALIZATION
    */
    /* compute the space-filling curve layout
    */
    scale = 26;
    sfc_layout.displace(leaves, sfc_layout.HILBERT, scale, 0);
    /* compute also the position of internal nodes
    */
    sfc_layout.displace_tree(tree);
    /* define a bundle layout
    */
    /* define a color scale for leaf depth
    */
    depth_color = d3.scale.linear().domain([
      1, d3.max(leaves, function(d) {
        return d.depth;
      })
    ]).range(['#FFF7DB', '#F0A848']).interpolate(d3.interpolateHcl);
    /* define a thickness scale for region depth
    */
    /* translate size to cell scale
    */
    /* translate depth to label font size
    */
    /* compute all the internal nodes regions
    */
    jigsaw.treemap(tree, scale, jigsaw.SQUARE_CELL);
    /* define the level zero region (the land)
    */
    defs = svg.append('defs');
    defs.append('path').attr('id', 'land').attr('d', jigsaw.get_svg_path(tree.region));
    /* faux land glow (using filters takes too much resources)
    */
    map.append('use').attr('class', 'land-glow-outer').attr('xlink:href', '#land');
    map.append('use').attr('class', 'land-glow-inner').attr('xlink:href', '#land');
    /* draw the cells
    */
    map.selectAll('.cell').data(leaves).enter().append('path').attr('class', 'cell').attr('d', jigsaw.square_generate_svg_path(scale)).attr('transform', function(d) {
      return "translate(" + d.x + "," + d.y + ")";
    }).attr('fill', function(d) {
      return depth_color(d.depth);
    }).attr('stroke', 'white');
    /* draw the level one region boundaries
    */
    /* draw the land border (above cells)
    */
    map.append('use').attr('class', 'land-fill').attr('xlink:href', '#land');
    /* draw the graph links
    */
    /* draw the level one labels
    */
    /* draw the leaf labels
    */
    return map.selectAll('.label').data(leaves).enter().append('text').attr('class', 'label').attr('font-size', '2px').attr('dy', '0.35em').attr('transform', function(d) {
      return "translate(" + d.x + "," + d.y + ")";
    }).text(function(d) {
      return d.name.split('.').reverse()[0];
    });
  });

}).call(this);
