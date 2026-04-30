
proc trace_from_regs {fp all_regs path visited} {
	foreach_in_collection one_reg $all_regs {
		set reg_name [get_object_name $one_reg]
		# avoid loops
		if {[lsearch -exact $visited $reg_name] >= 0} {
			continue
		}
		set new_visited [lappend visited $reg_name]
		set reg_out_pins [get_pins -quiet -of_objects $one_reg -filter "direction==out"]
		foreach_in_collection one_reg_pin $reg_out_pins {
			set reg_fanout [all_fanout -from $one_reg_pin]
			set reg_fanout [remove_from_collection $reg_fanout $one_reg_pin]

			set reg_fanout_pins [get_pins -quiet $reg_fanout]
			set reg_fanout_comb [get_cells -quiet -of_objects $reg_fanout_pins -filter "is_sequential==false && is_buffer==false && is_inverter==false"]
			set reg_fanout_regs [get_cells -quiet -of_objects $reg_fanout_pins -filter "is_sequential==true && is_macro_cell==false"]
			set reg_fanout_mems [get_cells -quiet -of_objects $reg_fanout_pins -filter "is_sequential==true && is_macro_cell==true"]
			set reg_fanout_port [get_ports -quiet $reg_fanout -filter "object_class==port"]

			set reg_comb_cnt [sizeof_collection $reg_fanout_comb]
			set reg_mems_cnt [sizeof_collection $reg_fanout_mems]
			if {$reg_comb_cnt != 0 || $reg_mems_cnt != 0} {
				continue
			}

			set reg_regs_count [sizeof_collection $reg_fanout_regs]
			set reg_port_count [sizeof_collection $reg_fanout_port]
			if {$reg_regs_count == 0 && $reg_port_count == 0} {
				continue   ;# dead end
			}

			# ----------------------------
			# Case: reg → OUT port
			# ----------------------------
			if {$reg_regs_count == 0 && $reg_port_count != 0} {
				foreach_in_collection one_reg_port $reg_fanout_port {
					puts $fp "In - reg - out : $path -> $reg_name -> [get_object_name $one_reg_port]"
				}
				continue
			}

			# ----------------------------
			# Case: reg → more regs
			# ----------------------------
			if {$reg_regs_count != 0} {
				trace_from_regs $fp $reg_fanout_regs $path $new_visited
			}
		}
	}
}


set fp [open "if_feedthrough.tcl" w]

set in_ports [all_inputs -no_clocks]

foreach_in_collection one_in $in_ports {
	set fanout [all_fanout -from $one_in]
	set fanout [remove_from_collection $fanout $one_in]

	set fanout_pins		[get_pins -quiet $fanout]
	set fanout_comb		[get_cells -quiet -of_objects $fanout_pins -filter "is_sequential==false && is_buffer==false && is_inverter==false"]
	set fanout_regs		[get_cells -quiet -of_objects $fanout_pins -filter "is_sequential==true && is_macro_cell==false"]
	set fanout_mems		[get_cells -quiet -of_objects $fanout_pins -filter "is_sequential==true && is_macro_cell==true"]
	set fanout_buff_invs   [get_cells -quiet -of_objects $fanout_pins -filter "is_sequential==false && (is_buffer==true || is_inverter==true)"]
	set fanout_port		[get_ports -quiet $fanout -filter "object_class==port"]

	set comb_cnt [sizeof_collection $fanout_comb]
	set mem_cnt  [sizeof_collection $fanout_mems]

	if {$comb_cnt != 0 || $mem_cnt != 0} {
		puts $fp "Port [get_object_name $one_in] -> Conected to Comb or Mem"
		continue
	}

	set regs_cnt [sizeof_collection $fanout_regs]
	set port_cnt [sizeof_collection $fanout_port]

	if {$regs_cnt == 0 && $port_cnt == 0} {
		puts $fp "Input NOT CONNECTED: [get_object_name $one_in]"
	} elseif {$regs_cnt == 0 && $port_cnt != 0} {
		foreach_in_collection one_port $fanout_port {
			puts $fp "IN-TO-OUT PATH: [get_object_name $one_in] -> [get_object_name $one_port]"
		}
	} elseif {$regs_cnt != 0} {
		set base_path [get_object_name $one_in]
		trace_from_regs $fp $fanout_regs $base_path [list ]
	}
}

close $fp



