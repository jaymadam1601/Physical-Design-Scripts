set comb_delay 0; set buff_delay 0 ;set inv_delay 0; foreach_in_collection one [get_property $rpt timing_points] {
set pin_name [get_object_name [get_property  $one pin]] 
set is_comb [dbget [dbget [dbget [dbget [dbget top.insts.instTerms.name $pin_name  -p2 ].cell.isSequential 0 -p2  ].cell.isBuffer 0 -p2 ].cell.isInverter 0 -p2 ].name -e]
set is_buff [dbget [dbget [dbget top.insts.instTerms.name $pin_name  -p2 ].cell.isBuffer 1 -p2 ].name -e]
set is_inv [dbget [dbget [dbget top.insts.instTerms.name $pin_name  -p2 ].cell.isInverter  1 -p2 ].name -e]
set cell_delay [get_property $one delay]        
if {[llength $is_comb ] ==1 } {
 set comb_delay [expr $comb_delay + $cell_delay]
} elseif {[llength $is_buff ] ==1 } {
set buff_delay [expr $buff_delay + $cell_delay]
} elseif {[llength $is_inv ] ==1 } {
set inv_delay [expr $inv_delay + $cell_delay]
}
puts "$is_comb $is_buff $is_inv $comb_delay $buff_delay $inv_delay"
}
