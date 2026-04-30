
proc get_propogated_noise_net_info {netNames} {
	puts "Net Driver(cell/port) RefName NetLength NetLayers"
	foreach onenetName $netNames {
		set time_path [report_timing -through $onenetName -collection]
		set time_path_nets [get_object_name [get_attribute $time_path nets]]
		foreach one_time_path_net $time_path_nets {
			set net_driver ""
			set net_driver_ref_name ""
			if {[dbget top.terms.name $one_time_path_net -e] == ""} {
				set net_driver [get_driver_of_net $one_time_path_net]
				set net_driver_ref_name [dbget [dbget top.insts.name $net_driver -p ].cell.name]
			} else {
				set net_driver "$one_time_path_net"
				set net_driver_ref_name "Port"
			}
			set net_layers [get_net_layer $one_time_path_net]
			set net_layers [join $net_layers ","]
			set net_length [get_net_length $one_time_path_net]
			if {$one_time_path_net == $netNames} {
				puts "-->$one_time_path_net $net_driver $net_driver_ref_name $net_length \{$net_layers\}"
			} else {
				puts "$one_time_path_net $net_driver $net_driver_ref_name $net_length \{$net_layers\}"
			}
		}
		puts ""
	}
}

proc listadd L {expr [join $L +]+0}
proc get_net_length {netName} {
	return [listadd [dbget  [dbget top.nets.name $netName -p ].wires.length ]]
}
proc get_net_length_on_layer {netName layer} {
	return [dbget [dbget [dbget top.nets.name $netName -p ].wires.layer.name $layer -p2 ].length]
}

proc get_net_layer {netName} {
	return "[dbget [dbget top.nets.name $netName -p ].wires.layer.name -u ]"
}
proc get_driver_of_net {netName} {
	return [dbget [dbget [dbget top.nets.name $netName -p ].instTerms.isOutput 1 -p ].inst.name]
}
proc get_net_layer_by_length {netName} {
    set net_layers [get_net_layer $netName]
    set net_length_map {}
    foreach one_net_layer $net_layers {
        set net_layer_length [get_net_length_on_layer $netName $one_net_layer]
        lappend net_length_map [list $one_net_layer $net_layer_length]
    }
    set sorted_layers [lsort -index 1 -real -decreasing $net_length_map]
    return [join [lmap layer_data $sorted_layers {lindex $layer_data 0}] " "]
}

proc print_net_layer_by_length {netName} {
    set net_layers [get_net_layer $netName]
    set net_length_map {}
	puts "$netName"
    foreach one_net_layer $net_layers {
        set net_layer_length [get_net_length_on_layer $netName $one_net_layer]
        puts "$one_net_layer [listadd $net_layer_length]"
    }   
}

