create_ccopt_clock_tree -name PbamClk.CTS -source PbamClk
create_ccopt_generated_clock_tree -name PbamClk_gen.CTS -source CTS_JM_exlusive_skewGrp_1/o -generated_by CTS_JM_exlusive_skewGrp_1/i

create_ccopt_skew_group -name PbamClk.skewGrp_without_mux -sources CTS_JM_exlusive_skewGrp_1/o -auto_sinks -target_insertion_delay 300ps -target_skew 20ps

