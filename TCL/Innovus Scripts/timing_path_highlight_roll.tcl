set ::current_path_index 1
set ::tpb {}
set ::tpi {}
set ::tps {}
set ::tpc {}
set ::tpa {}
set ::tpln {}
proc listadd L {expr [join $L +]+0}

proc get_common_nets_between_cells {cell1 cell2} {
    set pins1 [get_object_name [get_pins -of_objects [get_cells $cell1]]]
    set pins2 [get_object_name [get_pins -of_objects [get_cells $cell2]]]
    set nets1 [get_object_name [get_nets -of_objects $pins1]]
    set nets2 [get_object_name [get_nets -of_objects $pins2]]
    set common {}
    foreach n1 $nets1 {
        if {[lsearch -exact $nets2 $n1] != -1} {
            lappend common $n1
        }
    }
    return [lsort -unique $common]
}

proc find_common_nets {all_cells} {
    set results {}
    set n [llength $all_cells]
    for {set i 0} {$i < $n} {incr i} {
        set c1 [lindex $all_cells $i]
        for {set j [expr {$i+1}]} {$j < $n} {incr j} {
            set c2 [lindex $all_cells $j]
            set common [get_common_nets_between_cells $c1 $c2]
            if {[llength $common] > 0} {
                foreach net $common {
                    lappend results $net
                }
            }
        }
    }
    return [lsort -unique $results]
}

proc find_longest_net {nets} {
	global tpln
    set max_len -1
    set max_net ""
    foreach net $nets {
        set net_length [listadd [dbget [dbget top.nets.name $net -p].wires.length]]
        if {$net_length > $max_len} {
            set max_len $net_length
            set max_net $net
        }
    }
    if {$max_net ne ""} {
		set tpln $max_net
		puts "Longest net = $max_net"
		puts "  Longest net length = $max_len"
    } else {
        puts "No nets found"
    }
}

proc highlight_current_path {} {
    global current_path_index
    global tpb tpi tps tpc tpa tpln
    highlight_timing_report -path $current_path_index
    deselectAll
    select_highlighted -type instance
    set tpb [dbget -e [dbget selected.cell.isBuffer 1 -p2 ].name]
    set tpi [dbget -e [dbget selected.cell.isInverter 1 -p2 ].name]
    set tps [dbget -e [dbget selected.cell.isSequential 1 -p2 ].name]
    set tpc [dbget -e [dbget [dbget [dbget selected.cell.isSequential 0 -p2 ].cell.isBuffer 0 -p2 ].cell.isInverter 0 -p2 ].name]
    set tpa [concat $tpb $tpi $tpc]
    puts "Highlighted Path Number: $current_path_index"
	puts "Total Length: [llength [dbget selected.name]]"
    puts "  Buffers: [llength $tpb]"
	puts "  Inverters: [llength $tpi]" 
	puts "  Sequential: [llength $tps]"
	puts "  Combinational: [llength $tpc]"
	deselectAll
	selectInst $tpa
	selectInst $tps 
	set tpnets [find_common_nets [dbget selected.name ]]
	find_longest_net $tpnets
	deselectAll
	selectInst $tpa
}
proc start_from_first_timing_path {} {
    global current_path_index
    set current_path_index 1
    highlight_current_path
}
proc next_path {} {
    global current_path_index
    incr current_path_index
    highlight_current_path
}
proc prev_path {} {
    global current_path_index
    if {$current_path_index > 1} {
        incr current_path_index -1
        highlight_current_path
    } else {
        puts "Already at the first path. Cannot go back further."
    }
}

proc play_path {range {delay_ms 1000}} {
    global current_path_index

    if {[regexp {^(\d+)-(\d+)$} $range -> start end]} {
        if {$start > $end} {
            puts "Invalid range: start ($start) > end ($end)"
            return
        }
        for {set i $start} {$i <= $end} {incr i} {
            set current_path_index $i
            highlight_current_path
            update
            after $delay_ms
        }
    } else {
        puts "Invalid format. Use: play_path N-M ?delay_ms?"
    }
}


bindkey Shift-> {next_path}
bindkey Shift-< {prev_path}
set ICON_DIR "/home/Pictures/"
if {[uiFind main -label "Jay's Timing Path Parser Toolbar"] != ""} {
    uiDelete "Jay's Timing Path Parser Toolbar"
}
uiAdd "Jay's Timing Path Parser Toolbar" -type toolbar -in main -label "Jay's Timing Path Parser Toolbar"
uiAdd LeftToolButton -type toolbutton -in "Jay's Timing Path Parser Toolbar" -label "LeftToolButton_for_timing_path" -tooltip "Highlight Previous Timing Path" -icon [file join $ICON_DIR LeftArrow_150.svg] -command prev_path
uiAdd MiddleToolButton -type toolbutton -in "Jay's Timing Path Parser Toolbar" -label "MiddleToolButton_for_timing_path" -tooltip "Go to First Timing Path" -icon [file join $ICON_DIR MiddleRadio.svg] -command start_from_first_timing_path
uiAdd RightToolButton -type toolbutton -in "Jay's Timing Path Parser Toolbar" -label "RigthToolButton_for_timing_path" -tooltip "Highlight Next Timing Path" -icon [file join $ICON_DIR RightArrow_150.svg] -command next_path

puts "Usage: 1. load_timing_debug_report ../rpts/timing_0*/particular_path_groub.btarpt"
puts "       2. start_from_first_timing_path"
puts "       3. Shift-> or next_path and Shift-< or prev_path"
puts "Extra features --> play_path <range> ; <range> = 1-10 or 1-100 etc."

