
set critical_ports(<BLOCK_NAME>) [list   \
]


if {[info exists critical_ports($DESIGN)]} {
    set crit_in ""
    set crit_out ""
    foreach port_expr $critical_ports($DESIGN) {
        if {[sizeof_collection [get_ports -quiet $port_expr]]} {
            Puts "INFO: creating critical path group from and to ports $port_expr"
            foreach port [get_object_name [get_ports -quiet $port_expr]] {
                set dir [get_attr [get_ports $port] direction]
                if {$dir eq "in"} {
                    append_to_coll -unique crit_in [get_ports $port ]
                } elseif {$dir eq "out"} {
                    append_to_coll -unique crit_out [get_ports $port ]
                }
            }
        } else {
            Puts "ERROR: ports $port_expr from top critical IO port list doesn't exist in block $DESIGN"
        }
    }

    if {[sizeof_coll $crit_in]} {
        group_path -name topCrit_IN -from $crit_in -to [all_registers]
        setPathGroupOptions topCrit_IN -effortLevel high -weight 4
    }
    if {[sizeof_coll $crit_out]} {
        group_path -name topCrit_OUT -from [all_registers] -to $crit_out
        setPathGroupOptions topCrit_OUT -effortLevel high -weight 4
    }
} else {
    Puts "INFO: No top level critical ports in the block $DESIGN"
}

