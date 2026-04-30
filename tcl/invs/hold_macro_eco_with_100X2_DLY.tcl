if {[sizeof [get_cells -quiet -filter "is_macro_cell==true"]] > 0} {
#set macros_dly50 [get_object_name [get_cells -filter "is_macro_cell==true && (ref_name == M3PD211HC896X20R20221VTLPEB1340RCH20BOLA_wrapper || ref_name == M3DP222HC5376X20R20821VTLPEB1340CH20BOLA_wrapper)"]]
set macros_dly50 [get_object_name [get_cells -filter "is_macro_cell==true"]]
}
if {[sizeof [get_cells -quiet -filter "is_macro_cell==true"]] > 0} {
#set macros_bufx2 [get_object_name [get_cells -filter "is_macro_cell==true && (ref_name != M3PD211HC896X20R20221VTLPEB1340RCH20BOLA_wrapper && ref_name != M3DP222HC5376X20R20821VTLPEB1340CH20BOLA_wrapper)"]]
set macros_bufx2 [get_object_name [get_cells -filter "is_macro_cell==true"]]
}
#set macros {bfx_i0__bfx_mem_sym_len_i0__genblk1_ram_2rw_10752x20_i0__real_mem_i_0_mem0_i bfx_i0__bfx_mem_sym_len_i0__genblk1_ram_2rw_10752x20_i0__real_mem_i_1_mem0_i bfx_i0__bfx_mem_tdd_wrap_i0__genblk1_ram_1w1r_896x20_i0__mem0_i}

set iport {}
set c 0
set fw [open "../rpts/port_hold_eco.tcl" w]

puts $fw "setEcoMode -updateTiming false -prefixName mem_hold_eco_buf -batchMode true -refinePlace false -honorDontUse false -honorDontTouch false"

foreach macro $macros_bufx2 {
    set pins [get_object_name [get_pins -of_objects $macro -filter "is_clock==false AND direction==in"]]
	foreach pin $pins {
    #set pin_t [regsub "(.*RESET.*|.*rst.*|.*SCAN.*|.*ROW_.*|.*COL_.*|.*REDN_.*|.*BIST.*|.*MEM_.*|.*CORE_.*|.*CSA.*|.*CSB.*)" $pin " "]
    set pin_t $pin
	set mem_pin [join $pin_t " "]
    regsub -all {\[|\/|\]} $mem_pin "_" p1
	if { $mem_pin != "" && !([dbget [dbget top.insts.instTerms.name $mem_pin -p ].net.isPwrOrGnd])} {
	  incr c
	  puts $fw "ecoAddRepeater -cell G5SENAA_BUFX2 -term $mem_pin -name mem_hold_eco_buf_${p1}_${c} -newNetName mem_hold_eco_net_${p1}_${c} -relativeDistToSink 0"
	  lappend iport $mem_pin 
	}
	}
}

foreach macro $macros_dly50 {
    set pins [get_object_name [get_pins -of_objects $macro -filter "is_clock==false AND direction==in"]]
	foreach pin $pins {
    #set pin_t [regsub "(.*RESET.*|.*rst.*|.*SCAN.*|.*ROW_.*|.*COL_.*|.*REDN_.*|.*BIST.*|.*MEM_.*|.*CORE_.*|.*CSA.*|.*CSB.*)" $pin " "]
    set pin_t $pin
	set mem_pin [join $pin_t " "]
    regsub -all {\[|\/|\]} $mem_pin "_" p1
	if { $mem_pin != "" && !([dbget [dbget top.insts.instTerms.name $mem_pin -p ].net.isPwrOrGnd])} {
	  incr c
	  puts $fw "ecoAddRepeater -cell G5SENAA_CKDLY100X2 -term $mem_pin -name mem_hold_eco_buf_$p1 -newNetName mem_hold_eco_net_$p1 -relativeDistToSink 0"
	  lappend iport $mem_pin 
	  }
	}
}


puts $fw "setEcoMode -batchMode false"
puts $fw "setEcoMode -reset"
puts $fw "setInstancePlacementStatus -name *mem_hold_eco_buf* -status softFixed"
puts $fw "set_dont_touch \[get_cells -quiet *mem_hold_eco_buf*\]"
puts $fw "set_dont_touch \[get_nets mem_hold_eco_net*\]"
puts "Inserted hold buffer on [llength $iport] memory pins"
close $fw
source -e -v ../rpts/port_hold_eco.tcl

#if {[sizeof_collection [get_cells -quiet *hold_eco_buf*]]} {
#set_dont_touch [get_cells -quiet *hold_eco_buf* ]
#set_dont_touch [get_nets -quiet *mem_buf_net*]
#}

