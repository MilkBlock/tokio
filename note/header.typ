#let header = [
#set page(width: 8.5in, height: 11in, margin: 0.5in)
#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
  align: (x, y) => (
    if x > 0 { center }
    else { left }
  )
)
#set heading(numbering: "1.")
#set math.equation(numbering: "(1)")

]


