puts "Usage: signal_en_check_dropped_nets \$net_list"

proc signal_en_check_dropped_nets {net_list} {
	foreach one $net_list {
		if {[lsearch [dbget [dbget top.nets.name $one -p ].instTerms.inst.cell.name  ] *AA_TIE*] != "-1"} {
			puts "TIECELL ==> $one"
		} elseif {[lsearch [dbget [dbget [dbget top.nets.name $one -p ].instTerms.isInput 1 -p ].inst.cell.baseClass block] block] != "-1"} {
			puts "MACROINPUT ==> $one"
		} else {
			puts "NET ==> $one"
		}
	}
}
