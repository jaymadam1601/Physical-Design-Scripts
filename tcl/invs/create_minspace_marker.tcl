proc create_minspace_marker {spacing_x spacing_y} {
  global DST_RPTS_DIR
  global DESIGN 
  clearDrc
  set selected_objects [dbGet selected]
  foreach a $selected_objects {
      if {[dbGet $a.objType] != "inst"} {
         puts "### [dbGet $a] is not of object type Memory. "
         puts "### Deselecting it"
         deselect_obj $a
      }
    }
  if {[llength [dbGet selected]] < 2} {
      puts "### You need to have selected at least 2 memories"
      return
   }
   if {$spacing_x!=0} {set spacing_x [expr $spacing_x - 0.01]}
   if {$spacing_y!=0} {set spacing_y [expr $spacing_y - 0.01]}
   set half_spacing_x [expr $spacing_x / 2]
   set half_spacing_y [expr $spacing_y / 2]
   set inst_boxes [dbGet selected.boxes]

   set boxes_less_than_spacing [dbShape $inst_boxes SIZEX $half_spacing_x SIZEY $half_spacing_y SIZEX -$half_spacing_x SIZEY -$half_spacing_y ANDNOT $inst_boxes]
   foreach box $boxes_less_than_spacing {
       createMarker -bbox $box -desc "Memories are closer than x = $half_spacing_x or y = $half_spacing_y apart" -type user_verify
   }

   if {[llength $boxes_less_than_spacing] > 0} {
       puts "### ERROR INFO: Created [llength $boxes_less_than_spacing] spacing violations markers at $DST_RPTS_DIR/${DESIGN}_memory_spacing.drc"
   } else {
       puts "### INFO:  Good, There are no spacing violations for the [llength [dbGet selected]] selected Memories"
   }
saveDrc $DST_RPTS_DIR/${DESIGN}_memory_spacing.drc
deselectAll
}
deselectAll
if {[regexp 0x0 [dbget top.insts.cell.baseClass block]]} {
    puts "No Memory found,Hence Exiting ...."
    return
} else { selectInst [dbget [dbget top.insts.cell.baseClass block -p2].name] }
puts "create_minspace_marker <spacing_x> <spacing_y>"
