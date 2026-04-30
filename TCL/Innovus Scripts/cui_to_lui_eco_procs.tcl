define_proc_arguments eco_update_cell -info "eco_update_cell" \
  -define_args {
    { -location                    " instance_target_location    " "" "list"    "optional"}
    { -pin_maps                    " pin mapping if different   " "" "list"    "optional"}
    { -insts                       " target instance(s)         " "" "list"    "required"}
    { -cells                       " target cell reference      " "" "list"    "required"}
    { -orient                      " orientation                " "" "string"  "optional"}
    { -max_displacement            " not supported              " "" "list"    "optional"}
    { -down_size                   " downsize cell              " "" "boolean" "optional"}
    { -up_size                     " upsize cell                " "" "boolean" "optional"}
    { -ignore_power_intent_check   " not supported              " "" "boolean" "optional"}
    { -help                        " help                       " "" "boolean" "optional"} }

proc eco_update_cell { args } {
  parse_proc_arguments -args $args opts
  set Legacy_cmd "ecoChangeCell"
  foreach argname [array name opts] {
    switch $argname {
      -location { lappend Legacy_cmd "-loc"    $opts($argname) }
      -pin_maps { lappend Legacy_cmd "-pinMap" $opts($argname) }
      -insts    { lappend Legacy_cmd "-inst"   $opts($argname) }
      -cells    { lappend Legacy_cmd "-cell"   $opts($argname) }
      -down_size  { lappend Legacy_cmd "-downsize" }
      -up_size  { lappend Legacy_cmd "-upsize" }
       default   { if {$opts($argname) == ""} { lappend Legacy_cmd $argname} else { lappend Legacy_cmd $argname $opts($argname) }}
    }
  }
  puts "ORIG_CHGECELL_CMD : eco_update_cell  $args"
  puts "TRANS_CHGECELL_CMD : $Legacy_cmd"
  catch {uplevel eval $Legacy_cmd} msg1
  return $msg1
}

define_proc_arguments eco_add_repeater -info "eco_add_repeater" \
  -define_args {
    { -location                    " instance_target_location   " "" "list"    "optional"}
    { -name                        " name                       " "" "list"    "optional"}
    { -net                         " net                        " "" "list"    "optional"}
    { -new_net_name                " new_net_name               " "" "list"    "optional"}
    { -pins                        " target instance(s)         " "" "list"    "required"}
    { -buffer_orient               " orientation                " "" "string"  "optional"}
    { -cells                       " target cell reference      " "" "list"    "required"}
    { -load_cell                   " load_cell                  " "" "boolean" "optional"}
    { -relative_distance_to_sink   " relative_distance_to_sink  " "" "float"   "optional"}
    { -hinst_guide                 " hinst_guide                " "" "string"  "optional"}
    { -corner_specs                " corner_specs (unsupported) " "" "string"  "optional"}
    { -help                        " help                       " "" "boolean" "optional"} }

proc eco_add_repeater { args } {
  parse_proc_arguments -args $args opts
  set Legacy_cmd "ecoAddRepeater"
  foreach argname [array name opts] {
    switch $argname {
      -pins       { lappend Legacy_cmd "-term"      $opts($argname) }
      -cells      { lappend Legacy_cmd "-cell"      $opts($argname) }
      -new_net_name      { lappend Legacy_cmd "-newNetName"      $opts($argname) }
      -location   { lappend Legacy_cmd "-loc"       "\{$opts($argname)\}" }
      -relative_distance_to_sink   { lappend Legacy_cmd "-relativeDistToSink"       $opts($argname) }
      -load_cell  { lappend Legacy_cmd "-loadCell" }
      -buffer_orient { lappend Legacy_cmd "-bufOrient" $opts($argname) }
      -hinst_guide { lappend Legacy_cmd "-hinstGuide" $opts($argname) }
      -corner_specs {}
      default     { if {$opts($argname) == ""} { lappend Legacy_cmd $argname} else { lappend Legacy_cmd $argname $opts($argname) }}
    }
  }
  puts "ORIG_ADDREP_CMD : eco_add_repeater $args"
  puts "TRANS_ADDREP_CMD : $Legacy_cmd"
  catch {uplevel eval $Legacy_cmd} msg1
  return $msg1
}

define_proc_arguments eco_delete_repeater -info "eco_delete_repeater" \
  -define_args {
    { -insts                       " name                       " "" "list"    "optional"}
    { -inverter_pair               " name                       " "" "list"    "optional"}
    { -help                        " help                       " "" "boolean" "optional"} }

proc eco_delete_repeater { args } {
  parse_proc_arguments -args $args opts
  set Legacy_cmd "ecoDeleteRepeater"
  foreach argname [array name opts] {
    switch $argname {
      -insts              { lappend Legacy_cmd "-inst"      $opts($argname) }
      -inverter_pair      { lappend Legacy_cmd "-invPair"      $opts($argname) }
      default             { if {$opts($argname) == ""} { lappend Legacy_cmd $argname} else { lappend Legacy_cmd $argname $opts($argname) }}
    }
  }
  puts "ORIG_DELREP_CMD : eco_delete_repeater $args"
  puts "TRANS_DELREP_CMD : $Legacy_cmd"
  catch {uplevel eval $Legacy_cmd} msg1
  return $msg1
}

if { [info command eval_legacy] eq "" } {
  proc eval_legacy args {
    catch {uplevel eval $args} msg1
    return $msg1
  }
}

proc place_detail args  {
  set Legacy_cmd refinePlace
  set hard_place_false 0
  for {set i 0} {$i < [llength $args]} {incr i} { 
    set opt [lindex $args $i]
    if {$opt ne "-hard_fence"} {
      lappend Legacy_cmd $opt 
    } else {
      incr i
      set hard_place_false 1
    }
  }
  if { $hard_place_false } {
    set orig_hard_place_val [getPlaceMode -place_hard_fence]
    set Legacy_cmd "setPlaceMode -place_hard_fence false ; $Legacy_cmd ; setPlaceMode -place_hard_fence $orig_hard_place_val"
  }
  puts "ORIG_PLACEDET_CMD : place_detail $args"
  puts "TRANS_PLACEDET_CMD : $Legacy_cmd"
  catch {uplevel eval $Legacy_cmd} msg1
  return $msg1
}

