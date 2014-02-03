### FIXME update this code to the optimized version ###

### compute a Lindenmayer system given an axiom, a number of steps and rules ###
fractalize = (config) ->
    input = config.axiom
    
    for i in [0...config.steps]
        output = ''
        
        for char in input
            if char of config.rules
                output += config.rules[char]
            else
                output += char
                
        input = output
        
    return output
    
### execute a curve string and return all the generated points ###
execute = (curve_string, angle, scale, orientation) ->
    points = [{x: 0, y: 0}]
    
    for char in curve_string
        if char == '+'
            orientation += angle
        else if char == '-'
            orientation -= angle
        else if char == 'F'
            last_point = points[points.length-1]
            points.push {
                x: last_point.x + scale * Math.cos(orientation),
                y: last_point.y + scale * Math.sin(orientation)
            }
            
    return points
    
### custom base for logarithm (see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/log) ###
base_log = (x, base) -> Math.log(x) / Math.log(base)

window.sfc_layout = {
    GOSPER: {
        base: 7
        angle: Math.PI/3
        axiom: 'A'
        rules:
            A: 'A+BF++BF-FA--FAFA-BF+'
            B: '-FA+BFBF++BF+FA--FA-B'
    }
    HILBERT: {
        base: 4
        angle: Math.PI/2
        axiom: 'A'
        rules:
            A: '-BF+AFA+FB-'
            B: '+AF-BFB-FA+'
    }
    displace: (seq, curve_cfg, scale, orientation) ->
        scale = if scale? then scale else 10
        orientation = if orientation? then orientation else 0
        
        ### create the minimal curve that can accommodate the whole sequence ###
        steps = Math.ceil(base_log(seq.length, curve_cfg.base))
        
        ### generate the Lindenmayer system string for the requested curve ###
        curve_string = fractalize
            steps: steps
            axiom: curve_cfg.axiom
            rules: curve_cfg.rules
            
        ### execute the string, producing the actual points of the curve ###
        curve = execute(curve_string, curve_cfg.angle, scale, orientation)
        
        ### stores the coordinates in the given sequence ###
        for [d,point] in zip(seq, curve)
            d.x = point.x
            d.y = point.y
            
        ### center the layout coordinates in its centroid ###
        cx = d3.mean(seq, (d)->d.x)
        cy = d3.mean(seq, (d)->d.y)
        for d in seq
            d.x -= cx
            d.y -= cy
            
    ### recursively assign positions to internal nodes too ###
    displace_tree: (node) ->
        if not node.children?
            return [node]
            
        ### an internal node's position is the centroid of its leaf descendants ###
        leaf_descendants = (sfc_layout.displace_tree(c) for c in node.children).reduce((a, d) -> a.concat(d))
        
        node.x = d3.mean(leaf_descendants, (d)->d.x)
        node.y = d3.mean(leaf_descendants, (d)->d.y)
            
        ### pass descendants up to the hierarchy ###
        return leaf_descendants
}