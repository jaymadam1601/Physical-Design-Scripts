foreach one_macro [dbget selected] {
    # Initialize an empty array for marking macros
    array set macro_name_mark {}

    # Get macro name and bounding box
    set one_macro_name [dbget $one_macro.name]
    set one_macro_box [dbget $one_macro.box]

    # Get DRC markers for the macro
    set macro_drc_mark [dbget [dbQuery -objType marker -areas $one_macro_box].userType]

    # Process each marker for the current macro
    foreach one_macro_mark $macro_drc_mark {
        # Use a concatenated key to simulate a 2D array
        set key "$one_macro_name,$one_macro_mark"
        if {![info exists macro_name_mark($key)]} {
            set macro_name_mark($key) 0
        }
        incr macro_name_mark($key)
    }
}

# Example to print the data
foreach key [array names macro_name_mark] {
    puts "$key: $macro_name_mark($key)"
}

