############################################################
# Noise Navigation Script — Visibility Driven Debug
############################################################

set current_index 0
array set noise {}

proc listadd L {expr [join $L +]+0}

############################################################
# Load Noise File
############################################################

proc load_noise_order {file} {
    global noise
    array unset noise
    source $file
    puts "Loaded noise data from $file"
    start_from_first
}

############################################################
# Get Sorted Victim Nets
############################################################

proc get_sorted_nets {} {
    global noise

    set keys [array names noise]

    # victim net is before comma
    set nets [lsort -unique [lmap k $keys {lindex [split $k ,] 0}]]

    return $nets
}

############################################################
# Collect Aggressors
############################################################

proc get_aggressors {net} {
    global noise

    set aggr_list {}

    foreach k [array names noise "${net},*"] {
        lappend aggr_list {*}$noise($k)
    }

    return [lsort -unique $aggr_list]
}

############################################################
# Core Debug Controller
############################################################

proc show_noise_net {net} {

    set aggr_list [get_aggressors $net]

    # Select victim + aggressors
    deselectAll
    selectNet [concat $net $aggr_list]

    # Make only these nets visible
    set_visible_nets [dbget selected.name]
	deselectAll
	selectNet $net
	puts $aggr_list

    zoomSelected
}

############################################################
# Print Net Info
############################################################

proc get_current_key {} {

    global current_index noise

    set sorted_keys [get_sorted_nets]

    if {$current_index >= [llength $sorted_keys]} {
        return ""
    }

    set net [lindex $sorted_keys $current_index]

    # Cache db object (faster)
    set netObj [dbget top.nets.name $net -p]

    set fanout_count [llength [dbget $netObj.instTerms.isInput 1]]
    set net_length   [listadd [dbget $netObj.wires.length]]

    set cell_name \
        [dbget [dbget $netObj.instTerms.isOutput 1 -p].inst.name]

    set cell_ref_name \
        [dbget [dbget $netObj.instTerms.isOutput 1 -p].inst.cell.name]

    puts ""
    puts "Net: $net"
    puts "Driver Cell Name: $cell_name"
    puts "Driver CellRef: $cell_ref_name"
    puts "Fanout : $fanout_count, NetLength : $net_length"

    return $net
}

############################################################
# Start Navigation
############################################################

proc start_from_first {} {

    global current_index

    set current_index 0
    set first_net [get_current_key]

    if {$first_net ne ""} {
        puts "Starting from first net: $first_net"
        show_noise_net $first_net
    } else {
        puts "No nets available to select."
    }
}

############################################################
# Navigation Engine
############################################################

proc move {direction} {

    global current_index

    set sorted_keys [get_sorted_nets]
    set total_keys [llength $sorted_keys]

    if {$direction eq "next"} {

        if {$current_index < $total_keys - 1} {
            incr current_index
        } else {
            puts "Already at the last net."
            return
        }

    } elseif {$direction eq "prev"} {

        if {$current_index > 0} {
            incr current_index -1
        } else {
            puts "Already at the first net."
            return
        }

    } else {

        puts "Invalid direction. Use 'prev' or 'next'."
        return
    }

    set net [get_current_key]

    if {$net ne ""} {
        show_noise_net $net
    }
}

proc movenext {} { move "next" }
proc moveprev {} { move "prev" }

bindkey Shift-> {movenext}
bindkey Shift-< {moveprev}

############################################################
# Restore Full Visibility (VERY Useful)
############################################################

proc show_all_nets {} {
    set_visible_nets -all
    puts "All nets are now visible."
}


set ICON_DIR "/home/Pictures/"
if {[uiFind main -label "Jay's Net Switching Toolbar"] != ""} {
    uiDelete "Jay's Net Switching Toolbar"
} 
uiAdd "Jay's Net Switching Toolbar" -type toolbar -in main -label "Jay's Net Switching Toolbar"
uiAdd LeftToolButton -type toolbutton -in "Jay's Net Switching Toolbar" -label "LeftToolButton" -tooltip "Previous Net" -icon [file join $ICON_DIR LeftArrow_150.svg] -command moveprev 
uiAdd MiddleToolButton -type toolbutton -in "Jay's Net Switching Toolbar" -label "MiddleToolButton" -tooltip "Go to First Net" -icon [file join $ICON_DIR MiddleRadio.svg] -command start_from_first
uiAdd RightToolButton -type toolbutton -in "Jay's Net Switching Toolbar" -label "RigthToolButton" -tooltip "Next Net" -icon [file join $ICON_DIR RightArrow_150.svg] -command movenext
