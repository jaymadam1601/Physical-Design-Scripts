proc report_skew_group_sizes { { OUTFILE skew_group_sizes.txt } { OUTDIR . } } {
    global run_tag; # need to declare this
    global RUN_TAG; # need to declare this
    puts ""
    if { [ info exists RUN_TAG ] } {
        puts " INFO >> inheriting RUN_TAG variable setting : $RUN_TAG\n"
        set OUTDIR "runs/$RUN_TAG/skew_groups"
    }
    if { [ info exists run_tag ] } {
        puts " INFO >> inheriting run_tag variable setting : $run_tag\n"
        set OUTDIR "runs/$run_tag/skew_groups"
    }
    set OUTFILE "$OUTDIR/${OUTFILE}"
    file mkdir $OUTDIR
    puts " INFO >> writing to output directory : $OUTDIR\n"
    if { ! [ catch { set outfile [open $OUTFILE w] } ] } {
        foreach skew_group [ get_ccopt_skew_groups * ] {
            puts " INFO >> $skew_group ; number of sinks : [llength [get_ccopt_property sinks -skew_group $skew_group] ]"
            puts $outfile " INFO >> $skew_group ; number of sinks : [llength [get_ccopt_property sinks -skew_group $skew_group] ]"
        }
        puts "\n INFO >> skew group size listing in file : $OUTFILE\n"
        close $outfile
    } else {
        puts "\n INFO >> can't write to output file : $OUTFILE\n"
    }
}
