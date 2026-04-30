alias sz "size_cell"
alias ib "insert_buffer"
alias rt "report_timing -significant_digits 3"
alias rt_max "report_timing -significant_digits 3 -nets -start_end_type reg_to_reg -transition_time "
alias rt_min "report_timing -significant_digits 3 -nets -start_end_type reg_to_reg -transition_time -delay_type min"
alias rg "report_global_timing -significant_digits 3"
alias rc "report_constraints -nosplit -significant_digits 3"
alias rctran "report_constraints -nosplit -significant_digits 3 -all_violators -max_transition"
alias rccap "report_constraints -nosplit -significant_digits 3 -all_violators -max_capacitance"

proc dump_rt_setup {{max_paths "1000"} {slack_lesser_than "-0.005"}} {
	report_timing -significant_digits 3 -start_end_type reg_to_reg -nosplit -transition_time -capacitance -max_paths $max_paths -slack_lesser_than $slack_lesser_than > reg2reg_setup
	puts "Dumped $max_paths paths, for slack lesser then $slack_lesser_than"
}
