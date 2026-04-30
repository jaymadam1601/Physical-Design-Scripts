proc insert_buffer_near_driver_pin {pin_name cell_name {new_inst_name ""} {new_net_name ""}} {
	deselectAll
	selectPin $pin_name
	set to_place_on_pin [dbget selected.pt] 
	if {$new_inst_name != "" && $new_net_name != ""} {
		ecoAddRepeater -term $pin_name -cell $cell_name -name $new_inst_name -newNetName $new_net_name -loc $to_place_on_pin
	} elseif {$new_inst_name != "" && $new_net_name == ""} {
		ecoAddRepeater -term $pin_name -cell $cell_name -loc $to_place_on_pin -name $new_inst_name 
	} elseif {$new_inst_name == "" && $new_net_name != ""} {
		ecoAddRepeater -term $pin_name -cell $cell_name -loc $to_place_on_pin -newNetName $new_net_name
	} else {
		ecoAddRepeater -term $pin_name -cell $cell_name -loc $to_place_on_pin
	}
	deselectAll
}
