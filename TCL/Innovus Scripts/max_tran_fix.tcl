# --- Define buffer cell externally ---
set ::BUFFER_CELL "P6L8B_BUFX10"


proc cell_size {inst_name sizeto {steps 1} {type "invs"}} {
    set inst_ref_name [dbget [dbGet top.insts.name $inst_name -p ].cell.name]
    set find_ref_name "[lindex [split $inst_ref_name "X"] 0]X*"
    set ref_found [lsort -dictionary [dbget head.libCells.name $find_ref_name]]
    set inst_ref_index [lsearch $ref_found $inst_ref_name]
    set new_inst_ref_index $inst_ref_index

    if {$sizeto eq "up"} {
        set new_inst_ref_index [expr {$inst_ref_index + $steps}]
        if {$new_inst_ref_index >= [llength $ref_found]} {
            set new_inst_ref_index [expr {[llength $ref_found] - 1}]
        }
    } elseif {$sizeto eq "down"} {
        set new_inst_ref_index [expr {$inst_ref_index - $steps}]
        if {$new_inst_ref_index < 0} {
            set new_inst_ref_index 0
        }
    }

    set new_cell [lindex $ref_found $new_inst_ref_index]

    if {$new_cell ne $inst_ref_name} {
        if {$type eq "invs"} {
            puts "ecoChangeCell -inst $inst_name -cell $new_cell"
        } elseif {$type eq "pt"} {
            puts "size_cell $inst_name $new_cell"
        } else {
            puts "#SIZE_CELL: INFO type given other than invs/pt"
        }
        return [list success $new_cell]
    } else {
        puts "#SIZE_CELL: INFO $inst_name cannot be $sizeto sized by $steps step(s)"
        return [list fail ""]
    }
}


proc insert_buffer_command {pin_name {cell_name ""} {type "invs"} {new_inst_name ""} {new_net_name ""}} {
    # Use provided buffer name or fallback to external variable
    if {$cell_name eq ""} {
        set cell_name $::BUFFER_CELL
    }

    if {$type eq "invs"} {
        if {$new_inst_name != "" && $new_net_name != ""} {
            puts "ecoAddRepeater -term $pin_name -cell $cell_name -name $new_inst_name -newNetName $new_net_name"
        } elseif {$new_inst_name != "" && $new_net_name == ""} {
            puts "ecoAddRepeater -term $pin_name -cell $cell_name -name $new_inst_name"
        } elseif {$new_inst_name == "" && $new_net_name != ""} {
            puts "ecoAddRepeater -term $pin_name -cell $cell_name -newNetName $new_net_name"
        } else {
            puts "ecoAddRepeater -term $pin_name -cell $cell_name"
        }
    } else {
        if {$new_inst_name != "" && $new_net_name != ""} {
            puts "insert_buffer $pin_name $cell_name -new_cell_names $new_inst_name -new_net_names $new_net_name"
        } elseif {$new_inst_name != "" && $new_net_name == ""} {
            puts "insert_buffer $pin_name $cell_name -new_cell_names $new_inst_name"
        } elseif {$new_inst_name == "" && $new_net_name != ""} {
            puts "insert_buffer $pin_name $cell_name -new_net_names $new_net_name"
        } else {
            puts "insert_buffer $pin_name $cell_name"
        }
    }
}


proc fix_tran_pins {pin_list {command_type "invs"}} {
    array set done_nets {}
    deselectAll
    selectPin $pin_list
    set filterd_port_tran_pins [dbget [dbget selected.objType instTerm -p ].name]

    deselectAll
    selectPin $filterd_port_tran_pins
    set filterd_clock_pins [dbget [dbget selected.cellTerm.isClk 0 -p2 ].name]

    deselectAll
    selectPin $filterd_clock_pins
    set input_tran_pins [dbget [dbget selected.isInput 1 -p ].name]
    set output_tran_pins [dbget [dbget selected.isOutput 1 -p ].name]

    # ---------------- Output pins handling ----------------
    deselectAll
    selectPin $output_tran_pins
    foreach one [dbget selected] {
        set net_name [dbget $one.net.name]
        set pin_name [dbget $one.name]

        if {[info exists done_nets($net_name)]} {
            puts "#FIX_TRAN: Pin $net_name already fixed on net, not fixing for $pin_name"
            continue
        }

        set action_msg ""

        if {[dbget $one.inst.cell.isBuffer] || [dbget $one.inst.cell.isInverter]} {
            set inst_name [dbget $one.inst.name]
            set result [cell_size $inst_name up 4 $command_type]
            set status [lindex $result 0]
            set new_cell [lindex $result 1]

            if {$status eq "fail"} {
                insert_buffer_command $pin_name $::BUFFER_CELL $command_type
                set action_msg "Could not upsize $inst_name; inserted buffer $::BUFFER_CELL"
            } else {
                set action_msg "Upsized $inst_name to $new_cell"
            }
        } else {
            insert_buffer_command $pin_name $::BUFFER_CELL $command_type
            set action_msg "Inserted buffer $::BUFFER_CELL for non-buffer/non-inverter cell"
        }

        puts "#FIX_TRAN: Pin $pin_name on net $net_name -> $action_msg"
        puts ""

        set done_nets($net_name) 1
    }

    # ---------------- Input pins handling (driver pins) ----------------
    deselectAll
    selectPin $input_tran_pins
    foreach one [dbget selected] {
        set net_name [dbget $one.net.name]
        set input_pin_name [dbget $one.name]

        # Skip if net already handled
        if {[info exists done_nets($net_name)]} {
            puts "#FIX_TRAN: Net $net_name already fixed, skipping input pin $input_pin_name"
            continue
        }

        # Get driver instance name (assume single driver)
		set driver_pin_name [dbget [dbget $one.net.instTerms.isOutput 1 -p ].name]
        set driver_inst_name [dbget [dbget $one.net.instTerms.isOutput 1 -p ].inst.name]
		set driver_inst_pointer [dbget [dbget $one.net.instTerms.isOutput 1 -p ].inst]
        if {$driver_inst_name eq "0x0"} {
            puts "#FIX_TRAN: No driver found for input pin $input_pin_name on net $net_name"
            continue
        }

        set action_msg ""
        if {[dbget $driver_inst_pointer.cell.isBuffer] || [dbget $driver_inst_pointer.cell.isInverter]} {
            set result [cell_size $driver_inst_name up 4 $command_type]
            set status [lindex $result 0]
            set new_cell [lindex $result 1]

            if {$status eq "fail"} {
                insert_buffer_command $driver_pin_name $::BUFFER_CELL $command_type
                set action_msg "Could not upsize $driver_inst_name; inserted buffer $::BUFFER_CELL"
            } else {
                set action_msg "Upsized $driver_inst_name to $new_cell"
            }
        } else {
            insert_buffer_command $driver_pin_name $::BUFFER_CELL $command_type
            set action_msg "Inserted buffer $::BUFFER_CELL for non-buffer/non-inverter driver cell"
        }

        puts "#FIX_TRAN: Input pin $input_pin_name on net $net_name -> Driver $driver_inst_name -> $action_msg"
        puts ""

        set done_nets($net_name) 1
    }
}

