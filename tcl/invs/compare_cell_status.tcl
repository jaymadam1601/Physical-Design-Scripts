# compare_cells.tcl

if {[llength $argv] != 2} {
    puts "Usage: tclsh compare_cells.tcl <old_file> <new_file>"
    exit 1
}

set old_file [lindex $argv 0]
set new_file [lindex $argv 1]

# Read statuses from files into dictionaries
proc read_statuses {filename} {
    set status_dict [dict create]
    set f [open $filename r]
    while {[gets $f line] >= 0} {
        if {[regexp {set\s+cell_cord\((.+?)\)\s+\{(.+?)\}} $line -> cell status]} {
            dict set status_dict $cell $status
        }
    }
    close $f
    return $status_dict
}

set old_statuses [read_statuses $old_file]
set new_statuses [read_statuses $new_file]

# Compare and report changes
puts "Changed statuses:"
set found 0
foreach cell [dict keys $old_statuses] {
    if {[dict exists $new_statuses $cell]} {
        set old_val [dict get $old_statuses $cell]
        set new_val [dict get $new_statuses $cell]
        if {$old_val ne $new_val} {
            puts "$cell: $old_val → $new_val"
            set found 1
        }
    }
}

if {!$found} {
    puts "No differences found."
}

