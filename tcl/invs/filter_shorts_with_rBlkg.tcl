deselectAll
set markers_pointers [dbget top.markers.subType Metal_Short -p ]
foreach i $markers_pointers {
	set b [dbget $i.message ]
	if {[regexp {Routing Blockage} $b]} {
		select_obj $i
	} 
}
editDelete -selected 
