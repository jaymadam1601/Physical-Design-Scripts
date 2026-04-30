proc add_buffer_at_driver {driver_pins buffer_name prefix i} {
	foreach one $driver_pins {
	if {[dbget [dbget top.insts.instTerms.name $one -p ].isOutput] == "1"} {
    	set pin_point [dbget [dbget top.insts.instTerms.name $one -p ].pt]
    	ecoAddRepeater -term $one -cell $buffer_name -loc $pin_point -name ${prefix}_cell_${i} -newNetName ${prefix}_net_${i}
		set nets [dbget [dbget top.insts.name ${prefix}_cell_${i} -p ].instTerms.net.name]
		foreach one_net $nets {
			editDelete -nets $one_net
			setAttribute -net $one_net -top_preferred_routing_layer M13 -bottom_preferred_routing_layer M10 -preferred_routing_layer_effort high -preferred_extra_space 1
		}
    	incr i
	}
	}
}

add_buffer_at_driver $topnoisepins P6L8B_BUFX8 manual_eco_TOP_NOISE_FIX_0131 0
