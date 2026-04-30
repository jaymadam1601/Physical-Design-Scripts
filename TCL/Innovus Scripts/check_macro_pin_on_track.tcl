proc check_macro_pin_on_track {macro_name} {
	set macro_pins_on_track ""
	set macro_pins_not_on_track ""
	set fp [open "macro_pins_track_check.rpt" w]
		foreach one_macro $macro_name {
			foreach one_pin [dbget [dbget top.insts.name $one_macro -p ].instTerms] {
				set one_pin_name [dbget $one_pin.name]
				set one_pin_layer [dbget $one_pin.layer.name]
				set pin_layer_direction [dbget [dbget head.layers.name $one_pin_layer -p ].direction]
				set pin_cordinate 0
				set pin_layer_pitch 0 
				if {$pin_layer_direction == "Horizontal"} {
					set pin_cordinate [dbget $one_pin.pt_y]
					set pin_layer_pitch [dbget [dbget head.layers.name $one_pin_layer -p ].pitchX]
				} elseif {$pin_layer_direction == "Vertical"} {
					set pin_cordinate [dbget $one_pin.pt_x]
					set pin_layer_pitch [dbget [dbget head.layers.name $one_pin_layer -p ].pitchY]
				}
				
				set pin_pt_divide [expr {fmod($pin_cordinate, $pin_layer_pitch)}]
				if {$pin_pt_divide == 0 || [expr $pin_layer_pitch / 2 ] == $pin_pt_divide} {
					lappend macro_pins_not_on_track $one_pin_name
				} else {
					lappend macro_pins_on_track $one_pin_name
				}
			}
		}
	close $fp
}
