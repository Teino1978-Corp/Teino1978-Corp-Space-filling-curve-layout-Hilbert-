tcmp = (a,b) ->
    children_a = (if a.children? then a.children else [])
    children_b = (if b.children? then b.children else [])
    for [ai, bi] in zip(children_a,children_b)
        ci = tcmp(ai,bi)
        if ci isnt 0
            return ci
    return children_b.length-children_a.length
    
rsort = (t) ->
    children = (if t.children? then t.children else [])
    for c in children
        rsort(c)
        
    children.sort(tcmp)
    
window.tree_utils = {
    ### sort the given unordered tree using a canonical ordering ###
    ### see Constant time generation of free trees - Wright et al. 1986 ###
    canonical_sort: (tree) ->
        rsort(tree)
        
    ### return the ordered sequence of leaves of a given tree ###
    get_leaves: (tree) ->
        seq = []
        parse_leaves = (node) ->
            if not node.children?
                seq.push node
            else
                for c in node.children
                    parse_leaves(c)
                    
        parse_leaves(tree)
        
        return seq
}