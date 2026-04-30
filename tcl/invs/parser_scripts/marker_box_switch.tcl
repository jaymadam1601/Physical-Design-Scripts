set current_index 0
set boxes {}
set current_box {}

proc load_marker_boxes {box_list} {
    global boxes current_index current_box
    set boxes $box_list
    set current_index 0
    set current_box {}
    puts "Boxes loaded manually. Total: [llength $boxes]"
    start_zoom_from_first
}

proc start_zoom_from_first {} {
    global current_index
    set current_index 0
    if {[zoom_current_box]} {
        puts "Zoomed to first box."
    } else {
        puts "No boxes to zoom."
    }
}

proc zoom_current_box {} {
    global boxes current_index current_box

    if {$current_index >= [llength $boxes]} {
        puts "No box at index $current_index"
        return 0
    }

    set coords [lindex $boxes $current_index]

    if {[llength $coords] != 4} {
        puts "Invalid coordinates at index $current_index: $coords"
        return 0
    }

    lassign $coords llx lly urx ury
    set current_box $coords
    puts "Zooming to Box $current_index: $llx $lly $urx $ury"
    zoomBox $llx $lly $urx $ury
	zoomOut
    return 1
}

proc move_box {direction} {
    global current_index boxes

    set total_boxes [llength $boxes]

    if {$direction eq "next"} {
        if {$current_index < $total_boxes - 1} {
            incr current_index
        } else {
            puts "Already at the last box."
            return
        }
    } elseif {$direction eq "prev"} {
        if {$current_index > 0} {
            incr current_index -1
        } else {
            puts "Already at the first box."
            return
        }
    } else {
        puts "Invalid direction. Use 'prev' or 'next'."
        return
    }

    zoom_current_box
}

proc boxnext {} {
    move_box "next"
}

proc boxprev {} {
    move_box "prev"
}

# Key bindings
bindkey Shift-> {boxnext}
bindkey Shift-< {boxprev}

set ICON_DIR "/home/Pictures/"
if {[uiFind main -label "Jay's Toolbar"] != ""} {
    uiDelete "Jay's Toolbar"
}
uiAdd "Jay's Toolbar" -type toolbar -in main -label "Jay's Toolbar"
uiAdd LeftToolButton -type toolbutton -in "Jay's Toolbar" -label "LeftToolButton" -tooltip "Previous Box" -icon [file join $ICON_DIR LeftArrow_150.svg] -command boxprev
uiAdd MiddleToolButton -type toolbutton -in "Jay's Toolbar" -label "MiddleToolButton" -tooltip "Go to First Box" -icon [file join $ICON_DIR MiddleRadio.svg] -command start_zoom_from_first
uiAdd RightToolButton -type toolbutton -in "Jay's Toolbar" -label "RigthToolButton" -tooltip "Next Box" -icon [file join $ICON_DIR RightArrow_150.svg] -command boxnext
