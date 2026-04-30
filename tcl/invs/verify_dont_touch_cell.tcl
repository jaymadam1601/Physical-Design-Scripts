if {0} {
cat source/${MY_BLOCK}.size_only.flat.tcl | awk '{print $4}' | sed 's/\]//' > size_only.tcl
cat source/${MY_BLOCK}.dont_touch.flat.tcl | awk '{print $4}' | sed 's/\]//' > dont_touch.tcl
cat scripts/con/exclude_mbit.tcl | awk '/dontMergeMultibit 1/{print $3}' > mbit.tcl
source /home/scripts/tcl/invs/verify_dont_touch_cells.tcl
verify_donttouch_mbit_cells ../../../dont_touch.tcl ../../../mbit.tcl ../../../size_only.tcl
}

puts "Usage: verify_donttouch_mbit_cells <dont_touch_cell_list_file> <mbit_cell_list_file> <size_only_cell_list_file>"
proc verify_donttouch_mbit_cells {{dont_touch_file "NA"} {mbit_file "NA"} {size_only "NA"}} {
    if {$dont_touch_file != "NA"} {
        set rpt "dont_touch.rpt"
        if {[file exists $rpt]} {
            rm -rf $rpt
        }
        touch $rpt
        set fp [open $dont_touch_file r]
        while {[gets $fp line] >= 0} {
            set inst [string trim $line]
            if {$inst != ""} {
                if {[dbget -e top.insts.name $inst] == ""} {
                    redirect -append $rpt {puts "DONT_TOUCH ERROR: $inst is not present in design"}
                }
            }
        }
        close $fp
        set DONT_TOUCH [exec wc -l < $dont_touch_file]
        set VIOLATION  [exec wc -l < $rpt]
        puts "DONT TOUCH CELLS: $DONT_TOUCH"
        puts "DONT TOUCH ERROR: $VIOLATION"
		puts ""
    }
    if {$mbit_file != "NA"} {
        set rpt "mbit.rpt"
        if {[file exists $rpt]} {
            rm -rf $rpt
        }
        touch $rpt
        set fp [open $mbit_file r]
        while {[gets $fp line] >= 0} {
            set inst [string trim $line]
            if {$inst != ""} {
                if {[dbget -e top.insts.name $inst] == ""} {
                    redirect -append $rpt {puts "MBIT ERROR: $inst is not present in design"}
                }
            }
        }
        close $fp
        set DONT_MBIT [exec wc -l < $mbit_file]
        set VIOLATION  [exec wc -l < $rpt]
        puts "DONT MBIT CELLS: $DONT_MBIT"
        puts "DONT MBIT ERROR: $VIOLATION"
		puts ""
    }
    if {$size_only != "NA"} {
        set rpt "size_only.rpt"
        if {[file exists $rpt]} {
            rm -rf $rpt
        }
        touch $rpt
        set fp [open $size_only r]
        while {[gets $fp line] >= 0} {
            set inst [string trim $line]
            if {$inst != ""} {
                if {[dbget -e top.insts.name $inst] == ""} {
                    redirect -append $rpt {puts "SIZE_ONLY ERROR: $inst is not present in design"}
                }
            }
        }
        close $fp
        set SIZE_ONLY [exec wc -l < $size_only]
        set VIOLATION [exec wc -l < $rpt]
        puts "SIZE ONLY CELLS: $SIZE_ONLY"
        puts "SIZE ONLY ERROR: $VIOLATION"
		puts ""
    }
}
