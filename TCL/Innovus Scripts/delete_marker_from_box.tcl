proc is_marker_inside_box {main_box marker} {
    lassign $main_box LLX_main LLY_main URX_main URY_main
    lassign $marker LLX_m LLY_m URX_m URY_m
    set is_inside [expr {
        $LLX_m >= $LLX_main && $URX_m <= $URX_main &&
        $LLY_m >= $LLY_main && $URY_m <= $URY_main
    }]
    set is_bigger [expr {
        ($URX_m - $LLX_m) > ($URX_main - $LLX_main) ||
        ($URY_m - $LLY_m) > ($URY_main - $LLY_main)
    }]

    if {$is_inside && !$is_bigger} {
        return 1  ;# Delete marker
    } else {
        return 0  ;# Keep marker
    }
}


proc delete_marker_inside_box {main_box} {
	set fp [open "delete_marker.tcl" w]
	puts "[llength $main_box]"
	foreach one [dbget top.markers] {
		set marker [lindex [dbget $one.box] 0]
		puts "[llength $marker]"
		set orgin [dbget $one.userOriginator]
		set usertype [dbget $one.userType]
		set do_delete [is_marker_inside_box $main_box $marker]
		if {$do_delete} {
			puts $fp "violationBrowserDelete -tool $orgin -type $usertype -violation $one"
		}
	}
	close $fp
}
