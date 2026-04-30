## 17/08/2016
## This script traces input of instances, pins or ports using all_fanin command
## We need to select either instance, pin or port for which we want to trace the fanin levels or we can specify -from option.
## Once the script is executed it wil save global variables fanin_lvl_0, fanin_lvl_1 and so on which will have information of instances or ports in each fanin level


puts "tb stages \[get_pins / get_ports\]"
puts "echo fpo(stage"

proc tb {stages query args} {
   global fp
   global fpo
   global c
   global r
   global m
   
   setLayerPreference flightLine -isVisible 0
   
   if {[info exists fpo]} {unset fpo}
   if {[info exists fp]} {unset fp}
   if {[info exists c]} {unset c}
   if {[info exists r]} {unset r}
   if {[info exists m]} {unset m}
   
   array set opts $args
   set exclude_pins {*/ti */clk TEST__* */si*}
   
   set all_sources [get_property [all_clocks ] sources]
   #set other_ports [get_ports -quiet {tlaClockGateOpen}]
   
   set query [remove_from_collection $query $all_sources]
   #set query [remove_from_collection $query $other_ports]
   
   set fi_pins [get_pins -quiet $query -f "full_name!~*__LEQ*"]
   set fi_ports [get_ports -quiet $query]
   
   set cnt 0
   if {[sizeof_collection $fi_ports]} {
       set fpo($cnt) [get_object_name $fi_ports]
   } else {
       set fpo($cnt) "null"
   }
   
   if {[sizeof_collection $fi_pins]} {
       set fp($cnt) [get_object_name $fi_pins]
   } else {
       set fp($cnt) "null"
   }
   
   set insts [get_cells -quiet -of $fi_pins]
   set regs [filter_collection $insts "is_sequential==true"]
   set insts_nu [sizeof_collection $insts]
   set regs_nu [sizeof_collection $regs]
   set ports_nu [sizeof_collection $fi_ports]
   
   set colours {red blue green yellow magenta cyan purple pink orange brown maroon violet royalblue red blue green yellow magenta cyan purple pink orange brown maroon violet royalblue}
   puts "$cnt : insts_nu($insts_nu) : ports_nu($ports_nu) : regs_nu($regs_nu)" 
   puts "#######################"
   
   if {$insts_nu != 0} {
       selectInst [get_object_name $insts]
   }
   
   if {$ports_nu != 0} {
       foreach cur_port [get_object_name $fi_ports] {selectIOPin $cur_port}
   }
   
   dehighlight
   highlight -color red
   #set start_time [exec date +%s]
   
   incr cnt
   while {$stages >= $cnt} {
  	
      set fi [all_fanin -to $query]
      set fi [remove_from_collection $fi $query]
      set fi_pins [get_pins -quiet $fi -f "full_name !~ *__LEQ*"]
      #if {[info exists opts(-e)]} {
      foreach exclude_pin $exclude_pins {
         set fi_pins [get_pins -quiet $fi_pins -f "full_name !~ $exclude_pin"]
      }
      #}
      set prev_cnt [expr $cnt - 1]
      set fi_ports [get_ports -quiet $fi]
      set fi_insts [get_cells -quiet -of $fi_pins]
      
      if {[sizeof_collection $fi_ports]} {
          set fpo($cnt) [get_object_name $fi_ports]
      } else {
      	set fpo($cnt) "null"
      }
  
      set tmp_var [remove_from_collection $fi_pins [get_pins -quiet $fp($prev_cnt)]]
      
      if {[sizeof_collection $tmp_var] == 0} {
          set fp($cnt) "null"
      } else {    
          set fp($cnt) [get_object_name [remove_from_collection $fi_pins [get_pins -quiet $fp($prev_cnt)]]]
      }
  #    set end_time [exec date +%s]
  #    set diff_time [expr $end_time - $start_time]
  #    puts "1st : $diff_time"
  #    set start_time $end_time
      
  
      ##########
  #    if {[info exists opts(-h)]} { 
       set comb [get_cells -quiet -of [get_pins -quiet $fp($cnt)] -f "is_sequential==false && number_of_pins>2"]
       if {[sizeof_collection $comb] == 0} {
           set c($cnt) "null"
       } else {
           set combo_pins [get_pins -quiet -of $comb -f "direction==in"]
           set all_combs [get_object_name [remove_from_collection -intersect [get_pins $fp($cnt)] $combo_pins]]
           set c($cnt) $all_combs
       }
       
       set mem [get_cells -quiet -of [get_pins -quiet $fp($cnt)] -f "is_macro_cell==true"]
       if {[sizeof_collection $mem] == 0} {
       	set m($cnt) "null"
       } else {
            set mem_pins [get_pins -quiet -of $mem -f "direction==out"]
            set all_mem [get_object_name [remove_from_collection -intersect [get_pins -quiet $fp($cnt)] $mem_pins]]
            set m($cnt) $all_mem
       }
  #    }
      ##########
      set fi_insts [remove_from_collection $fi_insts [get_cells -quiet -of [get_pins -quiet $fp($prev_cnt)]]]
      
      set fi_regs [filter_collection $fi_insts "is_sequential==true"]
      if {[sizeof_collection $fi_regs] == 0} {
  	set r($cnt) null
      } else {
  	set r($cnt) [get_object_name $fi_regs]
      }
  
      set mem [filter_collection $fi_insts "is_macro_cell==true"]
      set mem_nu [sizeof_collection $mem]
      set comb [filter_collection $fi_insts "number_of_pins>2 && is_sequential==false"]
      set rep [filter_collection $fi_insts "number_of_pins==2"]
      set comb_nu [sizeof_collection $comb]
      set rep_nu [sizeof_collection $rep]
      set insts_nu [sizeof_collection $fi_insts]
      set ports_nu [sizeof_collection $fi_ports]
      set regs_nu [sizeof_collection $fi_regs]
      set colour [lindex $colours $cnt]
  
      deselectAll
      
      if {$ports_nu != 0} {
  	foreach io_pin [get_object_name $fi_ports] {
  	   selectIOPin $io_pin
   	}
      }
      
      if {$insts_nu != 0} {
  	if {[info exists opts(-r)]} {
  	    selectInst [get_cells -quiet $fi_insts -f "is_sequential==true"]
  	} else {
  	    selectInst $fi_insts
  	}
      }
      
      highlight -color $colour
      puts "$cnt : $colour : regs_nu($regs_nu) : comb_nu($comb_nu) : rep_nu($rep_nu) : mem_nu($mem_nu) : ports_nu($ports_nu)" 
      if {[sizeof_collection $fi_regs] == 0} {
  	puts "No instance found in $cnt iteration, stopping .." ; break
      }
      
      if {$cnt > 10} {
  	puts "Scipt does not support levels more than 10, stopping ..." ; break
      }
  
      set query [get_pins -quiet -of $fi_regs -filter "ref_lib_pin_name==d"]
      incr cnt
  }
   deselectAll
}
