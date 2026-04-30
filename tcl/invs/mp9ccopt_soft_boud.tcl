set cell_names [exec grep -o "\{.*}" ../rpts/mp9Ccopt_const.tcl | sed -e "s/ /\r/g" | sed -e "s/}//g" -e "s/{//g" | sed -e "s./clk..g" -e "s./phi..g"] 
createInstGroup mp9Ccopt_cells_soft_bound
foreach one_cell $cell_names {
	set name [dbget top.insts.name $one_cell -e]
	if {$name!=""} {
		puts "Cell: $one_cell"
		set is_block [dbget [dbget top.insts.cell.baseClass block -p2 ].name $one_cell -e] 
		if {$is_block==""} {
			addInstToInstGroup mp9Ccopt_cells_soft_bound $one_cell
		}
	}
}
