proc AR_CC_Fix {cc_cal_data_directory {filename "cc_fix_eco.tcl"}} {
	set fp [open $filename w]
	set fp1 [open ${filename}_after.tcl w]
	set all_nets {}
	set marker_file "$cc_cal_data_directory/cal_ascii"
	array set added_diodes {}
	clearDrc
	loadViolationReport -type Calibre -filename $marker_file
	set layer_antenas [lsort [dbGet top.markers.userType A.R.6__A.R.6.1__A.R.8* -u -e ]]
	if {$layer_antenas != ""} {
		foreach one $layer_antenas {
			set layer [lindex [split $one ":"] 1]
			set supporst_file "$cc_cal_data_directory/supportFiles/${one}.rep"
			clearDrc
			loadViolationReport -type Calibre -filename $supporst_file
			deselectAll
			foreach one_box [dbget [dbget top.markers.userType ${one}::<1>_*_${layer}i -p ].box] {
				deselectAll
				editSelect -area $one_box -layer $layer
				set net_name [dbget [dbget selected.net.isPwrOrGnd 0 -p ].name -u]
				lappend all_nets $net_name
				puts $fp "# $layer $net_name \{$one_box\} "
				set net_input_pins [dbget [dbget [dbget top.nets.name $net_name -p ].instTerms.isInput 1 -p ].name]
				foreach one_input $net_input_pins {
					set cell_name [dbget [dbget top.insts.instTerms.name $one_input -p2 ].name]
					set pin_name [lindex [split $one_input "/"] end]
					if { [info exists added_diodes($one_input)] } {
    	                continue
    	            }
					set pin_loc [dbget [dbget top.insts.instTerms.name $one_input -p ].pt]
					puts $fp "attachDiode -diodeCell P2LLRA_DIODEX4 -loc $pin_loc -pin $cell_name $pin_name"
					set added_diodes($one_input) 1
				}
			}
		}
	}

	clearDrc
	loadViolationReport -type Calibre -filename $marker_file
	set via_antenas [lsort [dbget top.markers.userType -u  A.R.7:* -e ]]
	if {$via_antenas != ""} {
		foreach one $via_antenas {
			puts $fp "# $one Fix"
			foreach one_box [dbget [dbget top.markers.userType $one -p ].box] {
				set input_pins [dbget [dbget [dbQuery -areas $one_box -objType inst ].instTerms.isInput 1 -p ].name]
				foreach one_input $input_pins {
					set net_of_pin [dbget [dbget top.insts.instTerms.name $one_input -p ].net.name]
					lappend all_nets $net_of_pin
    	            set cell_name [dbget [dbget top.insts.instTerms.name $one_input -p2 ].name]
    	            set pin_name [lindex [split $one_input "/"] end]
    	            if { [info exists added_diodes($one_input)] } {
    	                continue
    	            }
    	            set pin_loc [dbget [dbget top.insts.instTerms.name $one_input -p ].pt]
    	            puts $fp "attachDiode -diodeCell P2LLRA_DIODEX4 -loc $pin_loc -pin $cell_name $pin_name"
    	            set added_diodes($one_input) 1
				}
			}
		}
	}

	set via_antenas [lsort [dbget top.markers.userType -u  A.R.4:* -e]]
	if {$via_antenas != "" } {
		foreach one $via_antenas {
			set layer [lindex [split $one ":"] 1]
    		foreach two [dbget [dbget top.markers.userType $one -p ].box ] { 
    		    deselectAll
    		    editSelect -area [dbShape $two SIZE 0.07] -layer $layer -object_type Via 
    		    set net_name [dbget [dbget selected.net.isPwrOrGnd 0 -p ].name -u -e] 
    		    lappend all_nets $net_name
    		}   
		}
	}
	
	deselectAll
	selectNet $all_nets
	foreach one [dbget [dbget selected.skipRouting 1 -p ].name] {
		puts $fp "dbSet \[dbget top.nets.name $one -p \].skipRouting 0"
		puts $fp1 "dbSet \[dbget top.nets.name $one -p \].skipRouting 1"
	}
	foreach one [dbget [dbget selected.dontTouch true -p ].name] {
		puts $fp "dbSet \[dbget top.nets.name $one -p \].dontTouch false"
		puts $fp1 "dbSet \[dbget top.nets.name $one -p \].dontTouch true"
	}
	deselectAll
	close $fp1
	close $fp
}
