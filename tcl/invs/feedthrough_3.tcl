############################################
# Helper procedures
############################################

proc split_endpoints {endpoints} {
	set ports [get_ports -quiet $endpoints -filter "object_class==port"]
	set reg_pins [remove_from_collection $endpoints $ports]
	return [list $ports $reg_pins]
}

proc is_comb_free {objs} {
	set comb [get_cells -quiet -of_objects $objs -filter "is_sequential==false && is_buffer==false && is_inverter==false"]
	return [expr {[sizeof_collection $comb] == 0}]
}

############################################
# Recursive REG traversal
############################################

proc trace_from_reg {in_base reg_name visited path} {
	global fp

	set reg [get_cells -quiet -of_objects $reg_name]
	set reg_name [get_object_name $reg]

	# loop / reconvergence protection (per input)
	if {[lsearch -exact $visited $reg_name] != -1} {
		return
	}

	# get lib cell name
	set lib_cell [dbget [dbget top.insts.name $reg_name -p].cell.name]
	set visited [lappend visited $reg_name]
	set path    [lappend path "$reg_name $lib_cell"]

	set reg_all_pins [get_pins -quiet -of_objects $reg]
	set reg_out_pins [get_pins -quiet -of_objects $reg -filter "direction==out"]

	foreach_in_collection reg_out_pin $reg_out_pins {
		set fanout [all_fanout -from $reg_out_pin -endpoints_only]
		set fanout [remove_from_collection $fanout $reg_all_pins]

		lassign [split_endpoints $fanout] fanout_ports fanout_reg_pins

		# REG -> REG
		foreach_in_collection reg_pin $fanout_reg_pins {
			set r2r [all_fanout -from $reg_out_pin -to $reg_pin]
			set r2r [remove_from_collection $r2r $reg_all_pins]
			set r2r [remove_from_collection $r2r $reg_pin]
			if {[is_comb_free $r2r]} {
				trace_from_reg $in_base $reg_pin $visited $path
			}
		}

		# REG -> OUT
		foreach_in_collection port $fanout_ports {
			set port_name [get_object_name $port]

			set r2o [all_fanout -from $reg_out_pin -to $port]
			set r2o [remove_from_collection $r2o $reg_out_pin]
			set r2o [remove_from_collection $r2o $port]
			if {[is_comb_free $r2o]} {
				set full_path [concat $in_base $path $port_name]
				puts $fp "IN to REG to OUT : [join $full_path { --> }]"
			}
		}
	}
}

############################################
# Main driver
############################################

global fp
set fp [open "check1.tcl" w]

set in_ports [all_inputs -no_clocks]

foreach_in_collection one_in $in_ports {
	set one_in_name [get_object_name $one_in]

	set fanout [all_fanout -from $one_in -endpoints_only]
	set fanout [remove_from_collection $fanout $one_in]
	lassign [split_endpoints $fanout] fanout_ports fanout_reg_pins

	# IN -> REG
	foreach_in_collection reg_pin $fanout_reg_pins {
		set i2r [all_fanout -from $one_in -to $reg_pin]
		set i2r [remove_from_collection $i2r $one_in]
		set i2r [remove_from_collection $i2r $reg_pin]
		if {[is_comb_free $i2r]} {
			trace_from_reg $one_in_name $reg_pin {} {}
		}
	}

	# IN -> OUT
	foreach_in_collection port $fanout_ports {
		set port_name [get_object_name $port]
		set i2o [all_fanout -from $one_in -to $port]
		set i2o [remove_from_collection $i2o $one_in]
		set i2o [remove_from_collection $i2o $port]
		if {[is_comb_free $i2o]} {
			puts $fp "IN to OUT : $one_in_name --> $port_name"
		}
	}
}

close $fp

