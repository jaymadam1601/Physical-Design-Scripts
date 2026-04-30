proc blockInfo {} {
   puts "####################  BLOCK INFORMATION ###########################"
   set coreBox [dbu2uu [dbHeadCoreBox [dbgHead]]]
   set coreWidth [expr [lindex $coreBox 2] - [lindex $coreBox 0]]
   set coreHeight [expr [lindex $coreBox 3] - [lindex $coreBox 1]]
   set numInputIOs [dbCellNrInput [dbgTopCell]]
   set numOutputIOs [dbCellNrOutput [dbgTopCell]]
   set numBidrIOs [dbCellNrIo [dbgTopCell]]
   puts " Block Name               :  [dbgDesignName]"
   puts " Core Size (W X H) um^2   :  ${coreWidth} * ${coreHeight}"
   puts " Aspect Ratio             :  [expr ${coreHeight}/${coreWidth}]"
   puts " Std Cells Count          :  [expr ([dbCellNrStdCell [dbgTopCell]] - [dbCellNrPhysicalInst [dbgTopCell]])/1000.0]K"
   puts " Macro's Count            :  [dbCellNrBlock [dbgTopCell]]"
   Puts " Total IOs                :  [expr $numInputIOs+$numOutputIOs+$numBidrIOs]"
   Puts " No. of Input IOs         :  [dbCellNrInput [dbgTopCell]]"
   Puts " No. of Output IOs        :  [dbCellNrOutput [dbgTopCell]]"
   puts  "###################################################################"
}

proc get_memPlace {} {
  if {[file exists memplace.tcl]} {
    puts "**INFO : \"memplace.tcl\" file is already existed in this directory"
    set timestamp [exec date -r memplace.tcl +%d-%m-%Y_%H:%M]
    puts "**INFO : Taking the backup as \"memplace.tcl_${timestamp}\" file"
    exec  mv memplace.tcl memplace.tcl_${timestamp}
  }
  set IN [open "memplace.tcl" w]
  set insts [dbGet top.insts.cell.baseClass block -p2]
  foreach inst $insts {
    set instName [dbGet $inst.name]
    set ori [dbGet $inst.orient]
    set loc [dbu2uu [dbInstLoc [dbGetInstByName $instName]]]
    puts $IN "placeInstance $instName $loc $ori -fixed"
  }
  puts $IN "##INFO: All Macros pStatus making as FIXED"
  puts $IN "dbSet \[dbGet top.insts.cell.baseClass block -p2\].pstatus fixed"
  close $IN
  puts "**INFO : macro placement information is in \"memplace.tcl\" file"
}

proc vconn {} {
  deselectAll
  editSelect -nets *
  editDeselect -nets *_ROUTE__DELETE*
  eval verifyConnectivity -selected -type all -geomConnect -noAntenna -error 10000 -warning 50
  deselectAll
}

proc vdrc {} {
  verify_drc -view_window -limit 10000
}

proc save_db {} {
  global DST_DATA_DIR
  global DESIGN
  mt_saveDefVlogRoute $DST_DATA_DIR ""
  agAddIsTermSpecialProp
  saveDesign $DST_DATA_DIR/${DESIGN}.enc -netlist -tcon
}

proc save_backup_db {} {
  global DST_DATA_DIR
  global DESIGN
  mt_saveDefVlogRoute $DST_DATA_DIR ".bak"
  agAddIsTermSpecialProp
  saveDesign $DST_DATA_DIR/${DESIGN}.bak.enc -netlist -tcon
}

