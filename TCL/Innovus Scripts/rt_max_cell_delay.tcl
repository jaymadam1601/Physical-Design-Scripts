puts "Usage: rt_max_cell_delay path_group <max_paths_num> <sign_for_rt_worst_cell_delay> <sign1_for_rt_worst_plus_additional_cell_delay> {additional_delay}"
puts "rt_max_cell_delay reg2reg 100 <= > 0.1"

proc rt_max_cell_delay {path_group i sign sign1 {additional 0}} {
    set fp [open "${path_group}_rt_max_cell_delay.tcl" w+]

    foreach_in_collection one [report_timing -path_group $path_group -max_paths $i -collection] {
        set rt [get_property $one required_time]
        set worst_cell_delay [get_property $one worst_cell_delay]
        set delay [expr {$worst_cell_delay + $additional}]

        switch "$sign and $sign1" {
            "<= and <=" {
                if {$rt <= $worst_cell_delay && $rt <= $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt <= worst_cell_delay and rt <= delay"
                }
            }
            "<= and >=" {
                if {$rt <= $worst_cell_delay && $rt >= $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt <= worst_cell_delay and rt >= delay"
                }
            }
            "<= and ==" {
                if {$rt <= $worst_cell_delay && $rt == $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt <= worst_cell_delay and rt == delay"
                }
            }
            "<= and <" {
                if {$rt <= $worst_cell_delay && $rt < $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt <= worst_cell_delay and rt < delay"
                }
            }
            "<= and >" {
                if {$rt <= $worst_cell_delay && $rt > $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt <= worst_cell_delay and rt > delay"
                }
            }
            ">= and >=" {
                if {$rt >= $worst_cell_delay && $rt >= $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt >= worst_cell_delay and rt >= delay"
                }
            }
            ">= and ==" {
                if {$rt >= $worst_cell_delay && $rt == $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt >= worst_cell_delay and rt == delay"
                }
            }
            ">= and <=" {
                if {$rt >= $worst_cell_delay && $rt <= $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt >= worst_cell_delay and rt <= delay"
                }
            }
            ">= and <" {
                if {$rt >= $worst_cell_delay && $rt < $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt >= worst_cell_delay and rt < delay"
                }
            }
            ">= and >" {
                if {$rt >= $worst_cell_delay && $rt > $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt >= worst_cell_delay and rt > delay"
                }
            }
            "== and ==" {
                if {$rt == $worst_cell_delay && $rt == $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt == worst_cell_delay and rt == delay"
                }
            }
            "== and <=" {
                if {$rt == $worst_cell_delay && $rt <= $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt == worst_cell_delay and rt <= delay"
                }
            }
            "== and >=" {
                if {$rt == $worst_cell_delay && $rt >= $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt == worst_cell_delay and rt >= delay"
                }
            }
            "== and <" {
                if {$rt == $worst_cell_delay && $rt < $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt == worst_cell_delay and rt < delay"
                }
            }
            "== and >" {
                if {$rt == $worst_cell_delay && $rt > $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt == worst_cell_delay and rt > delay"
                }
            }
            "< and <" {
                if {$rt < $worst_cell_delay && $rt < $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt < worst_cell_delay and rt < delay"
                }
            }
            "< and >=" {
                if {$rt < $worst_cell_delay && $rt >= $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt < worst_cell_delay and rt >= delay"
                }
            }
            "< and >" {
                if {$rt < $worst_cell_delay && $rt > $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt < worst_cell_delay and rt > delay"
                }
            }
            "> and >" {
                if {$rt > $worst_cell_delay && $rt > $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt > worst_cell_delay and rt > delay"
                }
            }
            "> and <=" {
                if {$rt > $worst_cell_delay && $rt <= $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt > worst_cell_delay and rt <= delay"
                }
            }
            "> and ==" {
                if {$rt > $worst_cell_delay && $rt == $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt > worst_cell_delay and rt == delay"
                }
            }
            "> and <" {
                if {$rt > $worst_cell_delay && $rt < $delay} {
                    puts $fp "report_timing -from [get_object_name [get_property $one launching_point]] -to [get_object_name [get_property $one capturing_point]]; # rt > worst_cell_delay and rt < delay"
                }
            }
            default {
                puts "No valid operator pair given for sign: $sign and sign1: $sign1"
            }
        }
    }

    close $fp
}

