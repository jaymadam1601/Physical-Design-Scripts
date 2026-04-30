puts "file content should be like below:"
puts "set nets(net1) \[list 1\]"
puts "set nets(net2) \[list 2\]"
puts "set nets(net3) \[list 3\]"
puts "source \$script"
puts "load_net_order \$file"


set current_index 0
array set nets {}
proc listadd L {expr [join $L +]+0}
proc load_net_order {file} {
    global nets
    array unset nets
    source $file
    puts "Loaded net order from $file"
    start_from_first
}
proc start_from_first {} {
    global current_index
    set current_index 0
    set first_net [get_current_key]
    if {$first_net ne ""} {
        puts "Starting from first net: $first_net"
        deselectAll
        selectNet $first_net
        zoomSelected
    } else {
        puts "No nets available to select."
    }
}
proc get_sorted_nets {} {
    global nets
    set keys [array names nets]
    return [lsort -real -increasing -index 1 [lmap net $keys {list $net $nets($net)}]]
}
proc get_current_key {} {
    global current_index
    set sorted_keys [get_sorted_nets]
    if {$current_index >= [llength $sorted_keys]} {
        return ""
    }
    set selected_net [lindex $sorted_keys $current_index]
    set net [lindex $selected_net 0]
    set order [lindex $selected_net 1]
    set fanout_count [llength [dbget [dbget top.nets.name $net -p].instTerms.isInput 1]]
	set net_length [listadd [dbget [dbget top.nets.name $net -p ].wires.length ]]
	set cell_name [dbget [dbget [dbget top.nets.name $net -p ].instTerms.isOutput 1 -p ].inst.name]
	set cell_ref_name [dbget [dbget [dbget top.nets.name $net -p ].instTerms.isOutput 1 -p ].inst.cell.name]
	puts ""
    puts "Net: $net -> $order "
	puts "Driver Cell Name: $cell_name"
	puts "Driver CellRef: $cell_ref_name"
	puts "Fanout : $fanout_count, NetLength : $net_length"
    return $net
}
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
        deselectAll
        selectNet $net
        zoomSelected
    }
}
proc movenext {} {move "next"}
proc moveprev {} {move "prev"}
bindkey Shift-> {movenext}
bindkey Shift-< {moveprev}
set ICON_DIR "/home/Pictures/"
if {[uiFind main -label "Jay's Net Switching Toolbar"] != ""} {
    uiDelete "Jay's Net Switching Toolbar"
} 
uiAdd "Jay's Net Switching Toolbar" -type toolbar -in main -label "Jay's Net Switching Toolbar"
uiAdd LeftToolButton -type toolbutton -in "Jay's Net Switching Toolbar" -label "LeftToolButton" -tooltip "Previous Net" -icon [file join $ICON_DIR LeftArrow_150.svg] -command moveprev 
uiAdd MiddleToolButton -type toolbutton -in "Jay's Net Switching Toolbar" -label "MiddleToolButton" -tooltip "Go to First Net" -icon [file join $ICON_DIR MiddleRadio.svg] -command start_from_first
uiAdd RightToolButton -type toolbutton -in "Jay's Net Switching Toolbar" -label "RigthToolButton" -tooltip "Next Net" -icon [file join $ICON_DIR RightArrow_150.svg] -command movenext
