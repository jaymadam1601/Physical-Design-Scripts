proc loaddebugtiming {path_group {type "setup"}} {
	set ::path_group_type $path_group
	set ::timing_check_type $type
    if {![info exists ::DESIGN]} {puts "ERROR: DESIGN variable not set."; return}
    set rpt_dir [exec sh -c {ls -d ../rpts/timing_* 2>/dev/null | tail -1}]
    if {$rpt_dir eq ""} {puts "ERROR: No timing report directory found."; return}
    set file "${rpt_dir}/${::DESIGN}_${type}_${path_group}.btarpt"
    if {![file exists $file]} {puts "ERROR: File not found: $file"; return}
    puts "Loading: $file"
    load_timing_debug_report $file
}

proc get_setup_slack {} {
	return [get_property [report_timing -from $::tps -to $::tps -through $::tpa  -collection -path_group $::path_group_type -late] slack]
}
proc get_hold_slack {} {
	return [get_property [report_timing -from $::tps -to $::tps -through $::tpa -collection -path_group $::path_group_type -early] slack]
}


set ::path_group_type ""
set ::timing_check_type ""
set ::current_path_index 1
set ::tpb {}
set ::tpi {}
set ::tps {}
set ::tpc {}
set ::tpa {}

proc highlight_current_path {} {
    global current_path_index
    global tpb tpi tps tpc tpa
    highlight_timing_report -path $current_path_index
    deselectAll
    select_highlighted -type instance
    set tpb [dbget -e [dbget selected.cell.isBuffer 1 -p2 ].name]
    set tpi [dbget -e [dbget selected.cell.isInverter 1 -p2 ].name]
    set tps [dbget -e [dbget selected.cell.isSequential 1 -p2 ].name]
    set tpc [dbget -e [dbget [dbget [dbget selected.cell.isSequential 0 -p2 ].cell.isBuffer 0 -p2 ].cell.isInverter 0 -p2 ].name]
    set tpa [concat $tpb $tpi $tpc]
	set setup_slack [get_setup_slack]
	set hold_slack  [get_hold_slack]
    puts "Highlighted Path Number: $current_path_index"
	puts "Setup Slack : $setup_slack , Hold Slack: $hold_slack"
	puts "Total Length: [llength [dbget selected.name]]"
    puts "  Buffers: [llength $tpb]"
	puts "  Inverters: [llength $tpi]" 
	puts "  Sequential: [llength $tps]"
	puts "  Combinational: [llength $tpc]"
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
