foreach macro_one_box [dbget [dbget top.insts.cell.baseClass block -p2 ].box] {
	set outer_boundary_box [dbShape $macro_one_box SIZEX 1]
	set inner_boundary_box [dbShape $macro_one_box SIZEX -0.5]
	set middle_boxes [dbShape $outer_boundary_box XOR $inner_boundary_box ]
	foreach one $middle_boxes {
		createRouteBlk -name short_fix_route_blk -layer M7 -box $one
		createRouteBlk -name short_fix_route_blk -layer VIA7 -box $one
	}
	set outer_boxes [dbShape $macro_one_box SIZEX 6 SIZEY 2 XOR $macro_one_box]
	foreach one $outer_boxes {
		createPlaceBlockage -type partial -name short_fix_partial_blk -density 40 -box $one
	}
}
