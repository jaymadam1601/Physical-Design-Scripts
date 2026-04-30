
set present 0
proc nets_to_variable {arg} {
set fp [open $arg r]
global unset num
global set num
set num 0
global emlist
set emlist ""
      while { [gets $fp line] >= 0 } {
      lappend emlist $line
      incr num 
      }
}

proc next_em_net {} {
global present
global emlist
deselectAll
selectNet [lindex $emlist $present]
zoomSelected
#puts "[lindex $emlist $present]"
incr present  
}



proc addInvPair {} {
puts "ecoAddRepeater -cell F6ENAA_INVX32 -net [dbGet selected.name ] -offLoadAtLoc \"[uiGetCoord] [uiGetCoord]\""
}
proc addRepeater {} {
puts "ecoAddRepeater -cell G5SUNAA_BUFX16 -net [dbGet selected.name ] -offLoadAtLoc \"[uiGetCoord] [uiGetCoord]\""
}
bindKey space {next_em_net}
#bindKey i {addInvPair}
#bindKey b {addRepeater}


