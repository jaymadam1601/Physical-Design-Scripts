for checking crostalk delta on nets (mainly used for clock nets crosstalk)
redirect xtalk.rpt {report_timing -through ds*/CLK_IN -significant_digits 3 -delay_type max -nets -path_type full_clock_expanded -crosstalk_delta -nosplit -max_paths 100000 }
grep -C1 "(net)" xtalk.rpt | sed 's/<-//' | awk '/\(net\)/{line=$1;getline;print prev" "line" "$1,$3} {prev=$1}' | awk '$4 != 0 {print}' | sort -u
