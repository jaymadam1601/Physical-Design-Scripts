proc cell_size {inst_name sizeto {type "invs"}} {
	set inst_ref_name [dbget [dbGet top.insts.name $inst_name -p ].cell.name]
	set find_ref_name "[lindex [split $inst_ref_name "X"] 0]X*"
	set ref_found [lsort -dictionary [dbget head.libCells.name $find_ref_name]]
	set inst_ref_index [lsearch $ref_found $inst_ref_name]
	set new_inst_ref_index 0 
	if {$sizeto == "up"} {
		set new_inst_ref_index [expr $inst_ref_index + 1 ]
	} elseif {$sizeto == "down"} {
		set new_inst_ref_index [expr $inst_ref_index - 1 ]
	}
	if {[lindex $ref_found $new_inst_ref_index] != ""} {
		if {$type == "invs"} {
			puts "ecoChangeCell -inst $inst_name -cell [lindex $ref_found $new_inst_ref_index]"
		} elseif {$type == "pt"} {
			puts "size_cell $inst_name [lindex $ref_found $new_inst_ref_index]"
		} else {
			puts "#SIZE_CELL: INFO type given other then invs/pt"
		}
	} else {
		puts "#SIZE_CELL: INFO $inst_name cannot be $sizeto sized "
	}
}
proc up_size {inst_name {type "invs"}} {
	foreach one $inst_name {
		cell_size $one up $type
	}
}
proc down_size {inst_name {type "invs"}} {
	foreach one $inst_name {
		cell_size $inst_name down $type
	}
}

puts "Usage: up_size cellname invs/pt"
puts "Usage: down_size cellname invs/pt"
