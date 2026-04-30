proc highlight_macro_by_hier {list} {
	set i 1
	set all_macro $list
	array set groups {}
	foreach one_macro $all_macro {
		set base [regsub -all {\d+} $one_macro "*"]
		lappend groups($base) $one_macro
	}
	foreach key [array names groups] {
		highlight -index $i [dbget [dbget top.insts.cell.baseClass block -p2 ].name $key]
		if {$i < 63} {
			incr i
		} else {
			set i 1
		}
	}
}

proc highlight_macro_per_module {{depth 0}} {
	set hier_list [get_db designs .local_hinsts -depth $depth]
	set i 1
	foreach hier $hier_list {
		set macro_list [get_db [get_db $hier .insts -if {.base_cell.base_class == "block"}] .name]
		if {$macro_list != ""} {
			selectInst $macro_list
			highlight -index $i
			deselectAll
			if {$i < 63} {
				incr i
			} else {
				set i 1
			}
		}
	}
}


proc highlight_groups {file_name} {
    if {![file exists $file_name]} {
        puts "ERROR: File $file_name does not exist"
        return
    }

    deselectAll

    set fp [open $file_name r]
    while {[gets $fp line] >= 0} {
        set line [string trim $line]
        if {$line eq ""} {
            if {[llength [dbGet selected.name]] > 0} {
                highlight -auto_color
            }
            deselectAll
            continue
        }
        if {[catch {selectInst $line} err]} {
            puts "WARNING: Could not select instance '$line' : $err"
        }
    }
    if {[llength [dbGet selected.name]] > 0} {
        highlight -auto_color
    }
    close $fp
}
