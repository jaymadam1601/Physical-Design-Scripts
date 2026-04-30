proc listadd L {expr [join $L +]+0}

proc get_object_type {name} {
    set object_name $name
    deselectAll
    foreach object $object_name {
        select_obj $object
        set object_type [get_db selected .obj_type]
        deselectAll
    }
    return $object_type
}

proc noise_fix {pins} {
	foreach one $pins {
		if {[dbget [dbget top.insts.instTerms.name $one -p ].isInput]} {
 			
		} else {
			
		}
	}

}

