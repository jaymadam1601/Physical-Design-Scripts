source /home/scripts/tcl/invs/fanin_fanout_tree.tcl	
source /home/scripts/tcl/invs/procs.tcl
source /home/scripts/tcl/invs/propogate_noise_net_check.tcl
history keep 20000
set enc_tcl_return_display_limit 10000
set_global report_timing_format {timing_point cell fanout load slew delay incr_delay arrival edge}

set metal_layers [dbget [dbget head.layers.type routing -p ].name]
set via_layers [dbget [dbget head.layers.type cut -p ].name]
set layers [concat $metal_layers $via_layers]
foreach one_layer $layers {
	setLayerPreference $one_layer -isVisible 0
}
setLayerPreference allLayers -isSelectable 0
setLayerPreference node_blockage -isVisible 0
setLayerPreference flightLine -isVisible 0

###--------------------------------- Aliases ---------------------------------###
alias getCord uiGetCoord
alias ds deselectAll
alias sio selectIOPin
alias si selectInst
alias sn selectNet

##--------------- dbget commands ---------------##
alias dbsn dbget selected.name
alias ref dbget selected.cell.name

###--------------------------------- Procs ---------------------------------###
proc spinnet {pin} {selectNet [get_nets -of_objects $pin]}
proc set_timing_rpt_width {width} {set_table_style -name report_timing -frame -max_width $width -min_width {10,10}}
proc set_setup_hold_timing_mode {} {set timing_enable_simultaneous_setup_hold_mode true}
proc getmacro {} {set macros [dbget [dbget top.insts.cell.baseClass block -p2 ].name ]; return $macros}
proc simacro {} { selectInst [dbget [dbget top.insts.cell.baseClass block -p2 ].name ] }
proc dbGetDriverofNet {net_name} {return [dbget [dbget [dbget top.nets.name $net_name  -p ].instTerms.isOutput 1 -p ].inst.name ]}
proc dbBlockWidth {} {dbget top.fPlan.box_sizex}
proc dbBlockHeight {} {dbget top.fPlan.box_sizey}
proc defOutonlyMacros {{postfix ""}} {if {$postfix != ""} {set postfix "_${postfix}"}; global DESIGN; ds; simacro; puts "Writting macro only def ${DESIGN}_macro${postfix}.def.gz"; defOut -selected ${DESIGN}_macro${postfix}.def.gz; ds}
proc tclOutonlyMacros {{postfix ""}} {if {$postfix != ""} {set postfix "_${postfix}"}; global DESIGN; ds; simacro; puts "Writting macro only tcl ${DESIGN}_macro${postfix}.tcl"; writeFPlanScript -selected -fileName ${DESIGN}_macro${postfix}.tcl; ds}
proc gifOutMacros {{postfix ""}} {global DESIGN; puts "Dumping out macro only gif ${DESIGN}_macro${postfix}.gif"; gui_dump_picture ${DESIGN}_macro${postfix}.gif -format GIF}
proc macroOutdeftcl {{postfix ""}} {tclOutonlyMacros $postfix; defOutonlyMacros $postfix}
proc macroAllOutFile {{postfix ""}} {macroOutdeftcl $postfix; gifOutMacros $postfix}
proc swap_macros {macros} {
	set macro1 [lindex $macros 0]
	set macro2 [lindex $macros 1]
	set macro1_llx [dbget [dbget top.insts.name $macro1 -p ].box_llx] 
	set macro1_lly [dbget [dbget top.insts.name $macro1 -p ].box_lly]
	set macro2_llx [dbget [dbget top.insts.name $macro2 -p ].box_llx] 
	set macro2_lly [dbget [dbget top.insts.name $macro2 -p ].box_lly]
	placeInstance $macro1 $macro2_llx $macro2_lly
	placeInstance $macro2 $macro1_llx $macro1_lly
}
proc getInstbyMarker {sub_type} {foreach one [dbget [dbget top.markers.subType $sub_type -p ].box] {puts "[dbget [dbQuery -areas $one -objType inst ].name]"}}
proc getInstbyBox {box_list} {foreach one $box_list {puts "[dbget [dbQuery -areas $one -objType inst ].name]"}}
proc getInstrefbyBox {box_list} {foreach one $box_list {puts "[dbget [dbQuery -areas $one -objType inst ].cell.name]"}}
proc deleteFPAll {} {puts "FP Object: Deleting halo from macros"; deleteHaloFromBlock -allMacro; puts "FP Object: Deleting blockages"; ag_delete_blockage; puts "FP Object: Deleting rt blockages"; ag_delete_rt_blockage; puts "FP Object: Deleting Power Grid"; ag_delete_power_grid; puts "FP Object: Deleting endcap"; ag_delete_endcap}
proc checkpininit {{postfix ""}} {if {$postfix != ""} {set postfix "_${postfix}"}; checkPinAssignment -report_violating_pin -outFile checkPinAssignment_initial${postfix}.rpt}
proc checkpinpwr {{postfix ""}} {if {$postfix != ""} {set postfix "_${postfix}"}; checkPinAssignment -report_violating_pin -outFile checkPinAssignment_after_pwr${postfix}.rpt}
proc savedata {{postfix ""}} {global DST_DATA_DIR; global DESIGN; if {$postfix != ""} {set postfix "_${postfix}"}; saveDesign $DST_DATA_DIR/${DESIGN}${postfix}.enc -tcon; ag_def_out_route $DST_DATA_DIR $postfix}
proc create_physical_pin {} {
	set mm7 [dbGet top.fplan.box]
	set mm [dbShape -output rect $mm7 SIZE 5 ]
	editSelect -net {VDDM VDD VSS} -layer {M17 M16}  -area $mm -type Special
	foreach sel [dbGet -e selected] {
		createPhysicalPin -rect  [dbGet $sel.box] -net [dbGet $sel.net.name] -layer [dbGet $sel.layer.name]  [dbGet $sel.net.name] 
	}
}
proc violation_layer_count {} {
	puts "Violation,Layer,Count"
	foreach one_subtype [lsort [dbget top.markers.subType -u ]] {
		foreach one_layer [lsort [dbget [dbget top.markers.subType  $one_subtype -p ].layer.name -u]] {
			set layer_count [llength [dbget [dbget top.markers.subType $one_subtype -p].layer.name $one_layer]]
			puts "$one_subtype,$one_layer,$layer_count"
		}
	}
}
proc addAntenaCellonNet {netName cellName location {prefix "manual_cc_AR_fix"}} {
	set newCellName "${prefix}_cell_${netName}"
	addInst -cell $cellName -inst $newCellName -loc $location
	puts "Adding Antena cell ($cellName) for net $netName at $location"
	attachTerm $newCellName i [get_object_name [get_nets -quiet $netName]]
}
proc avo_violation_layer_count {} {
	puts "DRC,Count"
	foreach one_usertype [lsort [dbget top.markers.usertype -u]] {
		set count [llength [dbget top.markers.usertype $one_usertype ]]
		puts "$one_usertype,$count"
	}
}
proc get_skew_group_ignored_pins {} {
	foreach pin [get_ccopt_clock_tree_sinks *] {
        if { [get_ccopt_property sink_type -pin $pin] == "ignore" } {
			puts "global ignore pin found : $pin"
		}
	}
}
proc printDirtyNets {stage {showName "0"} {select "0"}} {
  set count 0
  dbForEachCellNet [dbgTopCell] netPtr {
    if {[dbIsNetRouteDirty $netPtr]} {
      incr count
      if {$showName == "1"} {
        set net [dbNetName $netPtr]
        puts "DIRTY NET: $net"
		if {$select =="1"} {
		  selectNet $net
		}
      }
    }
  }
  puts "\t$stage: total dirty nets: $count"
}

