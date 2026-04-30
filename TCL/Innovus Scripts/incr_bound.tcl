proc incr_bound {inst_list x y w h space incr} {
	set first_flag $incr
	set X1 $x
	set Y1 $y
	set X2 [expr {$x + $w}]
	set Y2 [expr {$y + $h}]
	
	while {$incr != 0} {
		createInstGroup incr_group_${incr} -region {X1 Y1 X2 Y2}
		if {$first_flag == $incr} {
			addInstToInstGroup incr_group_${incr} $inst_list
		} else {
			set fanin_tmp [all_fanout -from [get_pins -of_objects $inst_list -filter "direction==out"] -endpoint_only -only_cells]
			set fanin [remove_from_collection $fanin_tmp [get_cells $inst_list]]
			addInstToInstGroup incr_group_${incr} $fanin
			set inst_list $fanin
		}
		set incr [expr {$incr - 1}]
		set X1 [expr $X1 + $w + $space]
		set X2 [expr $X2 + $w + $space]
	}
}

#for {set i 1} {i<= $incr} {incr++} {
#	createInstGroup incr_group_${i} -region {X1 Y1 X2 Y2}
#	
#	if {$i == 1} {
#		addInstToInstGroup incr_group_${i} $inst_list
#	} else {
#		set fanin_tmp [all_fanout -from [get_pins -of_objects $inst_list -filter "direction==out"] -endpoint_only -only_cells]
#		set fanin [remove_from_collection $fanin_tmp [get_cells $inst_list]]
#		addInstToInstGroup incr_group_${i} $fanin
#		set inst_list $fanin
#	}
#	set X1 [expr $X1 + $w + $space]
#	set X2 [expr $X2 + $w + $space]
#}
