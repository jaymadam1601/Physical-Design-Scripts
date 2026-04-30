proc level_1_fanin_cell {cell_name} {
	set fanin_level_1_cell [dbget [dbget [dbget [dbget top.insts.name $cell_name -p ].instTerms.isInput 1 -p ].net.instTerms.isOutput 1 -p ].inst.name]
	return $fanin_level_1_cell
}
proc level_1_fanin_net {cell_name} {
	set fanin_level_1_net [dbget [dbget [dbget [dbget top.insts.name $cell_name -p ].instTerms.isInput 1 -p ].net.instTerms.isOutput 1 -p2 ].name]
	return $fanin_level_1_net
}
proc level_1_fanout_cell {cell_name} {
	set fanout_level_1_cell [dbget [dbget [dbget [dbget top.insts.name $cell_name -p ].instTerms.isOutput 1 -p ].net.instTerms.isInput 1 -p ].inst.name]
	return $fanout_level_1_cell
}
proc level_1_fanout_net {cell_name} {
	set fanout_level_1_net  [dbget [dbget [dbget [dbget top.insts.name $cell_name -p ].instTerms.isOutput 1 -p ].net.instTerms.isInput 1 -p2 ].name]
	return $fanout_level_1_net
}
proc get_mid_point_of_cells {cell_name_1 cell_name_2} {
	set cell_name_1_boxllx [dbget [dbget top.insts.name $cell_name_1 -p ].box_llx]
	set cell_name_1_boxlly [dbget [dbget top.insts.name $cell_name_1 -p ].box_lly]
	set cell_name_2_boxllx [dbget [dbget top.insts.name $cell_name_2 -p ].box_llx]
	set cell_name_2_boxlly [dbget [dbget top.insts.name $cell_name_2 -p ].box_lly]
	set new_cell_boxllx [expr {($cell_name_1_boxllx + $cell_name_2_boxllx) / 2.0}]
	set new_cell_boxlly [expr {($cell_name_1_boxlly + $cell_name_2_boxlly) / 2.0}]
	return "$new_cell_boxllx $new_cell_boxlly"
}
puts "Usage: check_inout_add_buffer \$cell_name insert_buffer_ref_name"
proc check_inout_add_buffer {cells insert_buffer_ref_name} {
	set fp [open "eco_add_buffer.tcl" w]
	foreach cell_name $cells {
		set fanin_level_1_cell [level_1_fanin_cell $cell_name]
		set fanin_level_1_net [level_1_fanin_net $cell_name]

		if {[string match "agPORTISO*" $fanin_level_1_cell]} {
			puts $fp "ecoAddRepeater -cell $insert_buffer_ref_name -net $fanin_level_1_net -loc \"[get_mid_point_of_cells $cell_name $fanin_level_1_cell]\" -name DRIVE_BUF_cell_${fanin_level_1_net} -newNetName DRIVE_BUF_net_${fanin_level_1_net}"
		} 
		#elseif {[string match "GFIX_DMSA_20252305*" $fanin_level_1_cell] && [string match "GFIX_DMSA_20250904*" $cell_name]} {
		#	puts $fp "ecoAddRepeater -cell $insert_buffer_ref_name -net $fanin_level_1_net -loc \"[get_mid_point_of_cells $cell_name $fanin_level_1_cell]\" -name DRIVE_BUF_cell_${fanin_level_1_net} -newNetName DRIVE_BUF_net_${fanin_level_1_net}"
		#}

		set fanout_level_1_cell [level_1_fanout_cell $cell_name]
		set fanout_level_1_cell_ref [dbget [dbget [dbget [dbget top.insts.name $cell_name -p ].instTerms.isOutput 1 -p ].net.instTerms.isInput 1 -p ].inst.cell.name]
		set fanout_level_1_net  [level_1_fanout_net $cell_name]
		set new_fanout_cell_boxll [dbget [dbget top.insts.name $fanout_level_1_cell -p ].box_ll]

		#if {![string match "*DLY*" $fanout_level_1_cell_ref] && ![string match "GFIX*" $fanout_level_1_cell]} {
			puts $fp "ecoAddRepeater -cell $insert_buffer_ref_name -net $fanout_level_1_net -loc $new_fanout_cell_boxll -name DRIVE_BUF_cell_${fanout_level_1_net} -newNetName DRIVE_BUF_net_${fanout_level_1_net}"
		#}
		#elseif {[string match "GFIX_DMSA_20252305*" $fanout_level_1_cell]} {
		#	puts $fp "ecoAddRepeater -cell $insert_buffer_ref_name -net $fanout_level_1_net -loc $new_fanout_cell_boxll -name DRIVE_BUF_cell_${fanout_level_1_net} -newNetName DRIVE_BUF_net_${fanout_level_1_net}"
		#}
	}
	close $fp
}

proc only_at_iso_and_cell {cells insert_buffer_ref_name} {
	set fp [open "eco_add_buffer.tcl" w]
	foreach cell_name $cells {
		set fanin_level_1_cell [level_1_fanin_cell $cell_name]
		set fanin_level_1_net [level_1_fanin_net $cell_name]

		if {[string match "agPORTISO*" $fanin_level_1_cell]} {
			puts $fp "ecoAddRepeater -cell $insert_buffer_ref_name -net $fanin_level_1_net -loc \"[get_mid_point_of_cells $cell_name $fanin_level_1_cell]\" -name DRIVE_BUF_cell_${fanin_level_1_net} -newNetName DRIVE_BUF_net_${fanin_level_1_net}"
		} 
		#elseif {[string match "GFIX_DMSA_20252305*" $fanin_level_1_cell] && [string match "GFIX_DMSA_20250904*" $cell_name]} {
		#	puts $fp "ecoAddRepeater -cell $insert_buffer_ref_name -net $fanin_level_1_net -loc \"[get_mid_point_of_cells $cell_name $fanin_level_1_cell]\" -name DRIVE_BUF_cell_${fanin_level_1_net} -newNetName DRIVE_BUF_net_${fanin_level_1_net}"
		#}

		set fanout_level_1_cell [level_1_fanout_cell $cell_name]
		set fanout_level_1_cell_ref [dbget [dbget [dbget [dbget top.insts.name $cell_name -p ].instTerms.isOutput 1 -p ].net.instTerms.isInput 1 -p ].inst.cell.name]
		set fanout_level_1_net  [level_1_fanout_net $cell_name]
		set new_fanout_cell_boxll [dbget [dbget top.insts.name $fanout_level_1_cell -p ].box_ll]

		if {![string match "*DLY*" $fanout_level_1_cell_ref] && ![string match "GFIX*" $fanout_level_1_cell]} {
			puts $fp "ecoAddRepeater -cell $insert_buffer_ref_name -net $fanout_level_1_net -loc $new_fanout_cell_boxll -name DRIVE_BUF_cell_${fanout_level_1_net} -newNetName DRIVE_BUF_net_${fanout_level_1_net}"
		}
		#elseif {[string match "GFIX_DMSA_20252305*" $fanout_level_1_cell]} {
		#	puts $fp "ecoAddRepeater -cell $insert_buffer_ref_name -net $fanout_level_1_net -loc $new_fanout_cell_boxll -name DRIVE_BUF_cell_${fanout_level_1_net} -newNetName DRIVE_BUF_net_${fanout_level_1_net}"
		#}
	}
	close $fp
}
