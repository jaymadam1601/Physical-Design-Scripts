#Pin placement in the block
setPinAssignMode -pinEditInBatch true
agPlaceHInstPins fp_oci_hseg_1 -layers {7 9 11 13 15} -spacing 2 -offset 20 -side bottom_left -force -pins {TEST__EDT_TDR_SOUT  etc...}
setPinAssignMode -pinEditInBatch false