proc change_selection {coll} {
  foreach_in_coll c $coll {    
    set objName [get_object_name $c]
    set objType [dbGet [dbGetObjByName $objName].objType]
    if { [regexp {^instTerm$} $objType] } {
      if { [dbTermName [dbGetObjByName $objName]] == "SI" } {continue}
      set inst [dbTermInst [dbGetObjByName $objName]]
      if { [regexp {cklbal} [dbInstCellName $inst]] || [regexp {filldiode} [dbInstCellName $inst]] || [regexp {tie} [dbInstCellName $inst]] } {continue}
      selectInst [dbInstName $inst]
    }
    if { [regexp {^term$} $objType] } {
     # if { [regexp {^TEST__} $objName] || [regexp {bist_} $objName] } {continue}
      #puts "Port $objName is also one of the fanin/fanout cone"
      selectIOPin $objName
    #}
  }
}

#proc faninc_of_selection {} {
#  cs  [all_fanin -to [get_pins -of [gs] -filter "direction == in && name != SI && name !=SE && name !=CK && name != TEST__TDR_SIN && name !~TEST__SIN* && name != ROW_REDN_IN && name != COL_REDN_IN "] -startpoints_only]
#}
#
#proc fanoutc_of_selection {} {
#  cs  [all_fanout -from [get_pins -of [gs] -filter "direction == out && name != SO && name !~TEST__SO* && name != ROW_REDN_OUT && name !~ COL_REDN_OUT*  && name !=TEST__TDR_SOUT && name !=TEST__DFT_CLK "] -endpoints_only]
#}

define_proc_arguments get_fanin \
  -info "Highlight Fanin Cone of given objects(inst/instTerm/port) " \
  -define_args { \
    {to "Name of the inst/instTerm/port in design" "" string required} \
    {-include_cells "Returns combinational cells with endpoints in the fanout" "" boolean} \
  }

proc get_fanin {args} {
  set results(-include_cells) 0
  set cmd "all_fanin -startpoints_only -to "
  parse_proc_arguments -args $args results
  set objs $results(to)
  if { $results(-include_cells) } { set cmd "all_fanin -to " }

  deselectAll
  foreach objName $objs {
    set objType [dbGet [dbGetObjByName $objName].objType]
    switch -exact $objType {
      term {
        if { [dbIsFTermInput [dbGetFTermByName $objName]] && ![dbIsFTermBidi [dbGetFTermByName $objName]] } {continue}
	puts "1 $cmd $objName"
        cs  [eval $cmd $objName]
      }
      instTerm {
	puts "2 $cmd $objName"
        cs  [eval $cmd $objName]
      }
      default {
##SJ 26/Oct
        set pins [get_pins -quiet -of $objName -filter "direction == in && is_clock != true && full_name !~ */SI && full_name !~ */SE && full_name !~ */*CLK* && full_name !~ */ROW_REDN_IN && full_name !~ */COL_REDN_IN && net_name !~ *TIEHI* && net_name !~ *TIELO* && full_name !~ */TEST__* && full_name !~ */*BIST* && full_name !~ */*TMG_MODE* && full_name !~ */ROW_RE* && full_name !~ */COL_RE* && full_name !~ */CORE_* && full_name !~ */WEA && full_name !~ */REB && full_name !~ */ti && full_name !~ */te"]
        if { $pins != "" } { 
		puts "3 $cmd $objName"
		cs  [eval $cmd $pins] 
	}
      }
    }
  }
}

define_proc_arguments get_fanout \
  -info "Highlight Fanout Cone of given objects(inst/instTerm/port) " \
  -define_args { \
    {from "Name of the inst/instTerm/port in design" "" string required} \
    {-include_cells "Returns combinational cells with endpoints in the fanout" "" boolean} \
  }

proc get_fanout {args} {
  set results(-include_cells) 0
  set cmd "all_fanout -endpoints_only -from "
  parse_proc_arguments -args $args results
  set objs $results(from)
  if { $results(-include_cells) } { set cmd "all_fanout -from " }

  deselectAll
  foreach objName $objs {
    set objType [dbGet [dbGetObjByName $objName].objType]
    switch -exact $objType {
      term {
        if { [dbIsFTermOutput [dbGetFTermByName $objName]] && ![dbIsFTermBidi [dbGetFTermByName $objName]] } {continue}
        cs  [eval $cmd $objName]
      }
      instTerm {
        cs  [eval $cmd $objName]
      }
      default {
##SJ 26/Oct
        set pins [get_pins -of $objName -quiet -filter "direction == out && full_name !~ */SO && full_name !~ */TEST* && full_name !~ */ROW_RE* && full_name !~ */COL_RE*  && full_name !~ */BIST_DONE* && fanout != 0"]
        if { $pins != "" } { cs  [eval $cmd $pins] }
      }
    } 
  } 
}

define_proc_arguments fanin_of_selection \
  -define_args { \
    {level "No of level to trace back" "" one_of_string {optional {values {1 2 3 4 5}}}} \
  }

proc fanin_of_selection {args} {
  global color
  parse_proc_arguments -args $args results         
  if { ![info exists results(level)] } { get_fanin [gs] ; return }
  highlight -color [lindex $color 0]
  for {set l 1} {$l<=$results(level)} {incr l} {
    set selObj [gs]
    get_fanin $selObj
    foreach objName $selObj {
      set objType [dbGet [dbGetObjByName $objName].objType]
      switch -exact $objType {
        term { deselectIOPin $objName }
        instTerm { deselectPin $objName }
        default { deselectInst $objName }
      }
    }
    highlight -color [lindex $color $l]
  }
}

define_proc_arguments fanout_of_selection \
  -define_args { \
    {level "No of level to trace back" "" one_of_string {optional {values {1 2 3 4 5}}}} \
  }

proc fanout_of_selection {args} {
  global color
  parse_proc_arguments -args $args results         
  if { ![info exists results(level)] } { get_fanout [gs] ; return }
  highlight -color [lindex $color 0]
  for {set l 1} {$l<=$results(level)} {incr l} {
    set selObj [gs]
    get_fanout $selObj
    foreach objName $selObj {
      set objType [dbGet [dbGetObjByName $objName].objType]
      switch -exact $objType {
        term { deselectIOPin $objName }
        instTerm { deselectPin $objName }
        default { deselectInst $objName }
      }
    }
    highlight -color [lindex $color $l]
  }
}

proc fanin_analysis {} {
  set fp [open fanin.tcl w]
  set cells [dbGet [dbGet top.insts.cell.isSequential 1 -p2 ].name]
  foreach_in_collection i [get_pins -quiet -of $cells -filter "direction == in && is_clock != true && name != CLR_N && name != SI && name != SE && name !~ *CLK* && name !~ TEST__* && name != ROW_REDN_IN && name != COL_REDN_IN && net_name !~ *TIEHI* && net_name !~ *TIELO*"] {
    set pin [get_object_name $i]
    puts $fp "$pin = [sizeof_collection [ all_fanin -startpoints_only -only_cells -to $pin]]"
  }
  close $fp
  exec cat fanin.tcl | sort -k 3 -nr > fanin.rpt
  exec rm -f fanin.tcl
}

proc fanout_analysis {} {
  set fp [open fanout.tcl w]
  set cells [dbGet [dbGet top.insts.cell.isSequential 1 -p2 ].name]
  foreach_in_collection i [get_pins -of $cells -quiet -filter "direction == out && name != SO && name !~ TEST__SO* && name != ROW_REDN_OUT && name !~ COL_REDN_OUT*  && name != TEST__TDR_SOUT && name != TEST__DFT_CLK && fanout != 0"] {
    set pin [get_object_name $i]
    puts $fp "$pin = [sizeof_collection [ all_fanout -endpoints_only -only_cells -from $pin]]"
  }
  close $fp
  exec cat fanout.tcl | sort -k 3 -nr > fanout.rpt
  exec rm -f fanout.tcl
}

