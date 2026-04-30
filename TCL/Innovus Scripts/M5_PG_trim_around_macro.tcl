proc trim_m5_macro_pg {{sizey "0.105"}} {
	foreach one [dbget [dbget top.insts.cell.baseClass block -p2 ].box] {
		foreach one_two [dbShape $one SIZEY $sizey XOR $one] { 
			trim_pg -net {VDD VSS} -type stripe -layer M5 -area $one_two -pattern 0
		}
	}
}
select_obj  [dbget [dbget top.pgNets.sWires.layer.name M5 -p2 ].mask 0 -p]
editChangeMask -to 1
