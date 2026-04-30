# ========================
# Global color counter
# ========================
set ::highlight_color 0

proc next_color {} {
    set ::highlight_color [expr {($::highlight_color + 1) % 16}]
    return $::highlight_color
}

# Store the visited chain here
set ::highlight_chain {}

# Helper: if object is a pin, get its cell name
proc resolve_to_cell_if_pin {obj} {
    if {[sizeof_collection [get_pins -quiet $obj]]} {
        return [get_cells -of_objects [get_pins -quiet $obj]]
    }
    return $obj
}

# ========================
# Backward trace to port
# ========================
proc highlight_back_to_port {startpoint} {
    global highlight_chain
    set curr $startpoint
    set visited {}
    while {![sizeof_collection [get_ports -quiet $curr]]} {
        if {[lsearch -exact $visited $curr] != -1} {
            puts "⚠ Loop detected while tracing backward at $curr. Stopping."
            break
        }
        lappend visited $curr
        lappend highlight_chain $curr

        puts "Tracing backward from: $curr"
        set new_rpt [report_timing -to $curr -collection]
        report_timing -to $curr -output_format binary > tmp_check
        load_timing_debug_report tmp_check
        highlight_timing_report -path 1 -color_index [next_color] -append

        set info [get_startpoint_endpoint_info $new_rpt]
        set new_sp [resolve_to_cell_if_pin [dict get $info startpoint]]

        if {$new_sp eq $curr || $new_sp eq ""} {
            puts "⚠ No further backward trace possible from $curr."
            break
        }
        set curr $new_sp
    }
    lappend highlight_chain $curr
    puts "Reached startpoint port: $curr"
}

# ========================
# Forward trace to port
# ========================
proc highlight_forward_to_port {endpoint} {
    global highlight_chain
    set curr $endpoint
    set visited {}
    while {![sizeof_collection [get_ports -quiet $curr]]} {
        if {[lsearch -exact $visited $curr] != -1} {
            puts "⚠ Loop detected while tracing forward at $curr. Stopping."
            break
        }
        lappend visited $curr
        lappend highlight_chain $curr

        puts "Tracing forward from: $curr"
        set new_rpt [report_timing -from $curr -collection]
        report_timing -from $curr -output_format binary > tmp_check
        load_timing_debug_report tmp_check
        highlight_timing_report -path 1 -color_index [next_color] -append

        set info [get_startpoint_endpoint_info $new_rpt]
        set new_ep [resolve_to_cell_if_pin [dict get $info endpoint]]

        if {$new_ep eq $curr || $new_ep eq ""} {
            puts "⚠ No further forward trace possible from $curr."
            break
        }
        set curr $new_ep
    }
    lappend highlight_chain $curr
    puts "Reached endpoint port: $curr"
}

# ========================
# Main proc to highlight both sides
# ========================
proc highlight_path_both_sides {path_obj} {
    global highlight_chain
    set highlight_chain {}

    set info [get_startpoint_endpoint_info $path_obj]
    set startpoint [resolve_to_cell_if_pin [dict get $info startpoint]]
    set endpoint   [resolve_to_cell_if_pin [dict get $info endpoint]]

    # Highlight main path first with a unique color
    puts "Highlighting main path from $startpoint to $endpoint..."
    report_timing -from $startpoint -to $endpoint -output_format binary > tmp_check
    load_timing_debug_report tmp_check
    highlight_timing_report -path 1 -color_index [next_color]
    lappend highlight_chain $startpoint
    lappend highlight_chain $endpoint

    # Backward trace if needed
    if {![dict get $info sp_is_port]} {
        highlight_back_to_port $startpoint
    } else {
        puts "Startpoint $startpoint is already a port."
    }

    # Forward trace if needed
    if {![dict get $info ep_is_port]} {
        highlight_forward_to_port $endpoint
    } else {
        puts "Endpoint $endpoint is already a port."
    }

    # Print final chain
    puts "\n=== Path Chain ==="
    foreach elem [lsort -unique $highlight_chain] {
        puts $elem
    }
    puts "=================="
}

