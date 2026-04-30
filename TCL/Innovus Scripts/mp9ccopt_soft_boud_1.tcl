set group_cells [exec grep -o "\{.*}" ../rpts/mp9Ccopt_const.tcl] 


set i 1

foreach one_group $group_cells {
	createInstGroup mp9Ccopt_cells_soft_bound_${i}
	foreach	cell $one_group {
		set one_cell [lindex [split $cell "/"] 0]
		set name [dbget top.insts.name $one_cell -e]
		if {$name!=""} {
        	set is_block [dbget [dbget top.insts.cell.baseClass block -p2 ].name $one_cell -e] 
        	if {$is_block==""} {
				addInstToInstGroup mp9Ccopt_cells_soft_bound_${i} $one_cell
        	}   
    	}
	}
	incr i
}

