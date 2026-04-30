proc editStrechY {YU YD} {
    if {$YU == 0 && $YD == 0} {
        puts "Not resizing net [dbget selected.net.name] at [dbget selected.net.box]"
    } elseif {$YU == 0 && $YD != 0} {
        set new_YD [expr {$YD * -1}]
        editResize -direction y -offset $new_YD -side low -keep_center_line auto
    } elseif {$YU != 0 && $YD == 0} {
        editResize -direction y -offset $YU -side high -keep_center_line auto
    } elseif {$YU != 0 && $YD != 0} {
        set new_YD [expr {$YD * -1}]
        editResize -direction y -offset $YU -side high -keep_center_line auto
        editResize -direction y -offset $new_YD -side low -keep_center_line auto
    }
}

proc get_max_length_from_dbget {lengths} {
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
        return 0
    }
    lassign $box _ lly _ ury
    return [expr {$ury - $lly}]
}

proc get_box_width {box} {
    if {[llength $box] != 4} {
        puts "Error: Box must contain exactly 4 values: llx lly urx ury"
        return 0
    }
    lassign $box llx _ urx _
    return [expr {$urx - $llx}]
}

proc increase_length_to_area {width current_length target_area} {
    if {$width <= 0} {
        puts "Error: Width must be greater than zero."
        return 0
    }
    set new_length [expr {$target_area / $width}]
    set increase [expr {$new_length - $current_length}]
    return $increase
}

proc get_stretch_limits {box_increased box_original} {
    set increased_up [lindex [dbShape $box_increased XOR $box_original] 1]
    set increased_down [lindex [dbShape $box_increased XOR $box_original] 0]

    set up_big [dbShape $increased_up SIZEY 0.07]
    set down_big [dbShape $increased_down SIZEY 0.07]

    set up_delta [lindex [dbShape $up_big XOR $increased_up] 1]
    set down_delta [lindex [dbShape $down_big XOR $increased_down] 0]

    set can_stretch_up 1
    set can_stretch_down 1

    if {[llength [dbQuery -areas $up_delta -layers {M5} -objType {wire pWire sWire}]] != 0} {
        set can_stretch_up 0
    }
    if {[llength [dbQuery -areas $down_delta -layers {M5} -objType {wire pWire sWire}]] != 0} {
        set can_stretch_down 0
    }

    set up_len [get_box_length $increased_up]
    set down_len [get_box_length $increased_down]

    if {!$can_stretch_up} { set up_len 0 }
    if {!$can_stretch_down} { set down_len 0 }

    return [list $up_len $down_len]
}

set summary {}

foreach mark [dbget top.markers.userType M5.R.14 -p ] {
    set mark_box [dbget $mark.box]
    set mark_box_x [dbget $mark.box_sizex]
    set mark_box_y [dbget $mark.box_sizey]
    puts "$mark_box"

    set new_length [increase_length_to_area $mark_box_x $mark_box_y 0.0130]
    set mark_box_y_increase [expr {$new_length / 2}]
    set mark_box_increased [dbShape $mark_box SIZEY $mark_box_y_increase]

    deselectAll
    select_obj [dbQuery -areas $mark_box -objType {wire pWire} -layers M5 -enclosed_only]

    if {[llength [dbget selected.objType -u -e]] == 0} {
        append summary "\nMARK: $mark_box --> NO OBJECTS FOUND. SKIPPING."
        continue
    }

    if {[llength [dbget selected.objType -u -e]] == 2} {
        set only_wire [dbget selected.objType wire -p ]
        deselectAll
        select_obj $only_wire
    } elseif {[llength [dbget selected.objType -u -e]] == 1} {
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

    set wire_box_before [dbget selected.box]
    set wire_increse_up [lindex [dbShape $mark_box_increased XOR $wire_box_before] 1]
    set wire_increse_down [lindex [dbShape $mark_box_increased XOR $wire_box_before] 0]
    set up_size_length [get_box_length $wire_increse_up]
    set down_size_length [get_box_length $wire_increse_down]

    set limits [get_stretch_limits $mark_box_increased $mark_box]
    lassign $limits max_up max_down

    if {$up_size_length <= $max_up && $down_size_length <= $max_down} {
        editStrechY $up_size_length $down_size_length
	append summary "\nMARK: $mark_box --> Stretching [dbget selected.net.name] Up: $up_size_length Down: $down_size_length"
    } else {
        set fallback_up [expr {($up_size_length <= $max_up) ? $up_size_length : $max_up}]
        set fallback_down [expr {($down_size_length <= $max_down) ? $down_size_length : $max_down}]
        puts "$mark_box Stretch limited: requested=($up_size_length/$down_size_length), using=($fallback_up/$fallback_down)"
        editStrechY $fallback_up $fallback_down
	append summary "\nMARK: $mark_box --> Stretching [dbget selected.net.name] Up: $fallback_up Down: $fallback_down"
    }

    deselectAll
}

set fp [open "stretch_summary.txt" w]
puts $fp $summary
close $fp