proc reportNDR {} {
  Puts "NDR's in design --> \n"
  foreach ndr [dbGet head.rules.name] {
    Puts " $ndr"
    Puts "\tLayer \tDirection \tWidth \tSpacing Pitch_X Pitch_Y"
    set NDR_Layer_Name "[dbGet [dbGet -p1 head.rules.name $ndr].layerRule.layer.name]"
    set NDR_Layer_Direction "[dbGet [dbGet -p1 head.rules.name $ndr].layerRule.layer.direction]"
    set NDR_Width "[dbGet [dbGet -p1 head.rules.name $ndr].layerRule.width]"
    set NDR_Spacing "[dbGet [dbGet -p1 head.rules.name $ndr].layerRule.spacing]"
    set NDR_Pitch_X "[dbGet [dbGet -p1 head.rules.name $ndr].layerRule.layer.pitchX]"
    set NDR_Pitch_Y "[dbGet [dbGet -p1 head.rules.name $ndr].layerRule.layer.pitchY] \n"
    foreach c1 $NDR_Layer_Name c2 $NDR_Layer_Direction c3 $NDR_Width c4 $NDR_Spacing c5 $NDR_Pitch_X c6 $NDR_Pitch_Y {
      Puts "\t$c1\t$c2\t$c3\t$c4\t$c5\t$c6"
    }
  }
  Puts ""
  Puts "Note: If a spacing or width is 0, it means the NDR does not have a value and will use the default instead."
  Puts ""
}

