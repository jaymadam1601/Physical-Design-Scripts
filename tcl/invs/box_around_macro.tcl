
proc distribute_density {llx lly urx ury overall_density sub_density} {
	set width  [expr {double($urx) - double($llx)}]
	set height [expr {double($ury) - double($lly)}]
	set area_big [expr {$width * $height}]

	# choose square size = smaller side
	set square_size [expr {($width < $height) ? $width : $height}]

	# number of sub-boxes in each direction
	set nx [expr {int(ceil($width  / $square_size))}]
	set ny [expr {int(ceil($height / $square_size))}]
	set total_sub [expr {$nx * $ny}]

	# sub-box area (ideal square size, may be smaller at edges)
	set area_sub [expr {$square_size * $square_size}]

	# how many sub-boxes should be filled
	set n_filled [expr {($sub_density > 0) ? round(($overall_density * $area_big) / ($sub_density * $area_sub)) : 0}]
	if {$n_filled > $total_sub} {
		set n_filled $total_sub
	}

	set results {}
	set count 0

	for {set i 0} {$i < $nx} {incr i} {
		for {set j 0} {$j < $ny} {incr j} {
			set x1 [expr {$llx + $i * $square_size}]
			set y1 [expr {$lly + $j * $square_size}]
			set x2 [expr {($x1 + $square_size < $urx) ? $x1 + $square_size : $urx}]
			set y2 [expr {($y1 + $square_size < $ury) ? $y1 + $square_size : $ury}]

			if {$count < $n_filled} {
				set d $sub_density
			} else {
				set d 0.0
			}
			lappend results [list $x1 $y1 $x2 $y2 $d]
			incr count
		}
	}

	return $results
}



proc box_around_box {bbox_list size_x size_y {side "XYF"}} {
	set input_bbox $bbox_list
	set result_boxes []
	if {$side == "X"} {
		set side_x_boxes [dbShape $input_bbox SIZEX $size_x XOR $input_bbox]
		set result_boxes $side_x_boxes
	} elseif {$side == "Y"} {
		set side_y_boxes [dbShape $input_bbox SIZEY $size_y XOR $input_bbox]
		set result_boxes $side_y_boxes
	} elseif {$side == "XY"} {
		set side_x_boxes [dbShape $input_bbox SIZEX $size_x XOR $input_bbox]
		set side_y_boxes [dbShape $input_bbox SIZEY $size_y XOR $input_bbox]
		set result_boxes [concat $side_x_boxes $side_y_boxes]
	} elseif {$side == "XYF"} { 
		set result_boxes [dbShape $input_bbox SIZEX $size_x SIZEY $size_y XOR $input_bbox]
	} else {
		puts "Error: Invalid side is given"
	}
	return $result_boxes
}

proc box_around_macro {macro_name size_x size_y {side "XYF"}} {
	set macro_bbox [dbget [dbget top.insts.name $macro_name -p].box]
	set result_boxes []
	if {$side == "X"} {
		set side_x_boxes [dbShape $macro_bbox SIZEX $size_x XOR $macro_bbox]
		set result_boxes $side_x_boxes
	} elseif {$side == "Y"} {
		set side_y_boxes [dbShape $macro_bbox SIZEY $size_y XOR $macro_bbox]
		set result_boxes $side_y_boxes
	} elseif {$side == "XY"} {
		set side_x_boxes [dbShape $macro_bbox SIZEX $size_x XOR $macro_bbox]
		set side_y_boxes [dbShape $macro_bbox SIZEY $size_y XOR $macro_bbox]
		set result_boxes [concat $side_x_boxes $side_y_boxes]
	} elseif {$side == "XYF"} {
		set result_boxes [dbShape $macro_bbox SIZEX $size_x SIZEY $size_y XOR $macro_bbox]
	} else {
		puts "Error: Invalid side is given"
	}
	return $result_boxes
}

proc box_around_macro_side {macro_name sides} {
	set macro_bbox [dbget [dbget top.insts.name $macro_name -p].box ]
	lassign $sides top bottom left right
	set result_boxes []
	if {$top != 0} {
		set top_box [lindex [dbShape [dbShape $macro_bbox SIZEY $top ] XOR $macro_bbox ] 1]
		lappend result_boxes $top_box
	}
	if {$bottom != 0} {
		set bottom_box [lindex [dbShape [dbShape $macro_bbox SIZEY $bottom ] XOR $macro_bbox ] 0]
		lappend result_boxes $bottom_box
	}
	if {$left != 0} {
		set left_box [lindex [dbShape [dbShape $macro_bbox SIZEX $left ] XOR $macro_bbox ] 0]
		lappend result_boxes $left_box
	}
	if {$right != 0} {
		set right_box [lindex [dbShape [dbShape $macro_bbox SIZEX $right ] XOR $macro_bbox ] 1]
		lappend result_boxes $right_box
	}
	return $result_boxes
}

