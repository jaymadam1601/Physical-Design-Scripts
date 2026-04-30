setEcoMode -batchMode false -honorDontTouch $is_honorDontTouch -honorDontUse $is_honorDontUse -honorFixedStatus $is_honorFixedStatus -honorFixedNetWire $is_honorFixedNetWire -refinePlace $is_refinePlace
clearDrc
eco_place_cells_post_fill ; clearDrc ; checkPlace
if {[llength [dbget [dbget top.markers.originator CheckPlace -p ].subType SPOverlapViolation -e]] != 0 } {
	puts "JM_INFO: Insts overlap found...."
	source /home/scripts/tcl/invs/fix_overlap.tcl
} else {
	puts "JM_INFO: No overlap ....."
}
cleanup_vt_post_swap -delete_all_no_metal_fill_cells true
setNanoRouteMode -routeWithTimingDriven false ; ecoRoute ; clearDrc ; verify_drc -limit 0 ; checkPlace
source /home/scripts/tcl/invs/filter_shorts_with_rBlkg.tcl
