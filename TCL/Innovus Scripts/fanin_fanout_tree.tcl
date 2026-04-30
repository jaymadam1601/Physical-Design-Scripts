#proc get_fanout_tree_by_pin_name {object level {till_cell} {current_level 0}} {
#	if {$current_level >= $level} {return}
#	set fanout_object_collection 
#}

proc get_fans_tree {object_name level {current_level 0}} {
	get_fanin_tree $object_name $level $current_level
	get_fanout_tree $object_name $level $current_level
}

proc get_fanout_tree {object_name level {current_level 0}} {
    if {$current_level >= $level} {return}
    set fanout_object_collection [remove_from_collection [all_fanout -from [dbget [dbget [dbget top.insts.name $object_name -p ].instTerms.isOutput 1 -p ].name ] -endpoints_only -only_cells] $object_name]
    set fanout_object [get_object_name $fanout_object_collection]
    if {[llength $fanout_object] == 0} {return} 
    set indent [string repeat "|  " $current_level]
    if {$current_level == 0} {puts "$object_name"}
    foreach fanout_object_one $fanout_object {
        puts "${indent}|->[expr {$current_level +1 }]. ${fanout_object_one}"
        get_fanout_tree $fanout_object_one $level [expr {$current_level + 1}]
    }
}

proc get_fanin_tree {object_name level {current_level 0}} {
	if {$current_level >= $level} {return}
	set pins [filter_collection [get_pins [dbget [dbget [dbget top.insts.name $object_name -p ].instTerms.isInput 1 -p ].name]] "full_name !~ */ti && full_name !~ */te && full_name !~ */phi  && full_name !~ */reset*" ]
	set fanin_object_collection [remove_from_collection [all_fanin -to $pins -startpoints_only -only_cells] $object_name]
	set fanin_object [get_object_name $fanin_object_collection]
	if {[llength $fanin_object] == 0} {return}
	set indent [string repeat "|  " $current_level]
	if {$current_level == 0} {puts "$object_name"}
	foreach fanin_object_one $fanin_object {
		puts "${indent}|->[expr {$current_level +1 }]. ${fanin_object_one}"
		get_fanin_tree $fanin_object_one $level [expr {$current_level + 1}]
	}


}

proc get_fanout_tree_csv {object_name level {current_level 0}} {
    if {$current_level >= $level} {return}
    set fanout_object_collection [remove_from_collection [all_fanout -from [dbget [dbget [dbget top.insts.name $object_name -p ].instTerms.isOutput 1 -p ].name ] -endpoints_only -only_cells] $object_name]
    set fanout_object [get_object_name $fanout_object_collection]
    if {[llength $fanout_object] == 0} {return}
    set indent [string repeat "-," $current_level]
    if {$current_level == 0} {puts "$object_name"}
    foreach fanout_object_one $fanout_object {
        puts "${indent}->[expr {$current_level +1 }],${fanout_object_one}"
        get_fanout_tree_csv $fanout_object_one $level [expr {$current_level + 1}]
    }
}

proc get_fanin_tree_csv {object_name level {current_level 0}} {
	if {$current_level >= $level} {return}
	set pins [filter_collection [get_pins [dbget [dbget [dbget top.insts.name $object_name -p ].instTerms.isInput 1 -p ].name]] "full_name !~ */ti && full_name !~ */te && full_name !~ */phi  && full_name !~ */reset*" ]
	set fanin_object_collection [remove_from_collection [all_fanin -to $pins -startpoints_only -only_cells] $object_name]
	set fanin_object [get_object_name $fanin_object_collection]
	if {[llength $fanin_object] == 0} {return}
	set indent [string repeat "-," $current_level]
	if {$current_level == 0} {
        puts "$object_name"
    }
	foreach fanin_object_one $fanin_object {
		puts "${indent}->[expr {$current_level +1 }], ${fanin_object_one}"
		get_fanin_tree_csv $fanin_object_one $level [expr {$current_level + 1}]
	}
}

proc get_fanout_tree_obj {object_name level {current_level 0}} {
    global fanout;
	if {$current_level == 0} {
		array unset fanout
		array set fanout {}
	}
	if {$current_level >= $level} {return}
		
    set fanout_object_collection [remove_from_collection [all_fanout -from [dbget [dbget [dbget top.insts.name $object_name -p ].instTerms.isOutput 1 -p ].name */q*] -endpoints_only -only_cells] $object_name]
    set fanout_object [get_object_name $fanout_object_collection]
    if {[llength $fanout_object] == 0} {return}
    set indent [string repeat "|  " $current_level]
    if {$current_level == 0} {puts "$object_name"}
    foreach fanout_object_one $fanout_object {
        puts "${indent}|->[expr {$current_level +1 }]. ${fanout_object_one}"
        lappend fanout([expr {$current_level +1 }]) $fanout_object_one
		get_fanout_tree $fanout_object_one $level [expr {$current_level + 1}]
    }
	if {$current_level == 0} {
        foreach key [array names fanout] {
            set fanout($key) [lsort -unique $fanout($key)]
        }
    }
}

