set total_filler [llength [dbget top.insts.name *FILLER*]]

set fillbycap_count 0
set METAL_FILL_CELLS_count 0
set NO_METAL_FILL_CELLS_count 0
set NO_METAL_EARLY_FILL_CELLS_count 0

foreach one $fillbycap {
    set one_count [llength [dbget [dbget top.insts.name *FILLER* -p ].cell.name $one -e]]
	puts "fillbycap : $one : $one_count"
	set fillbycap_count [expr $fillbycap_count + $one_count]
}

foreach one $METAL_FILL_CELLS {
    if {[lsearch -exact $fillbycap $one] == -1} {
    	set one_count [llength [dbget [dbget top.insts.name *FILLER* -p ].cell.name $one -e]]
		puts "METAL_FILL_CELLS : $one : $one_count"
        set METAL_FILL_CELLS_count [expr $METAL_FILL_CELLS_count + $one_count]
    }
}

foreach one $NO_METAL_FILL_CELLS {
    set one_count [llength [dbget [dbget top.insts.name *FILLER* -p ].cell.name $one -e]]
	puts "NO_METAL_FILL_CELLS : $one : $one_count"
    set NO_METAL_FILL_CELLS_count [expr $NO_METAL_FILL_CELLS_count + $one_count]
}

foreach one $NO_METAL_EARLY_FILL_CELLS {
    set one_count [llength [dbget [dbget top.insts.name *FILLER* -p ].cell.name $one -e]]
	puts "NO_METAL_EARLY_FILL_CELLS : $one : $one_count"
    set NO_METAL_EARLY_FILL_CELLS_count [expr $NO_METAL_EARLY_FILL_CELLS_count + $one_count]
}

set p_fillbycap [expr {100.0 * $fillbycap_count / $total_filler}]
set p_METAL_FILL [expr {100.0 * $METAL_FILL_CELLS_count / $total_filler}]
set p_NO_METAL_FILL [expr {100.0 * $NO_METAL_FILL_CELLS_count / $total_filler}]
set p_NO_METAL_EARLY [expr {100.0 * $NO_METAL_EARLY_FILL_CELLS_count / $total_filler}]

#puts "Total Filler cells           : $total_filler"
#puts "Filler by cap                : $fillbycap_count  ($p_fillbycap%)"
#puts "METAL_FILL_CELLS             : $METAL_FILL_CELLS_count  ($p_METAL_FILL%)"
#puts "NO_METAL_FILL_CELLS          : $NO_METAL_FILL_CELLS_count  ($p_NO_METAL_FILL%)"
#puts "NO_METAL_EARLY_FILL_CELLS    : $NO_METAL_EARLY_FILL_CELLS_count  ($p_NO_METAL_EARLY%)"

puts "Total Filler cells: $total_filler; Filler by cap: $fillbycap_count ($p_fillbycap%); METAL_FILL_CELLS: $METAL_FILL_CELLS_count ($p_METAL_FILL%); NO_METAL_FILL_CELLS: $NO_METAL_FILL_CELLS_count ($p_NO_METAL_FILL%); NO_METAL_EARLY_FILL_CELLS: $NO_METAL_EARLY_FILL_CELLS_count ($p_NO_METAL_EARLY%)"

puts "Total Filler cells,Filler by cap,METAL_FILL_CELLS,NO_METAL_FILL_CELLS,NO_METAL_EARLY_FILL_CELLS,"	
puts "$total_filler,$p_fillbycap%,$p_METAL_FILL%,$p_NO_METAL_FILL%,$p_NO_METAL_EARLY%"