proc printParasitic {netName} {
	puts "capacitance_max : [get_property [get_net $netName] capacitance_max]"
	puts "coupling_capacitance_max [get_property [get_net $netName] coupling_capacitance_max]"
	puts "resistance_max [get_property [get_net $netName] resistance_max]"
}
proc noise_pin_net_sum {noise_pins} {
	foreach one $noise_pins {
		set pin $one
		set one [get_object_name [get_nets -of_objects $one]]
		puts "$one [dbget [dbget [dbget top.nets.name $one  -p ].instTerms.isOutput 1 -p ].inst.name ] [dbget [dbget [dbget top.nets.name $one  -p ].instTerms.isOutput 1 -p ].inst.cell.name] [listadd [dbget  [dbget top.nets.name $one  -p ].wires.length ]]"
	}
}
proc pin_driver_name {pin_list} {
	foreach one $pin_list {
		set net [get_object_name [get_nets -of_objects $one]]
		puts "$one [dbget [dbget [dbget top.nets.name $net -p ].instTerms.isOutput 1 -p ].inst.name ] [dbget [dbget [dbget top.nets.name $net  -p ].instTerms.isOutput 1 -p ].inst.cell.name]"
	}
}
proc start_edit {} {start_parallel_edit -region [dbget top.fplan.coreBox]; puts "Starting the Parallel edit at [dbget top.fplan.coreBox]"}
proc end_edit {{postfix ""}} {if {$postfix != ""} {set postfix "_${postfix}"}; global DESIGN; end_parallel_edit -out_file ${DESIGN}${postfix}.tcl; puts "Paralled edit saved in ${DESIGN}${postfix}.tcl"}

proc loaddebugtiming {path_group {type "setup"}} {
	if {![info exists ::DESIGN]} {puts "ERROR: DESIGN variable not set."; return}
	set rpt_dir [exec sh -c {ls -d ../rpts/timing_* 2>/dev/null | tail -1}]
	if {$rpt_dir eq ""} {puts "ERROR: No timing report directory found."; return}
	set file "${rpt_dir}/${::DESIGN}_${type}_${path_group}.btarpt"
	if {![file exists $file]} {puts "ERROR: File not found: $file"; return}
	puts "Loading: $file"
	load_timing_debug_report $file
}



proc start_timing_path_parsing {} {
	source /home/scripts/tcl/invs/parser_scripts/timing_path_highlight_roll.tcl
	source /home/scripts/tcl/invs/parser_scripts/sfin_sfout.tcl
}

###--------------------------------- all_* ---------------------------------###
alias ar all_registers
alias ac all_clocks
alias afi all_fanin
alias afo all_fanout
alias ai all_instances
alias ac all_connected
alias ao all_outputs
alias ai all_inputs 


###--------------------------------- others ---------------------------------###
proc deleteaddrtBlkg {} {deleteRouteBlk -name MEMORYPERI_blk}
proc add_endcap_add_blkg {} {
	ag_add_obs_endcap
	setFinishFPlanMode -activeObj "macro  hardblkg core"
	finishFloorplan -fillPlaceBlockage hard .8 -name endcap_blockage
	ag_add_endcap
}
proc addTCDCell {} {global DESIGN; addInst -physical -cell N02_DTCD_ALL_M13_230809 -inst TCD_CELL_${DESIGN}}

set design_name   [dbget top.name]
set block_width   [dbBlockWidth]
set block_height  [dbBlockHeight]
set block_area    [dbget top.fPlan.area]
set ports_count   [sizeof_collection [get_ports]]
set input_ports   [sizeof_collection [get_ports -filter "direction==in"]]
set output_ports  [sizeof_collection [get_ports -filter "direction==out"]]
set cell_count    [sizeof_collection [get_cells]]
set macro_count   [llength [dbget top.insts.cell.baseClass block]]

proc add_commas {num} {
    if {![string is integer -strict $num]} {
        return $num
    }
    set sign ""
    if {[string match -* $num]} {
        set sign "-"
        set num [string range $num 1 end]
    }
    set len [string length $num]
    if {$len <= 3} {
        return "$sign$num"
    }
    set last3 [string range $num end-2 end]
    set rest [string range $num 0 end-3]
    set result ""
    while {[string length $rest] > 2} {
        set result ",[string range $rest end-1 end]$result"
        set rest [string range $rest 0 end-2]
    }
    if {[string length $rest] > 0} {
        set result "$rest$result"
    }
    return "$sign$result,$last3"
}

set area_fmt          [add_commas $block_area]
set ports_count_fmt   [add_commas $ports_count]
set input_ports_fmt   [add_commas $input_ports]
set output_ports_fmt  [add_commas $output_ports]
set cell_count_fmt    [add_commas $cell_count]
set macro_count_fmt   [add_commas $macro_count]

puts "+----------------------------------------------------------+"
puts [format "|  %-12s: %-42s|" "Design Name"   $design_name]
puts [format "|  %-12s: %-42s|" "Block Size"    "$block_width x $block_height"]
puts [format "|  %-12s: %-42s|" "Block Area"    $area_fmt]
puts [format "|  %-12s: %-42s|" "Ports Count"   $ports_count_fmt]
puts [format "|  %-12s: %-42s|" "Input Ports"   $input_ports_fmt]
puts [format "|  %-12s: %-42s|" "Output Ports"  $output_ports_fmt]
puts [format "|  %-12s: %-42s|" "Cell Count"    $cell_count_fmt]
puts [format "|  %-12s: %-42s|" "Macro Count"   $macro_count_fmt]
puts "+----------------------------------------------------------+"

