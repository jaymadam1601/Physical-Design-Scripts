source /home/scripts/tcl/invs/trace_backwards.tcl
source /home/scripts/tcl/invs/trace_forward.tcl

proc tbi {count} {
	set selected [dbget selected.name]
	tb $count [get_pins [dbget [dbget selected.instTerms.isInput 1 -p ].name ]]
	selectInst $selected
}

proc tfi {count} {
	set selected [dbget selected.name]
    tf $count [get_pins [dbget [dbget selected.instTerms.isOutput 1 -p ].name ]]
	selectInst $selected
}

proc tbp {count} {
    tb $count [get_ports [dbget selected.name ]]
}

proc tfp {count} {
    tf $count [get_ports [dbget selected.name ]]
}
