proc editStrechY {YU YD} {
	if {$YU == 0 && $YD == 0} {
		puts "Not resizing net [dbget selected.net.name] at [dbget selected.net.box]"
	} elseif {$YU == 0 && $YD != 0} {
		set new_YD [expr $YD * -1]
		editResize -direction y -offset $new_YD -side low -keep_center_line auto
	} elseif {$YU != 0 && $YD == 0} {
		editResize -direction y -offset $YU -side high -keep_center_line auto
	} elseif {$YU != 0 && $YD != 0} {
		set new_YD [expr $YD * -1]
		editResize -direction y -offset $YU -side high -keep_center_line auto
		editResize -direction y -offset $new_YD -side low -keep_center_line auto
	}
}
proc get_max_length_from_dbget {lengths} {

    if {[llength $lengths] == 0} {
        puts "No lengths found."
        return
    }

    set max_length [lindex $lengths 0]

    foreach len $lengths {
        if {$len > $max_length} {
            set max_length $len
        }
    }

    return $max_length
}

proc get_box_length {box} {
    if {[llength $box] != 4} {
        puts "Error: Box must contain exactly 4 values: llx lly urx ury"
        return
    }
    lassign $box _ lly _ ury
    set length [expr {$ury - $lly}]
    return $length
}
proc get_box_width {box} {
    if {[llength $box] != 4} {
        puts "Error: Box must contain exactly 4 values: llx lly urx ury"
        return
    }
    lassign $box llx _ urx _
    set width [expr {$urx - $llx}]
    return $width
}



proc increase_length_to_area {width current_length target_area {precision 4}} {
    if {$width <= 0} {
        puts "Error: Width must be greater than zero."
        return
    }
    set new_length [expr {$target_area / $width}]
    set increase [expr {$new_length - $current_length}]
    return [format "%.${precision}f" $increase]
}

foreach mark [dbget top.markers.userType M5.R.14 -p ] {
	set mark_box [dbget $mark.box]
	set mark_box_x [dbget $mark.box_sizex]
	set mark_box_y [dbget $mark.box_sizey]
	puts "$mark_box"	
	set new_length [increase_length_to_area $mark_box_x $mark_box_y 0.011]
	set mark_box_y_increase [expr {$new_length / 2}]
	set mark_box_increased [dbShape $mark_box SIZEY $mark_box_y_increase]
	set mark_box_increased_up [lindex [dbShape $mark_box_increased XOR $mark_box] 1]
	set mark_box_increased_down [lindex [dbShape $mark_box_increased XOR $mark_box] 0]
	set mark_box_increased_up_big [dbShape $mark_box_increased_up SIZEY 0.07]
	set mark_box_increased_down_big [dbShape $mark_box_increased_down SIZEY 0.07]
	set mark_box_up_up [lindex [dbShape $mark_box_increased_up_big XOR $mark_box_increased_up ] 1]
	set mark_box_down_down [lindex [dbShape $mark_box_increased_down_big XOR $mark_box_increased_down ] 0]
	deselectAll
	set up_objects [llength [dbQuery -areas $mark_box_up_up -layers {M5} -objType {wire pWire sWire}]]
	set down_objects [llength [dbQuery -areas $mark_box_down_down -layers {M5} -objType {wire pWire sWire}]]
	if {$up_objects != 0 && $down_objects != 0} {
		puts "$mark_box Cannot size $up_objects $down_objects"

	} elseif {$up_objects != 0} {
		puts "$mark_box Cannot size to up $up_objects"
	} elseif {$down_objects != 0} {
		puts "$mark_box Cannot size to down $down_objects"
	} else {
		deselectAll	
		select_obj [dbQuery -areas $mark_box -objType {wire pWire} -layers M5]
		if {[llength [dbget selected.objType -u]] == "2"} {
			set only_wire [dbget selected.objType wire -p ]
			deselectAll
			select_obj $only_wire
			puts "$mark_box Two [dbget selected.objType]"
		} elseif {[llength [dbget selected.objType -u]] == "1"} {
			foreach type {pWire wire} {
    				if {[dbget selected.objType -u] eq $type && [llength [dbget selected.objType]] > 1} {
       					set max_length [get_max_length_from_dbget [dbget selected.box_sizey]]
       			 		set longest_shape [dbget selected.box_sizey $max_length -p]
       			 		deselectAll
       			 		select_obj $longest_shape
       			 		break
    				}
			}
		}
		set wire_box [dbget selected.box]
		set wire_increse_up [lindex [dbShape $mark_box_increased XOR $wire_box] 1]
		set wire_increse_down [lindex [dbShape $mark_box_increased XOR $wire_box] 0]
		createMarker -bbox $wire_increse_up
		createMarker -bbox $wire_increse_down
		set up_size_length [get_box_length $wire_increse_up]
		set down_size_length [get_box_length $wire_increse_down]
		editStrechY $up_size_length $down_size_length
	}
	deselectAll	
}
