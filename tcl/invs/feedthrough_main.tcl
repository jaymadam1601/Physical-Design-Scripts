proc trace_from_reg {in_base reg_name visited path} {
	global fp
	set reg [get_cells -quiet -of_objects $reg_name]
	set reg_name [get_object_name $reg]
	if {[lsearch -exact $visited $reg_name] != -1} {
		return
	}
	set lib_cell [dbget [dbget top.insts.name $reg_name -p].cell.name]

	set visited [lappend visited $reg_name]
	set path    [lappend path "$reg_name $lib_cell"]
	set reg_all_pins [get_pins -quiet -of_objects $reg]
	set reg_out_pins [get_pins -quiet -of_objects $reg -filter "direction == out"]
	foreach_in_collection one_reg_out_pin $reg_out_pins {
		set one_reg_out_pin_fanout [all_fanout -from $one_reg_out_pin -endpoints_only]
		set one_reg_out_pin_fanout [remove_from_collection $one_reg_out_pin_fanout $reg_all_pins]

		set one_reg_out_pin_fanout_port [get_ports -quiet $one_reg_out_pin_fanout -filter "object_class==port"]
		set one_reg_out_pin_fanout_regs [get_cells -quiet -of_objects $one_reg_out_pin_fanout -filter "is_sequential==true && is_macro_cell==false"]
		set one_reg_out_pin_fanout_reg_pins [remove_from_collection $one_reg_out_pin_fanout $one_reg_out_pin_fanout_port]

		if {[sizeof_collection $one_reg_out_pin_fanout_regs] != 0} {
			foreach_in_collection one_reg_fanout_reg_pin $one_reg_out_pin_fanout_reg_pins {
				set reg_to_reg_fanout [all_fanout -from $one_reg_out_pin -to $one_reg_fanout_reg_pin]
				set reg_to_reg_fanout [remove_from_collection $reg_to_reg_fanout $reg_all_pins]
				set reg_to_reg_fanout [remove_from_collection $reg_to_reg_fanout $one_reg_fanout_reg_pin]

				set reg_to_reg_fanout_comb [get_cells -quiet -of_objects $reg_to_reg_fanout -filter "is_sequential==false && is_buffer==false && is_inverter==false"]

				if {[sizeof_collection $reg_to_reg_fanout_comb] != 0} {
					continue
				} else {
					trace_from_reg $in_base $one_reg_fanout_reg_pin $visited $path
				}
			}
		}
		if {[sizeof_collection $one_reg_out_pin_fanout_port] != 0} {
			foreach_in_collection one_port $one_reg_out_pin_fanout_port {
				set one_port_name [get_object_name $one_port]

				set reg_to_out_fanout [all_fanout -from $one_reg_out_pin -to $one_port]
				set reg_to_out_fanout [remove_from_collection $reg_to_out_fanout $one_reg_out_pin]
				set reg_to_out_fanout [remove_from_collection $reg_to_out_fanout $one_port]

				set reg_to_out_fanout_comb [get_cells -quiet -of_objects $reg_to_out_fanout -filter "is_sequential==false && is_buffer==false && is_inverter==false"]

				if {[sizeof_collection $reg_to_out_fanout_comb] != 0} {
					continue
				} else {
					set full_path [concat $in_base $path $one_port_name]
					puts $fp "IN to REG to OUT : [join $full_path { --> }]"
				}
			}
		}
	}
}


global fp
set fp [open "check1.tcl" w]

set in_ports [all_inputs -no_clocks] ; # To give only list of ports change here input should be collection

foreach_in_collection one_in $in_ports {
	set one_in_name [get_object_name $one_in]
	puts "$one_in_name"
	set fanout_endpoint [all_fanout -from $one_in -endpoints_only]
	set fanout_endpoint [remove_from_collection $fanout_endpoint $one_in]
	set fanout_endpoint_port [get_ports -quiet $fanout_endpoint -filter "object_class==port"]
	set fanout_endpoint_regs [get_cells -quiet -of_objects $fanout_endpoint -filter "is_sequential==true && is_macro_cell==false"]
	set fanout_endpoint_reg_pins [remove_from_collection $fanout_endpoint $fanout_endpoint_port]
	if {[sizeof_collection $fanout_endpoint_regs] != 0} {
		foreach_in_collection one_fanout_reg_pin $fanout_endpoint_reg_pins {
			set in_to_reg_fanout [all_fanout -from $one_in -to $one_fanout_reg_pin]
			set in_to_reg_fanout [remove_from_collection $in_to_reg_fanout $one_in]
			set in_to_reg_fanout [remove_from_collection $in_to_reg_fanout $one_fanout_reg_pin]
			set in_to_reg_fanout_comb [get_cells -quiet -of_objects $in_to_reg_fanout -filter "is_sequential==false && is_buffer==false && is_inverter==false"]
			if {[sizeof_collection $in_to_reg_fanout_comb] != 0} {
				continue
			} else {
				trace_from_reg $one_in_name $one_fanout_reg_pin {} {}
			}
		}
	}
	if {[sizeof_collection $fanout_endpoint_port] != 0} {
		foreach_in_collection one_fanout_port $fanout_endpoint_port {
			set one_fanout_port_name [get_object_name $one_fanout_port]
			set in_to_out_fanout [all_fanout -from $one_in -to $one_fanout_port]
			set in_to_out_fanout [remove_from_collection $in_to_out_fanout $one_in]
			set in_to_out_fanout [remove_from_collection $in_to_out_fanout $one_fanout_port]
			set in_to_out_fanout_comb [get_cells -quiet -of_objects $in_to_out_fanout -filter "is_sequential==false && is_buffer==false && is_inverter==false"]
			if {[sizeof_collection $in_to_out_fanout_comb] != 0} {
				continue
			} else {
				puts $fp "IN to OUT : $one_in_name --> $one_fanout_port_name"
			}
		}
	}
}

close $fp

