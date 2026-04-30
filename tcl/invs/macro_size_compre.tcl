set fp [open "macro_area_compare.rpt" w]

selectInst [dbget [dbget top.insts.cell.baseClass block -p2 ].name]
foreach one [dbget selected] {
 set name [dbget $one.cell.name]
 set sizex [dbget $one.box_sizex]
 set sizey [dbget $one.box_sizey]
 set area [dbget $one.area] 
puts $fp "$name,$sizex,$sizey,$area"
 }

close $fp
