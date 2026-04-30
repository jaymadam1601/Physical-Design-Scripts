proc report_moved_cells {orig_coord_file} {
    if {[file exists $orig_coord_file]} {
        source $orig_coord_file
    } else {
        puts "Error: File '$orig_coord_file' not found."
        return
    }
    set fp [open "report_moved_cells" w]
    puts $fp "# Moved Instances (distance + new coordinates):"
    foreach inst_name [array names cell_cord] {
        foreach {ollx olly ourx oury} $cell_cord($inst_name) {break}
		if {[dbget top.insts.name $inst_name] == "0x0"} {puts $fp "# Warning: $inst_name not found in layout." ; continue }
        set current_bbox [dbget [dbget top.insts.name $inst_name -p].box]
        foreach {nllx nlly nurx nury} $current_bbox {break}
        if {$ollx != $nllx || $olly != $nlly || $ourx != $nurx || $oury != $nury} {
            set dx [expr {$nllx - $ollx}]
            set dy [expr {$nlly - $olly}]
            set dist [expr {sqrt($dx*$dx + $dy*$dy)}]
            set dist_fmt [format "%.1f" $dist]
            set bbox_fmt [format "{%.3f %.3f %.3f %.3f}" $nllx $nlly $nurx $nury]
            puts $fp "$inst_name moved: $dist_fmt units, new bbox = $bbox_fmt"
        }
    }
    close $fp
    puts "Report written to 'report_moved_cells'"
}
proc report_pstatus_changes {orig_pstatus_file} {
    if {![file exists $orig_pstatus_file]} {
        puts "Error: File '$orig_pstatus_file' not found."
        return
    }
    source $orig_pstatus_file
    set fp [open "report_pstatus_changes.txt" w]
    puts $fp "# Pstatus Changes (Old vs New):"
    foreach inst_name [array names cell_pstatus] {
        set old_status [string trim $cell_pstatus($inst_name) "{}"]
		if {[dbget top.insts.name $inst_name] == "0x0"} {puts $fp "# Warning: $inst_name not found in layout." ; continue }
        set new_status [dbget [dbget top.insts.name $inst_name -p].pstatus]
        if {$old_status ne $new_status} {
            puts $fp "$inst_name: $old_status -> $new_status"
        }
    }
    close $fp
    puts "Report written to 'report_pstatus_changes.txt'"
}

