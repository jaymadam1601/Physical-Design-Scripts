proc get_box_length {box} {
    if {[llength $box] != 4} {
        puts "Error: Box must have 4 values: llx lly urx ury"
        return 0
    }   
    lassign $box _ lly _ ury 
    return [expr {$ury - $lly}]
}
proc get_box_width {box} {
    if {[llength $box] != 4} {
        puts "Error: Box must have 4 values: llx lly urx ury"
        return 0
    }
    lassign $box llx _ urx _
    return [expr {$urx - $llx}]
}

proc get_incremented_box {marker_box layer target_length} {
	set layer_direction [dbget [dbget head.layers.name $layer -p ].direction]
	set target_increment_box ""
	if {$layer_direction == "Horizontal"} {
		set marker_box_length [get_box_width $marker_box]
		set target_increment [expr ($target_length - $marker_box_length)/2]
		set target_incremented_box [lindex [dbShape $marker_box SIZEX $target_increment] 0]
	} elseif {$layer_direction == "Vertical"} {
		set marker_box_length [get_box_length $marker_box]
		set target_increment [expr ($target_length - $marker_box_length)/2]
		set target_incremented_box [lindex [dbShape $marker_box SIZEY $target_increment] 0]
	}
	return $target_incremented_box
}

proc fix_minimal_area {{file_name "fix_Minimal_area.tcl"}} {
	set fp [open $file_name w]
	puts $fp "setEditMode -create_via_on_pin 0"
	puts $fp "setEditMode -create_crossover_vias 0"
	puts $fp "setEditMode -rule Default"
	puts $fp "setEditMode -drc_on 1"
	set violation_layers [lsort [dbget [dbget top.markers.subType Minimal_Area -p ].layer.name -u]]
	foreach one_layer $violation_layers {
		set layer_width [dbget [dbget head.layers.name $one_layer -p ].width]
		puts $fp "setEditMode -layer_minimum $one_layer"
		puts $fp "setEditMode -layer_maximum $one_layer"
		puts $fp "setEditMode -layer_horizontal $one_layer"
		puts $fp "setEditMode -layer_vertical $one_layer"
		foreach one_violation [dbget [dbget top.markers.subType Minimal_Area -p ].layer.name $one_layer -p2 ] {
			set one_violation_box [dbget $one_violation.box]
			set layer_direction [dbget [dbget head.layers.name $one_layer -p ].direction]
			set new_one_violation_box ""
			if {$layer_direction == "Horizontal"} { 
				set new_one_violation_box [dbShape $one_violation_box SIZEY 0.0650]
			} elseif {$layer_direction == "Vertical"} {
				set new_one_violation_box [dbShape $one_violation_box SIZEX 0.0650]
			}
			set box_object_ptr [dbQuery -areas $new_one_violation_box -layers $one_layer -objType {sViaInst sWire viaInst wire} -enclosed_only ]
			set net_name [dbget $box_object_ptr.net.name -u]
			set net_status [dbget $box_object_ptr.status -u]
			set net_objType [dbget $box_object_ptr.objType -u]
			if {[regexp {^s.*} $net_objType]} {
				set net_objType special
			} elseif {[regexp {^p.*} $net_objType]} {
				set net_objType patch
			} else {
				set net_objType regular
			}
			puts $fp "setEditMode -nets $net_name -status $net_status"
			set target_len ""

			switch -- $one_layer {
				M8  { set target_len 0.3970 }
				M9  { set target_len 0.3955 }
				M10 { set target_len 0.4010 }
				M11 { set target_len 0.4145 }
				M12 { set target_len 0.3950 }
				M15 { set target_len 0.3640 }
				default {
				    puts "Skipping unknown layer: $one_layer"
				    continue  ;# Skip to next item in foreach
				}
			}
	 
			set fix_box [get_incremented_box [lindex $one_violation_box 0] $one_layer $target_len]
			puts $fp "editAddRoute [lindex $fix_box 0] [lindex $fix_box 1]"
			puts $fp "editCommitRoute [lindex $fix_box 2] [lindex $fix_box 3]"

		}
	}
	close $fp
}


#M8 -- 0.3970
#M9 -- 0.3955
#M10 -- 0.4010
#M11 -- 0.4145
#M12 -- 0.3950
#M15 -- 0.3640

