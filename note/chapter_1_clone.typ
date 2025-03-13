
// #import "header.typ" as header
// // #eval(header.header)
// #header.header
// #align(center, text(17pt)[
//   *Tokio Async Runtime 
//   *
// ])
// #align(center, text(12pt)[
//   *2025/3/4 v1.1
//   *
// ])
// = clone3 调用
// #image("./clone3_disas.png",width:50%)


// #let r = rect(width: 100% ,height:100pt)
// #r
// #r.fields()
// #let s = "a,b,c".split(",").join([ hello ])
// #s

// #sym.chi


// #import "@preview/codly:1.2.0": *
// #import "@preview/codly-languages:0.1.1": *
// #show: codly-init.with()

// #codly(languages: codly-languages)
// ```rust
// pub fn main() {
//     println!("Hello, world!");
// }
// ```


#import "@preview/fletcher:0.5.6" as fletcher: diagram, node, edge
#set page(width: auto,  margin: 5mm, fill: white)
#set text(white, font: "New Computer Modern")
#let colors = (maroon, olive, eastern)

#diagram(
	edge-stroke: 1pt,
	node-corner-radius: 5pt,
	edge-corner-radius: 8pt,
	mark-scale: 80%,
	node((0,0), [input], fill: colors.at(0)),
	node((2,+1), [memory unit (MU)], fill: colors.at(1)),
	node((2, 0), align(center)[arithmetic & logic \ unit (ALU)], fill: colors.at(1)),
	node((2,-1), [control unit (CU)], fill: colors.at(1)),
	node((4,0), [output], fill: colors.at(2), shape: fletcher.shapes.hexagon),

	edge((0,0), "r,u,r", "-}>"),
	edge((2,-1), "r,d,r", "-}>"),
	edge((2,-1), "r,dd,l", "--}>"),
	edge((2,1), "l", (1,-.5), marks: ((inherit: "}>", pos: 0.65, rev: false),)),

	for i in range(-1, 2) {
		edge((2,0), (2,1), "<{-}>", shift: i*5mm, bend: i*20deg)
	},

	edge((2,-1), (2,0), "<{-}>"),
)


// #import "@preview/alchemist:0.1.4": *

// #skeletize({
//   molecule(name: "A", "A")
//   single()
//   molecule("B")
//   branch({
//     single(angle: 1)
//     molecule(
//       "W",
//       links: (
//         "A": double(stroke: red),
//       ),
//     )
//     single()
//     molecule(name: "X", "X")
//   })
//   branch({
//     single(angle: -1)
//     molecule("Y")
//     single()
//     molecule(
//       name: "Z",
//       "Z",
//       links: (
//         "X": single(stroke: black + 3pt),
//       ),
//     )
//   })
//   single()
//   molecule(
//     "C",
//     links: (
//       "X": cram-filled-left(fill: blue),
//       "Z": single(),
//     ),
//   )
// })