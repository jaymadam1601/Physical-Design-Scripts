proc check_pin_constrained {pin_list} {
	foreach one $pin_list {
		set is_setup [sizeof_collection	[get_timing_paths -through $one ]] 
		set is_hold [sizeof_collection [get_timing_paths -through $one -delay_type min]]
		if {$is_setup == 0 && $is_hold == 0} {
			puts "Unconstrained $one"
		} elseif {$is_setup != 0 && $is_hold == 0} {
			puts "Setup Constrained $one"
		} elseif {$is_setup == 0 && $is_hold != 0} {
			puts "Hold Constrained $one"
		} elseif {$is_setup != 0 && $is_hold != 0} {
			puts "Constrained $one"
		}
	}
}