proc marker_around_box {bbox_list size_x size_y {side "XYF"}} {
	set box_list [box_around_box $bbox_list $size_x $size_y $side]
	foreach bbox $box_list {
		createMarker -bbox $bbox
	}
}
proc density_screen_around_box {bbox_list size_x size_y density {side "XYF"} {name "density_around_box"}} {
	set box_list [box_around_box $bbox_list $size_x $size_y $side]
	foreach bbox $box_list {
		createPlaceBlockage -type partial -name "${name}_${side}" -density $density -box $bbox
	}
}
proc density_screen_around_macro {macro_name size_x size_y density {side "XYF"} {name "density_around_macro"}} {
	set macro_boxes [box_around_macro $macro_name $size_x $size_y $side]
	foreach bbox $macro_boxes {
		createPlaceBlockage -type partial -name "${name}_${side}" -density $density -box $bbox
	}
}
proc density_screen_around_macro_side {macro_name density sides {extended 0} {excludeFlops 0} {type "partial"}} {
	set macro_bbox [dbget [dbget top.insts.name $macro_name -p].box ]
	lassign $sides top bottom left right
	set extra_options ""
	if {$excludeFlops != 0} {
		set extra_options "-excludeFlops"
	}
	if {$top != 0} {
		set top_box [lindex [dbShape [dbShape [dbShape $macro_bbox SIZEY $top] SIZEX $extended] XOR [dbShape $macro_bbox SIZEX $extended]] 1]
		eval createPlaceBlockage -type $type -name "${macro_name}_top_density" -density $density -box $top_box $extra_options
	}
	if {$bottom != 0} {
		set bottom_box [lindex [dbShape [dbShape [dbShape $macro_bbox SIZEY $bottom] SIZEX $extended] XOR [dbShape $macro_bbox SIZEX $extended]] 0]
		eval createPlaceBlockage -type $type -name "${macro_name}_bottom_density" -density $density -box $bottom_box $extra_options
	}
	if {$left != 0} {
		set left_box [lindex [dbShape [dbShape [dbShape $macro_bbox SIZEX $left] SIZEY $extended] XOR [dbShape $macro_bbox SIZEY $extended]] 0]
		eval createPlaceBlockage -type $type -name "${macro_name}_left_density" -density $density -box $left_box $extra_options
	}
	if {$right != 0} {
		set right_box [lindex [dbShape [dbShape [dbShape $macro_bbox SIZEX $right] SIZEY $extended] XOR [dbShape $macro_bbox SIZEY $extended]] 1]
		eval createPlaceBlockage -type $type -name "${macro_name}_right_density" -density $density -box $right_box $extra_options
	}
}

proc marker_around_macro {macro_name size_x size_y {side "XYF"}} {
	set macro_boxes [box_around_macro $macro_name $size_x $size_y $side]
	foreach bbox $macro_boxes {
		createMarker -bbox $bbox
	}
}

proc density_near_ports {port_list port_side size_from_boundary width height density} {
	foreach one $port_list {
		selectIOPin $one
	}

	set llx 0; set lly 0; set urx 0; set ury 0;
	if {$port_side == "b"} {
		set llx [expr [lindex [lsort -dictionary [dbget selected.pt_x -u ] ] 0] - 5]
		set lly [dbget selected.pt_y -u]
		set urx [expr [lindex [lsort -dictionary [dbget selected.pt_x -u ] ] end] + 5]
		set ury $size_from_boundary
	} elseif {$port_side == "t"} {
		set llx [expr [lindex [lsort -dictionary [dbget selected.pt_x -u ] ] 0] - 5 ]
		set lly [expr [dbget selected.pt_y -u] - $size_from_boundary ]
		set urx [expr [lindex [lsort -dictionary [dbget selected.pt_x -u] ] end] + 5 ]
		set ury [dbget selected.pt_y -u]
	} elseif {$port_side == "l"} {
		set llx [dbget selected.pt_x -u]
		set lly [expr [lindex [lsort -dictionary [dbget selected.pt_y -u] ] 0] - 5]
		set urx [expr [dbget selected.pt_x -u] + $size_from_boundary]
		set ury [expr [lindex [lsort -dictionary [dbget selected.pt_y -u]] end] + 5]
	} elseif {$port_side == "r"} {
		set llx [expr [dbget selected.pt_x -u] - $size_from_boundary]
		set lly [expr [lindex [lsort -dictionary [dbget selected.pt_y -u] ] 0] - 5]
		set urx [dbget selected.pt_x -u]
		set ury [expr [lindex [lsort -dictionary [dbget selected.pt_y -u]] end] + 5]
	} else {
		puts "ERROR: Give right side , $port_side is not valid"
	}	
	puts "density_screen $llx $lly $urx $ury $width $height $density"
	density_screen $llx $lly $urx $ury $width $height $density
	
}



proc density_screen {x1 y1 x2 y2 x y density} {
	set a1 $x1
	set b1 $y1
	set a2 [expr $a1 + $x]
	set b2 [expr $b1 + $y]
	createPlaceBlockage -type partial -name pblkg_${x}by${y}_$density -density $density -box "$a1 $b1 $a2 $b2" -excludeFlops
	set j $x1
	set i $y1
	while {$i <= $y2} {
		while {$j < $x2} {
			set a1 [expr $a1 + $x]
			set a2 [expr $a1 + $x]
			set j $a2
			if {$a2 <= $x2} {
				createPlaceBlockage -type partial  -name pblkg_${x}by${y}_$density -density $density -box "$a1 $b1 $a2 $b2" -excludeFlops
			}
		}
		set b1 [expr $b1 + $y]
		set b2 [expr $b1 + $y]
		set i $b2
		set j $x1
		set a1 $x1
		set a2 [expr $a1 + $x]
		if {$b2 <= $y2} {
			createPlaceBlockage -type partial  -name pblkg_${x}by${y}_$density -density $density -box "$a1 $b1 $a2 $b2" -excludeFlops
		}
	}
}


