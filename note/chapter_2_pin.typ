#import "@preview/fletcher:0.5.6" as fletcher: diagram, node, edge
#set page(width: auto, height: auto, margin: 5mm, fill: white)
// #set text(white, font: "New Computer Modern")
#let colors = (maroon, olive, eastern)
// #set node(fill:colors.at(0)) 
// #show metadata: data => {
//   [hello this is a meta data ]
// }

#diagram(
	edge-stroke: 1pt,
	node-corner-radius: 5pt,
	edge-corner-radius: 8pt,
	mark-scale: 150%,
  node-fill: colors.at(0),
  render: (grid, nodes, edges, options) => {
    let nodes = nodes.map(node => {
      node.label = [#set text(fill:white) 
      #node.label]
      node
    })
    let edges = edges.map(edge => {
      edge.label = [#set text(fill:black) 
      #edge.label]
      edge
    })
		fletcher.cetz.canvas(fletcher.draw-diagram(grid, nodes, edges, debug: options.debug))
	},
  node((0,0), [
    = T:unpin
    type with unpin trait 
  ]), 
  node((1,0), [
    = T: !unpin
    type without unpin trait 
  ]),
  node((0.5,1), [
    = pin\<T\>
    struct 

  ],shape:fletcher.shapes.circle
  ),
  edge((0,0),(0.5,1),[],"=>",),
  edge((1,0),(0.5,1),[],"=>"),
)
  // #node((0,0), [ = T:unpin
  //   type with unpin trait 
  // ]) <node>
  // #query(<node>).label