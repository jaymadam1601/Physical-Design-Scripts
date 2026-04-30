## 17/08/2016
## This script traces output of instances, pins or ports using all_fanout command
## We need to select either instance, pin or port for which we want to trace the fanout levels, or we can specify -from option.
## Once the script is executed it wil save global variables lvl_0, lvl_1 and so on which will have information of instances or ports in each fanout level

puts "tf stages \[get_pins -quiet / get_ports\]"
proc tf {stages query args} {
   global po
   global p
   global c
   global r
   global m
   
   setLayerPreference flightLine -isVisible 0
   
   if {[info exists po]} {unset po}
   if {[info exists p]} {unset p}
   if {[info exists c]} {unset c}
   if {[info exists r]} {unset r}
   if {[info exists m]} {unset m}
   
   array set opts $args
   set exclude_pins {*/ti */TEST__* */REB* */si*}
   set all_sources [get_property [all_clocks ] sources]
   #set other_ports [get_ports -quiet {tlaClockGateOpen}]
   #set query [remove_from_collection $query $other_ports]
   #set fo_pins [filter_collection $query "object_class==pin && full_name!~*__LEQ*"]
   set fo_pins [get_pins -quiet $query -filter "full_name !~ *__LEQ*"]
   #set fo_ports [filter_collection $query "object_class==port"]
   set fo_ports [get_ports -quiet $query]
   set cnt 0
   if {[sizeof_collection $fo_ports]} {
       set po($cnt) [get_object_name $fo_ports]
   } else {
       set po($cnt) ""
   }
   
   if {[sizeof_collection $fo_pins]} {
       set p($cnt) [get_object_name $fo_pins]
   } else {
       set p($cnt) ""
   }
   
   set insts [get_cells -quiet -of $fo_pins]
   set regs [filter_collection $insts "is_sequential==true"]
   set insts_nu [sizeof_collection $insts]
   set regs_nu [sizeof_collection $regs]
   set ports_nu [sizeof_collection $fo_ports]
   
   dehighlight
   deselectAll
   
   if {$insts_nu != 0} { 
       selectInst [get_object_name $insts]
   }

   if {$ports_nu != 0} {
       foreach cur_port [get_object_name $fo_ports] {selectIOPin $cur_port}
   }

   set colours {red blue green yellow magenta cyan purple pink orange brown maroon violet royalblue red blue green yellow magenta cyan purple pink orange brown maroon violet royalblue}
   set colour [lindex $colours $cnt]
   highlight -color $colour
   puts "$cnt : $colour : insts_nu($insts_nu) : ports_nu($ports_nu) : regs_nu($regs_nu)" 
   puts "#######################"
   
   incr cnt
   while {$stages >= $cnt} {
      set fo [all_fanout -from $query]
      set fo [remove_from_collection $fo $query]
      set fo_pins [get_pins -quiet $fo -filter "full_name !~ *__LEQ*"]

      foreach exclude_pin $exclude_pins {
         set fo_pins [get_pins -quiet $fo_pins -f "full_name !~ $exclude_pin"]
      }

      set prev_cnt [expr $cnt - 1]
      set fo_ports [get_ports -quiet $fo -filter "object_class==port"]
      set fo_insts [get_cells -quiet -of $fo_pins]
      
      if {[sizeof_collection $fo_ports]} {
          set po($cnt) [get_object_name $fo_ports]
      } else {
      	  set po($cnt) ""
      }
      
      if {[sizeof_collection $fo_pins]} {
      	  set p($cnt) [get_object_name [remove_from_collection $fo_pins [get_pins -quiet $p($prev_cnt)]]]
      } else {
      	  set p($cnt) ""
      }
   
      ##########
   #   if {[info exists opts(-h)]} {
      set comb [get_cells -quiet -of [get_pins -quiet $p($cnt)] -f "is_sequential==false && number_of_pins > 2"]
      if {[sizeof_collection $comb] == 0} {
      	  set c($cnt) "null"
      } else {
          set comb_pins [get_pins -quiet -of $comb -f "direction==in"]
          set all_combs [get_object_name [remove_from_collection -intersect [get_pins -quiet $p($cnt)] $comb_pins]]
          set c($cnt) $all_combs
      }
      
      set mem [get_cells -quiet -of [get_pins -quiet $p($cnt)] -f "is_macro_cell==true"]
      if {[sizeof_collection $mem] == 0} {
          set m($cnt) "null"
      } else {
          set mem_pins [get_pins -quiet -of $mem -f "direction==in"]
          set all_mem [get_object_name [remove_from_collection -intersect [get_pins -quiet $p($cnt)] $mem_pins]]
          set m($cnt) $all_mem
      }
   #   }
      #########
   
      set fo_insts [remove_from_collection $fo_insts [get_cells -quiet -quiet -of [get_pins -quiet -quiet $p($prev_cnt)]]]
      set fo_regs [filter_collection $fo_insts "is_sequential==true && is_macro_cell==false"]
      set r($cnt) [get_object_name $fo_regs]
   
      set mem [filter_collection $fo_insts "is_macro_cell==true"]
      set mem_nu [sizeof_collection $mem]
      set insts_nu [sizeof_collection $fo_insts]
      set comb [filter_collection $fo_insts "number_of_pins>2 && is_sequential==false"]
      set rep [filter_collection $fo_insts "number_of_pins==2"]
      set comb_nu [sizeof_collection $comb]
      set rep_nu [sizeof_collection $rep]
      set ports_nu [sizeof_collection $fo_ports]
      set regs_nu [sizeof_collection $fo_regs]
      set colour [lindex $colours $cnt]
   
      deselectAll
      if {$ports_nu != 0} {
          foreach io_pin [get_object_name $fo_ports] {
             selectIOPin $io_pin
          }
      }
      
      if {$insts_nu != 0} {
          if {[info exists opts(-r)]} {
	      selectInst [get_cells -quiet $fo_insts -f "is_sequential==true"]
          } elseif {[info exists opts(-rc)]} {
	      selectInst [get_cells -quiet $fo_insts -f "is_sequential==true && number_of_pins>2"]
          } else {
              selectInst $fo_insts
	  }
	  highlight -color $colour
      }
      
      puts "$cnt : $colour : regs_nu($regs_nu) : comb_nu($comb_nu) : rep_nu($rep_nu) : mem_nu($mem_nu) : ports_nu($ports_nu)" 
      
      if {[sizeof_collection $fo_regs] == 0} {
	  puts "No instance found in $cnt iteration, stopping .." ; break
      }
      
      if {$cnt > 10} {
	  puts "Scipt does not support levels more than 10, stopping ..." ; break
      }
      
      set query [get_pins -quiet -of $fo_regs -filter "direction==out"]
      incr cnt
   }
   deselectAll
}
