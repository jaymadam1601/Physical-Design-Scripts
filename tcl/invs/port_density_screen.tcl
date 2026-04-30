proc get_group_cordinates {list_of_points max_gap min_count} {
	if {[llength $list_of_points] == 0} {
		return {}
	}
	set sorted_points [lsort -real $list_of_points]
	set groups {}
	set start_point [lindex $sorted_points 0]
	set prev_point $start_point
	set count 1
	foreach point $sorted_points {
		if {$point == $start_point} {
			continue
		}
		if {[expr {$point - $prev_point >= $max_gap}]} {
			if {$count >= $min_count} {
				lappend groups [list $start_point $prev_point]
			}
			set start_point $point
			set count 1
		} else {
			incr count
		}
		set prev_point $point
	}
	if {$count >= $min_count} {
		lappend groups [list $start_point $prev_point]
	}
	return $groups
}

proc density_screen {x1 y1 x2 y2 x y density} {
	set b1 $y1
	while {$b1 < $y2} {
		set b2 [expr {$b1 + $y}]
		if {$b2 > $y2} { set b2 $y2 } ;# adjust for last row
		set a1 $x1
		while {$a1 < $x2} {
			set a2 [expr {$a1 + $x}]
			if {$a2 > $x2} { set a2 $x2 } ;# adjust for last column
			createPlaceBlockage -type partial \
				-name pblkg_${x}by${y}_$density \
				-density $density \
				-box "$a1 $b1 $a2 $b2" \
				-excludeFlops
			set a1 $a2
		}
		set b1 $b2
	}
}


proc density_screen_around_all_ports {size_from_boundary {density "30"} {max_gap 10} {min_count 25} {internal_ports ""}} {
	set sides [dbget top.terms.side -u] ; # {botom top right left}
	foreach one_side $sides {
		deselectAll
		selectPin [dbget top.terms.side $one_side -p ]
		foreach one_internal_port $internal_ports {
			deselectPin $one_internal_port
		}
		if {$one_side == "South" || $one_side == "North"} {
			set common_ys [dbget selected.pt_y -u]
			foreach one_common_ys $common_ys {
				set points_groups [get_group_cordinates [dbget [dbget selected.pt_y $one_common_ys -p ].pt_x] $max_gap $min_count]
				foreach one $points_groups {
					set llx [lindex $one 0]
					set urx [lindex $one 1]
					set lly $one_common_ys
					set ury $one_common_ys
					if {$one_side == "South"} {
						set ury [expr $one_common_ys + $size_from_boundary] 
					} elseif {$one_side == "North"} {
						set lly [expr $one_common_ys - $size_from_boundary]
					}
					density_screen [expr $llx-10] $lly [expr $urx+10] $ury $size_from_boundary 5 $density
				}
			}
		} elseif {$one_side == "East" || $one_side == "West"} {
			set common_xs [dbget selected.pt_x -u]
			foreach one_common_xs $common_xs {
				set points_groups [get_group_cordinates [dbget [dbget selected.pt_x $one_common_xs -p ].pt_y] $max_gap $min_count]
				foreach one $points_groups {
					set lly [lindex $one 0]
					set ury [lindex $one 1]
					set llx $one_common_xs
					set urx $one_common_xs
					if {$one_side == "East"} {
						set llx [expr $one_common_xs - $size_from_boundary ]
					} elseif {$one_side == "West"} {
						set urx [expr $one_common_xs + $size_from_boundary]
					}
					density_screen $llx [expr $lly-10] $urx [expr $ury+10] 5 $size_from_boundary $density
				}
			}
		}
	}
	deselectAll
}
