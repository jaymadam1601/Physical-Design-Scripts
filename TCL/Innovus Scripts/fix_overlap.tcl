puts "JM_INFO: Generating place status file changing ....."
set fp1 [open "after_place.tcl" w]
set fp2 [open "before_place.tcl" w]
deselectAll
set overlapbox [dbget [dbget [dbget top.markers.originator CheckPlace -p ].subType SPOverlapViolation -p ].box]
foreach one $overlapbox {
	selectInst [dbQuery -areas $one -objType inst -enclosed_only]
}
foreach one [dbget [dbget selected.isPhysOnly 1 -p ].name -e ] {
deselectInst $one
}
foreach	one [dbget [dbget selected.cell.baseClass block -p2 ].name -e ] {
deselectInst $one
}
if {[llength [dbget selected.name]] != 0} {
	foreach one [dbget selected] {
	set pstatus [dbget $one.pstatus]
	set name [dbget $one.name]
	puts $fp1 "dbSet \[dbGet top.insts.name $name -p \].pstatus $pstatus"
	puts $fp2 "dbSet \[dbGet top.insts.name $name -p \].pstatus softfixed"
	}
}
close $fp1
close $fp2

if {[llength [dbget selected.name]] != 0} {
puts "JM_INFO: Sourcing before_place.tcl to softfix overlaping insts"
source before_place.tcl -v
clearDrc
puts "JM_INFO: Starting eco place"
eco_place_cells_post_fill ; clearDrc ; checkPlace
puts "JM_INFO: Sourcing after_place.tcl to set pstatus to initial value of overlaping insts"
source after_place.tcl -v
}
