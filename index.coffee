width = 960
height = 500

### create the SVG ###
svg = d3.select('body').append('svg')
    .attr('width', width)
    .attr('height', height)
    
vis = svg.append('g')

map = vis.append('g')
    .attr('transform', "translate(#{width/2},#{height/2})")
    
### define a zoom behavior ###
zoom = d3.behavior.zoom()
    .scaleExtent([1,10]) # min-max zoom
    .on 'zoom', () ->
        ### whenever the user zooms, ###
        ### modify translation and scale of the zoom group accordingly ###
        vis.attr('transform', "translate(#{zoom.translate()})scale(#{zoom.scale()})")
        
### bind the zoom behavior to the main SVG ###
svg.call(zoom)

### read flare data ###
d3.json 'flare-imports.json', (data) ->
    ### package tree ###
    tree = flare_reader.tree(data)
    hierarchy = d3.layout.hierarchy()
    nodes = hierarchy(tree)
    
    ### imports links ###
    # graph_links = flare_reader.imports(nodes)
    
    
    ### this tree is unordered, we need a canonical ordering for it ###
    tree_utils.canonical_sort(tree)
    
    
    ### obtain the sequence of leaves ###
    leaves = tree_utils.get_leaves(tree)
    
    
    ### VISUALIZATION ###
    
    ### compute the space-filling curve layout ###
    scale = 26
    sfc_layout.displace(leaves, sfc_layout.HILBERT, scale, 0)
    
    ### compute also the position of internal nodes ###
    sfc_layout.displace_tree(tree)
    
    ### define a bundle layout ###
    # bundle = d3.layout.bundle()
    # bundles = bundle(graph_links)

    # link_generator = d3.svg.line()
        # .interpolate('bundle')
        # .tension(0.99)
        # .x((d) -> d.x)
        # .y((d) -> d.y)
        
    ### define a color scale for leaf depth ###
    depth_color = d3.scale.linear()
        .domain([1, d3.max(leaves,(d)->d.depth)])
        .range(['#FFF7DB', '#F0A848'])
        .interpolate(d3.interpolateHcl)
        
    ### define a thickness scale for region depth ###
    # depth_thickness = d3.scale.sqrt()
        # .domain([0, d3.max(leaves,(d)->d.depth)-1])
        # .range([4, 0.1])
        
    ### translate size to cell scale ###
    # size2cellscale = d3.scale.sqrt()
        # .domain([0, d3.max(nodes,(d)->d.size)])
        # .range([0,scale])
        
    ### translate depth to label font size ###
    # depth2fontsize = d3.scale.sqrt()
        # .domain([0, d3.max(nodes,(d)->d.depth)])
        # .range([40,4])
        
    ### compute all the internal nodes regions ###
    jigsaw.treemap(tree, scale, jigsaw.SQUARE_CELL)
    
    ### define the level zero region (the land) ###
    defs = svg.append('defs')
    
    defs.append('path')
        .attr('id', 'land')
        .attr('d', jigsaw.get_svg_path tree.region)
        
    ### faux land glow (using filters takes too much resources) ###
    map.append('use')
        .attr('class', 'land-glow-outer')
        .attr('xlink:href', '#land')
        
    map.append('use')
        .attr('class', 'land-glow-inner')
        .attr('xlink:href', '#land')
        
    ### draw the cells ###
    map.selectAll('.cell')
        .data(leaves)
      .enter().append('path')
        .attr('class', 'cell')
        # .attr('d', (d) -> jigsaw.square_generate_svg_path size2cellscale(d.size) )
        .attr('d', jigsaw.square_generate_svg_path scale )
        .attr('transform', (d) -> "translate(#{d.x},#{d.y})")
        .attr('fill', (d) -> depth_color(d.depth))
        # .attr('stroke', (d) -> depth_color(d.depth))
        .attr('stroke', 'white')
        
    ### draw the level one region boundaries ###
    # map.selectAll('.region')
        # .data(nodes.filter((d)->d.depth is 1))
      # .enter().append('path')
        # .attr('class', 'region')
        # .attr('d', (d) -> jigsaw.get_svg_path d.region)
        ## .attr('stroke-width', (d) -> depth_thickness(d.depth))
        # .attr('stroke-width', '2px')
        
    ### draw the land border (above cells) ###
    map.append('use')
        .attr('class', 'land-fill')
        .attr('xlink:href', '#land')
        
    ### draw the graph links ###
    # map.selectAll('.graph_link')
        # .data(bundles)
      # .enter().append('path')
        # .attr('class', 'graph_link')
        # .attr('d', link_generator)
        
    ### draw the level one labels ###
    # map.selectAll('.label')
        # .data(nodes.filter((d)->d.depth is 1))
      # .enter().append('text')
        # .attr('class', 'label')
        # .attr('font-size', (d) -> depth2fontsize(d.depth))
        # .attr('dy', '0.35em')
        # .attr('transform', (d) -> "translate(#{d.x},#{d.y})")
        # .text((d) -> d.name.split('.').reverse()[0])
        
    ### draw the leaf labels ###
    map.selectAll('.label')
        .data(leaves)
      .enter().append('text')
        .attr('class', 'label')
        .attr('font-size', '2px')
        .attr('dy', '0.35em')
        .attr('transform', (d) -> "translate(#{d.x},#{d.y})")
        .text((d) -> d.name.split('.').reverse()[0])
        