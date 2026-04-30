source /home/scripts/tcl/invs/marker_box_switch.tcl

set current_obj ""

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

proc increase_length_to_area {width current_length target_area} {
    if {$width <= 0} {
        puts "Error: Width must be greater than 0"
        return 0
    }
    set new_length [expr {$target_area / $width}]
    set increase [expr {$new_length - $current_length}]
    return $increase
}

proc select_object_from_current_box {} {
    global current_box
    global current_obj

    set current_obj {}
    deselectAll
    select_obj [dbQuery -areas $current_box -objType {wire pWire} -layers M5]

    if {[llength [dbget selected.objType -u -e]] == 2} {
        set only_wire [dbget selected.objType wire -p]
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

    set current_obj [dbget selected -e]
}

proc editStrechY {YU YD} {
    if {$YU == 0 && $YD == 0} {
        puts "Not resizing net [dbget selected.net.name] at [dbget selected.net.box]"
    } elseif {$YU == 0 && $YD != 0} {
        set new_YD [expr {$YD * -1}]
        editResize -direction y -offset $new_YD -side low -keep_center_line auto
    } elseif {$YU != 0 && $YD == 0} {
        editResize -direction y -offset $YU -side high -keep_center_line auto
    } else {
        set new_YD [expr {$YD * -1}]
        editResize -direction y -offset $YU -side high -keep_center_line auto
        editResize -direction y -offset $new_YD -side low -keep_center_line auto
    }
}

proc stretch_fully_selected_shape_to_current_box {} {
    global current_box
    global current_obj

    set wire_box_before [dbget selected.box]

    set width [get_box_width $current_box]
    set current_length [get_box_length $current_box]
    set target_area 0.0118

    set new_length [increase_length_to_area $width $current_length $target_area]
    set half_increase [expr {$new_length / 2}]
    set increased_box [dbShape $current_box SIZEY $half_increase]

    set wire_increase_up   [lindex [dbShape $increased_box XOR $wire_box_before] 1]
    set wire_increase_down [lindex [dbShape $increased_box XOR $wire_box_before] 0]

    set up_len   [get_box_length $wire_increase_up]
    set down_len [get_box_length $wire_increase_down]

    editStrechY $up_len 0
    select_obj $current_obj
    editStrechY 0 $down_len

    puts "Stretched fully: Up = $up_len, Down = $down_len"
}

proc select_and_strech {} {
    global current_obj
    select_object_from_current_box
    stretch_fully_selected_shape_to_current_box
}

set ICON_DIR "/home/Pictures/"
if {[uiFind main -label "Jay's Toolbar"] != ""} {
    uiDelete "Jay's Toolbar"
}
uiAdd "Jay's Toolbar" -type toolbar -in main -label "Jay's Toolbar"
uiAdd LeftToolButton -type toolbutton -in "Jay's Toolbar" -label "LeftToolButton" -tooltip "Previous Box" -icon [file join $ICON_DIR LeftArrow_150.svg] -command boxprev
uiAdd MiddleToolButton -type toolbutton -in "Jay's Toolbar" -label "MiddleToolButton" -tooltip "Select and strech" -icon [file join $ICON_DIR MiddleRadio.svg] -command select_and_strech
uiAdd RightToolButton -type toolbutton -in "Jay's Toolbar" -label "RigthToolButton" -tooltip "Next Box" -icon [file join $ICON_DIR RightArrow_150.svg] -command boxnext

