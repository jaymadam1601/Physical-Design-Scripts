source /home/scripts/tcl/invs/procs.tcl

proc highlight_path {args} {
    parse_proc_arguments -args $args results
    if {[info exists results(-dehighlight)]} {
        dehighlight
    }
    deselectAll
    set startpoint $results(-from)
    set startpoint_type [get_object_type $startpoint]
    if {$startpoint_type == "pin"} {
        set start [get_db [get_cells -of_objects $startpoint] .name]
    } elseif {$startpoint_type == "inst"} {
	set start [get_db [get_cells $startpoint] .name]
	set startpoint [get_db [get_pins -of_objects $startpoint -filter "direction==out"] .name] 
    } else {
        set start $startpoint
    }
    if {[info exists results(-to)]} {
        set endpoint $results(-to)
        set endpoint_type [get_object_type $endpoint]
        if {$endpoint_type == "pin"} {
            set end [get_db [get_cells -of_objects $endpoint] .name]
        } elseif {$endpoint_type == "inst"} {
	    set end [get_db [get_cells $endpoint] .name]
	    set endpoint [get_db [get_pins -of_objects $endpoint -filter "direction==in"] .name]
	} else {
            set end $endpoint
        }
        set net_of_path [get_nets -of_objects [all_fanout -from $startpoint -to $endpoint]]
        set cell_of_path [all_fanout -from $startpoint -to $endpoint -only_cells]
    } else {
        set net_of_path [get_nets -of_objects [all_fanout -from $startpoint]]
        set cell_of_path [all_fanout -from $startpoint -only_cells]
    }
    if {![info exists results(-color)]} {
        set results(-color) "yellow"
    }
    highlight -color $results(-color) "$net_of_path $cell_of_path"
    highlight -color red $start
    if {[info exist result(-to)]} {
		highlight -color blue $end
    }
    deselectAll
}
define_proc_arguments highlight_path -info "Command Description" \
   -define_args {
   { -from "startpoint" "" string required}
   {-to "endpoint" "" string optional}
   {-dehighlight "dehighlight all objects before highlighting" "" boolean optional}
   {-color "Color of timing path" "" string optional}
}

proc hp {from to} {
	highlight_path -from $from -to $to
}

proc hpd {from to} {
	highlight_path -from $from -to $to -dehighlight
}

