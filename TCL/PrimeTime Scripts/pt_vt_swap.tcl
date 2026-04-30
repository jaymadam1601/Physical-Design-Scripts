proc vt_swap {startpoint endpoint} {
	set fp [open "undo_vt_swap.tcl" a+]
	puts $fp ""
	puts $fp "#New vt_swap"
	set cell_list [get_object_name [get_cells -of_objects [get_attribute [get_attribute [get_timing_paths -from $startpoint -to $endpoint] points] object]]]
	set cell_list_length [llength $cell_list]
	for {set i 1} {$i < [expr {$cell_list_length - 1}]} {incr i} {
		set one_cell_ref_name [get_attribute [get_cells [lindex $cell_list $i]] ref_name]
		if {[string match *LL* $one_cell_ref_name]} {
			regsub {LL} $one_cell_ref_name {LN} new_one_cell_ref_name
			puts $fp "size_cell [lindex $cell_list $i] $one_cell_ref_name"
			size_cell [lindex $cell_list $i] $new_one_cell_ref_name; # $one_cell_ref_name ---> $new_one_cell_ref_name
		} elseif {[string match *LN* $one_cell_ref_name]} {
			puts $fp "size_cell [lindex $cell_list $i] $one_cell_ref_name"
			regsub {LN} $one_cell_ref_name {UL} new_one_cell_ref_name
			size_cell [lindex $cell_list $i] $new_one_cell_ref_name; # $one_cell_ref_name ---> $new_one_cell_ref_name
		} elseif {[string match *UL* $one_cell_ref_name]} {
			puts $fp "size_cell [lindex $cell_list $i] $one_cell_ref_name"
			regsub {UL} $one_cell_ref_name {UN} new_one_cell_ref_name
			size_cell [lindex $cell_list $i] $new_one_cell_ref_name; # $one_cell_ref_name ---> $new_one_cell_ref_name
		} elseif {[string match *UN* $one_cell_ref_name]} {
			puts $fp "size_cell [lindex $cell_list $i] $one_cell_ref_name"
			regsub {UN} $one_cell_ref_name {EN} new_one_cell_ref_name
			size_cell [lindex $cell_list $i] $new_one_cell_ref_name; # $one_cell_ref_name ---> $new_one_cell_ref_name
		}
	}
	close $fp
}

proc get_vt_swap {startpoint endpoint} {
    set fp [open "undo_vt_swap.tcl" a+] 
	puts $fp ""
    puts $fp "#New vt_swap"
    set cell_list [get_object_name [get_cells -of_objects [get_attribute [get_attribute [get_timing_paths -from $startpoint -to $endpoint] points] object]]]
    set cell_list_length [llength $cell_list]
    for {set i 1} {$i < [expr {$cell_list_length - 1}]} {incr i} {
        set one_cell_ref_name [get_attribute [get_cells [lindex $cell_list $i]] ref_name]
        if {[string match *LL* $one_cell_ref_name]} {
            regsub {LL} $one_cell_ref_name {LN} new_one_cell_ref_name
            puts $fp "size_cell [lindex $cell_list $i] $one_cell_ref_name"
            puts "size_cell [lindex $cell_list $i] $new_one_cell_ref_name; # $one_cell_ref_name ---> $new_one_cell_ref_name"
        } elseif {[string match *LN* $one_cell_ref_name]} {
            puts $fp "size_cell [lindex $cell_list $i] $one_cell_ref_name"
            regsub {LN} $one_cell_ref_name {UL} new_one_cell_ref_name
            puts "size_cell [lindex $cell_list $i] $new_one_cell_ref_name; # $one_cell_ref_name ---> $new_one_cell_ref_name"
        } elseif {[string match *UL* $one_cell_ref_name]} {
            puts $fp "size_cell [lindex $cell_list $i] $one_cell_ref_name"
            regsub {UL} $one_cell_ref_name {UN} new_one_cell_ref_name
            puts "size_cell [lindex $cell_list $i] $new_one_cell_ref_name; # $one_cell_ref_name ---> $new_one_cell_ref_name"
        } elseif {[string match *UN* $one_cell_ref_name]} {
            puts $fp "size_cell [lindex $cell_list $i] $one_cell_ref_name"
            regsub {UN} $one_cell_ref_name {EN} new_one_cell_ref_name
            puts "size_cell [lindex $cell_list $i] $new_one_cell_ref_name; # $one_cell_ref_name ---> $new_one_cell_ref_name"
        }
    }   
    close $fp 
}

