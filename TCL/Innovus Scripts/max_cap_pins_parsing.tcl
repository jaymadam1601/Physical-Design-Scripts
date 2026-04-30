puts "File content should be like below:"
puts "set max_cap_pins(1) \[list pin1 -0.051\]"
puts "set max_cap_pins(2) \[list pin2 -0.033\]"
puts "set max_cap_pins(3) \[list pin3 -0.032\]"

set current_index 0
array set max_cap_pins {}

proc load_max_cap_pins {file} {
    global max_cap_pins
    array unset max_cap_pins
    source $file
    puts "Loaded max_cap pin data from $file"
    start_from_first_cap_pin
}

proc start_from_first_cap_pin {} {
    global current_index
    set current_index 0
    set first_pin [get_current_cap_pin]
    if {$first_pin ne ""} {
        puts "Starting from first pin: $first_pin"
    } else {
        puts "No pins available to navigate."
    }
}

proc get_sorted_cap_pins {} {
    global max_cap_pins
    set keys [array names max_cap_pins]
    return [lsort -integer $keys]
}

proc get_current_cap_pin {} {
    global current_index max_cap_pins
    set sorted_keys [get_sorted_cap_pins]
    if {$current_index >= [llength $sorted_keys]} {
        return ""
    }
    set key [lindex $sorted_keys $current_index]
    lassign $max_cap_pins($key) pin_name cap_val
    puts ""
    puts "Pin Index : $key"
    puts "Pin Name  : $pin_name"
    puts "Cap Slack : $cap_val"
	set net [dbget [dbget top.insts.instTerms.name $pin_name -p ].net.name]
	set fanout_count [llength [dbget [dbget top.nets.name $net -p].instTerms.isInput 1]]
	set net_length [listadd [dbget [dbget top.nets.name $net -p ].wires.length ]]
	set cell_name [dbget [dbget [dbget top.nets.name $net -p ].instTerms.isOutput 1 -p ].inst.name]
	set cell_ref_name [dbget [dbget [dbget top.nets.name $net -p ].instTerms.isOutput 1 -p ].inst.cell.name]
    puts "Net: $net"
    puts "Driver Cell Name: $cell_name"
    puts "Driver CellRef: $cell_ref_name"
    puts "Fanout : $fanout_count, NetLength : $net_length"
    return $pin_name
}

proc move_cap_pin {direction} {
    global current_index max_cap_pins
    set sorted_keys [get_sorted_cap_pins]
    set total [llength $sorted_keys]

    if {$direction eq "next"} {
        if {$current_index < $total - 1} {
            incr current_index
        } else {
            puts "Already at the last pin."
            return
        }
    } elseif {$direction eq "prev"} {
        if {$current_index > 0} {
            incr current_index -1
        } else {
            puts "Already at the first pin."
            return
        }
    } else {
        puts "Invalid direction. Use 'next' or 'prev'."
        return
    }

    set pin [get_current_cap_pin]
    if {$pin ne ""} {
        # Optional tool commands (uncomment if needed)
        # deselectAll
        # selectPin $pin
        # zoomSelected
		deselectAll
		selectPin $pin
		zoomSelected
    }
}

proc movenextcap {} {move_cap_pin "next"}
proc moveprevcap {} {move_cap_pin "prev"}

bindkey Shift-> {movenextcap}
bindkey Shift-< {moveprevcap}

set ICON_DIR "/home/Pictures/"
if {[uiFind main -label "Jay's Max Cap pin Switching Toolbar"] != ""} {
    uiDelete "Jay's Max Cap pin Switching Toolbar"
}
uiAdd "Jay's Max Cap pin Switching Toolbar" -type toolbar -in main -label "Jay's Max Cap pin Switching Toolbar"
uiAdd LeftToolButton -type toolbutton -in "Jay's Max Cap pin Switching Toolbar" -label "LeftToolButton" -tooltip "Previous MaxCap Pin" -icon [file join $ICON_DIR LeftArrow_150.svg] -command moveprevcap
uiAdd MiddleToolButton -type toolbutton -in "Jay's Max Cap pin Switching Toolbar" -label "MiddleToolButton" -tooltip "Go to First MaxCap Pin" -icon [file join $ICON_DIR MiddleRadio.svg] -command start_from_first_cap_pin
uiAdd RightToolButton -type toolbutton -in "Jay's Max Cap pin Switching Toolbar" -label "RigthToolButton" -tooltip "Next MaxCap Pin" -icon [file join $ICON_DIR RightArrow_150.svg] -command movenextcap
