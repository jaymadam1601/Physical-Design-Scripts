proc ck_timing {} {
	set patterns {constant_clock_pin clock_clipping_freq clock_clipping_gate clock_crossing clock_expected clock_gating_controlling_edge_unknown clock_gating_no_data clock_missing_at_sequential_output clock_not_propagated clocks_masked_by_another_clock const_collision data_check_multiple_reference_signal data_check_no_reference_signal ideal_clock_waveform invalid_pll_configuration loop master_clk_edge_not_reaching missing_clock_groups missing_drive multiple_clock no_drive no_gen_clock_source no_input_delay partial_input_delay pulse_non-pulse_clock_merge signal_level uncons_endpoint uncons_endpoints_due_to_case_analysis }
	set joined_pattern [join $patterns {|}]
	check_timing > check_timing	
	set result [exec sh -c "egrep -wo \"$joined_pattern\" check_timing | sort -u | paste -sd ' ' -"]
	puts $result
	foreach one $result {
		check_timing -check_only $one -verbose > check_timing_${one}
		puts "check_timing -check_only $one -verbose > check_timing_${one}"
	}
}

proc ck_timing {} {
    set patterns {
        constant_clock_pin
        clock_clipping_freq
        clock_clipping_gate
        clock_crossing
        clock_expected
        clock_gating_controlling_edge_unknown
        clock_gating_no_data
        clock_missing_at_sequential_output
        clock_not_propagated
        clocks_masked_by_another_clock
        ideal_clock_waveform
        no_drive
        uncons_endpoint
    }

    set joined_pattern [join $patterns {|}]
    check_timing > check_timing

    set result [exec sh -c "egrep -wo \"$joined_pattern\" check_timing | sort -u | paste -sd ' ' -"]
    puts $result

    foreach one $result {
        set rpt_file "check_timing_${one}"
        set xls_file "xls_${rpt_file}"
        puts "Generating: $rpt_file"
        check_timing -check_only $one -verbose > $rpt_file

        if {$one == "constant_clock_pin"} {
            exec sh -c {cat check_timing_constant_clock_pin | awk '/Clock missing due to constant/ {print (NF==6 ? prev : $1)",Clock missing due to constant,"$NF} {prev=$1}'} > $xls_file
        } elseif {$one == "ideal_clock_waveform"} {
            exec sh -c {cat check_timing_ideal_clock_waveform | awk '/Clock Waveform/ {found=1} found' | awk 'NF==2{print $1","$2}'} > $xls_file
        } elseif {$one == "no_drive"} {
            exec sh -c {cat check_timing_no_drive | awk '/No drive assertion/ {print (NF==4 ? prev : $1)",No drive assertion,"$NF} {prev=$1}'} > $xls_file
        } elseif {$one == "uncons_endpoint"} {
            exec sh -c {cat check_timing_uncons_endpoint | awk '/Unconstrained signal arriving at end point/ {if (NF==6) {getline; print prev",Unconstrained signal arriving at end point,"$1} else if (NF==7) {print prev",Unconstrained signal arriving at end point,"$NF} else if (NF==8) {print $1",Unconstrained signal arriving at end point,"$NF}} {prev=$1}'} > $xls_file
        }
    }
}

