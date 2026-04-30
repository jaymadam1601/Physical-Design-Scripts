 # |--------------------------------------------------------------------------------|
 # |                                                                                |
 # |      _               Copyright (c) 2017                                        |
 # |    c a d e n c e     Cadence Design Systems Ltd.                               |
 # |                      All Rights Reserved                                       |
 # |                                                                                |
 # |                                                                                |
 # |                                                                                |
 # | This work may not be copied, re-published, uploaded, or distributed in any way,|
 # | in any medium, whether in whole or in part, without prior written permission   |
 # | from Cadence. Notwithstanding any restrictions herein, subject to compliance   |
 # | with the terms and conditions of the Cadence software license agreement under  |
 # | which this material was provided, this material may be copied and internally   |
 # | distributed solely for internal purposes for use with Cadence tools.           |
 # |                                                                                |
 # | This work is Cadence intellectual property and may under no circumstances be   |
 # | given to third parties, neither in original nor in modified versions, without  |
 # | explicit written permission from Cadence. The information contained herein is  |
 # | the proprietary and confidential information of Cadence or its licensors, and  |
 # | is supplied subject to, and may be used only by Cadence's current customers    |
 # | in accordance with, a previously executed license agreement between Cadence    |
 # | and its customer.                                                              |
 # |                                                                                |
 # | -----------------------------------------------------------------------------  |
 # | THIS MATERIAL IS PROVIDED BY CADENCE "AS IS" AND ANY EXPRESS OR IMPLIED        |
 # | WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF           |
 # | MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.           |
 # | IN NO EVENT SHALL CADENCE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL       |
 # | OR CONSEQUENTIAL DAMAGES HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,        |
 # | WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT  (INCLUDING NEGLIGENCE OR       |
 # | OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS  MATERIAL, EVEN IF        |
 # | ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                                     |
 # | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF CADENCE DESIGN SYSTEMS          |
 # |                                                                                |
 # | -----------------------------------------------------------------------------  |
 # |                                                                                |
 # | Description :                                                                  |
 # |     Script to plot waveform based on database information driven by the sdc    |
 # |                                                                                |
 # | Release:                                                                       |
 # |     17-06-28 First version                                                     |
 # |     17-07-03 Few correction to handle partial clock definition                 |
 # |     18-12-03 Add filtering out of multiple clock definition                    |
 # |     20-09-28 Fix when glitch like clock edges and more than 2 edges define     |
 # |     20-09-29 Adjust resolution to speed up graph generation                    |
 # |     21-01-25 Add switch like usage with auto argument completion.              |
 # |              Fix issue with inverted pulse clock                               |
 # |                                                                                |
 # |--------------------------------------------------------------------------------|
################################################################################
namespace eval ::user_clock_waveform {
}

set ::user_clock_waveform::w .clockWaveform

################################################################################
#---------------------------------------
proc ::user_clock_waveform::graphscale {v vmin vmax pixels} {
    return [expr {$pixels*1.0*($v-$vmin)/($vmax-$vmin)}]
}

#---------------------------------------
proc ::user_clock_waveform::max { x y } {
  if {$x!=""} { 
    if {$x<$y} {
      return $y
    } else {
      return $x
    }
  } else {
    return $y
  }
}
#---------------------------------------
proc ::user_clock_waveform::min { x y } {
  if {$x!=""} { 
    if {$x>$y} {
      return $y
    } else {
      return $x
    }
  } else {
    return $y
  }
}

#---------------------------------------
proc ::user_clock_waveform::plot {res labels} {
    # Adapted the simple graph plotter, http://wiki.tcl.tk/8552
    upvar [set state plot_[clock clicks]] plot
    array set ::user_clock_waveform::plot [list busy 0 colors {ff 00 00} res $res labels $labels]
    set ::user_clock_waveform::plot(newcolors) $::user_clock_waveform::plot(colors)
    set width [expr {[winfo screenwidth .] / 2}]
    set height [expr {[winfo screenheight .] / 2}]
    # canvas
    if {$::user_clock_waveform::w!=""} { 
      if [winfo exists $::user_clock_waveform::w] { ;# delete it. Same as clear.
          destroy $::user_clock_waveform::w
      }
    }
    if {$::user_clock_waveform::w==""} { 
      toplevel .
    } else {
      toplevel $::user_clock_waveform::w
    }
    canvas $::user_clock_waveform::w.c -width $width -height $height \
        -xscrollincrement 1 -bg beige
    pack $::user_clock_waveform::w.c -expand 1 -fill both

    wm title $::user_clock_waveform::w "Clock Waveform"
    bind $::user_clock_waveform::w.c <Configure> [list ::user_clock_waveform::draw $state]
    event generate $::user_clock_waveform::w.c <Configure>
#    return $state
}

#---------------------------------------
proc ::user_clock_waveform::draw {plot} {
    if {$::user_clock_waveform::plot(busy)} return
    set ::user_clock_waveform::plot(busy) 0
    $::user_clock_waveform::w.c addtag all all
    $::user_clock_waveform::w.c delete all
    set ::user_clock_waveform::plot(newcolors) $::user_clock_waveform::plot(colors)
    set res [lsort -real -index 0 $::user_clock_waveform::plot(res)]
    # get range of x & y
    set width  [winfo width  $::user_clock_waveform::w.c]
    set height [winfo height $::user_clock_waveform::w.c]

    variable xmin {} xmax {} ymin {} ymax {}
    set nvars [expr {[llength [lindex $res 0]]-1}]
    foreach item $::user_clock_waveform::plot(res) {
        set y [lassign $item r]
        set xmin [::user_clock_waveform::min $xmin $r]
        set xmax [::user_clock_waveform::max $xmax $r]
        foreach yv $y { ;# get range of Y coordinate
            set ymin [::user_clock_waveform::min $ymin $yv]
            set ymax [::user_clock_waveform::max $ymax $yv]
        }
    }
    # Y dimension is defined by the number of clocks
    set ymax [expr $ymax +1]
    set ymin [expr $ymin -1]

    #Draw X axis 
    set nextXaxis 0
    while {$nextXaxis < $xmax} { ;# draw grid
        set xpix [::user_clock_waveform::graphscale $nextXaxis $xmin $xmax $width]
        $::user_clock_waveform::w.c create text [expr {$xpix-10}] 0 -anchor n -text [format %.3f [expr $nextXaxis]] \
            -fill lightgray
        $::user_clock_waveform::w.c create line $xpix 0 $xpix $height -fill lightgray
        set nextXaxis [expr {$nextXaxis+$::user_clock_waveform::xgrid}]
    }

    # Draw 0 reference and label for each clock waveform
    set idx [expr [llength $::user_clock_waveform::plot(labels)]-1]
    set ygrid 2 ;# how often to draw grid in Y
    set nextYaxis [expr {int($ymin/$ygrid)*$ygrid+$ygrid}]
    while {$nextYaxis < $ymax} { ;# draw grid
        set ypix [::user_clock_waveform::graphscale $nextYaxis $ymax $ymin $height]
        set nextYaxis [expr {$nextYaxis+$ygrid}]
        # Clock label
        set label [lindex $::user_clock_waveform::plot(labels) $idx] 
        $::user_clock_waveform::w.c create text [expr [::user_clock_waveform::graphscale 0 $xmin $xmax $width]+10] [expr $ypix-20] -anchor nw -text $label \
            -fill black
        $::user_clock_waveform::w.c create line 0 $ypix $width $ypix -fill lightgray
        incr idx -1
    }

    for {set iy 0} {$iy<$nvars} {incr iy} {
        lassign $::user_clock_waveform::plot(newcolors) red green blue
        lappend ::user_clock_waveform::plot(newcolors) $red 
        set ::user_clock_waveform::plot(newcolors) [lreplace $::user_clock_waveform::plot(newcolors) 0 0]

        set coordlist {}
        foreach item $res {
                set y [lassign $item r]
                set xpix [::user_clock_waveform::graphscale $r $xmin $xmax $width]
                set vv [lindex $y $iy]
                set v [::user_clock_waveform::graphscale $vv $ymax $ymin $height]
                lappend coordlist $xpix $v
           set rold $xpix
           set yold $v         ;# vector of y values
         }
        $::user_clock_waveform::w.c create line $coordlist -fill #$red$green$blue
    }
    set ::user_clock_waveform::plot(busy) 0
}

################################################################################
##########  Main Procedure
################################################################################
define_proc user_clock_waveform \
     -description "Display clocks waveform of the corresponding active analysis view." \
    {
    { clocks  ""    -clocks  string optional "To filter by giving a list of clock names to vizualize only, else all active clocks will be displayed" }
    { xgrid   0.1   -xgrid   float  optional "Time unit grid step displayed"                         }
    { verbose false -verbose bool   optional "verbose mode"                                          }
    } \
{
    set ::user_clock_waveform::xgrid      $xgrid
    set ::user_clock_waveform::resolution 100
    set all_clocks {}
    set all_edges {}
    if {$clocks!=""} {
      set clock_to_process [get_clocks $clocks]
    } else {
      set clock_to_process [all_clocks ]
    }
    set clock_already_processed {}
    foreach_in_collection c $clock_to_process { 
      if {[lsearch $clock_already_processed [get_object_name $c ]]<0} {
        set c_high_or_low 0
        if {[get_property $c edges]!="NA"} { ; # Specific case when inverted pulse clock 
          set e_list_tmp [split [regsub -all {[ ]} [lindex [get_property $c edges] 0] ""] ","]
          if {[lindex $e_list_tmp end-1]==[lindex $e_list_tmp end]} {
            set c_high_or_low 1
          }
        }
        
        lappend clock_already_processed [get_object_name $c ]
        set _error 0
        if { [get_property $c waveform]!="" && [get_property $c waveform]!="NA"} {
          set edge_list {}
          foreach e [lindex [get_property $c waveform] 0] {
            lappend edge_list [expr int($e*$::user_clock_waveform::resolution)]
          }
        } else {
          set _error 1
          puts "ERROR : Clock [get_object_name $c ] has no waveform defined."
        }
        if { [get_property $c period  ]!="" && [get_property $c period  ]!="NA"} {
          set p  [expr int([lindex [get_property $c period  ] 0]*$::user_clock_waveform::resolution)]
        } else {
          set _error 1
          puts "ERROR : Clock [get_object_name $c ] has no period defined."
        }
        if {$_error==0} {
          lappend all_clocks [list [get_object_name $c ] $edge_list $p $c_high_or_low]
          set edge_list_real {}
          foreach e $edge_list {  lappend all_edges $e ; lappend edge_list_real [expr $e.0/${::user_clock_waveform::resolution}]}
          lappend all_edges $p
          lappend names [get_object_name $c ] 
          if { $verbose} { 
            puts "INFO : Clock [get_object_name $c ]"
            puts "       Period [expr $p.0/${::user_clock_waveform::resolution}] / Edges $edge_list_real"
          }
        } else {
          if { $verbose} { 
            puts "INFO : Clock [get_object_name $c ] skipped due to previous ERROR"
          }
        }
      } else {
        puts "WARN : Clock [get_object_name $c ] already processed..."
        puts "       This means either that you have different analysis"
        puts "       view (in setup+hold) using the same SDC sets."
        puts "       Or with different SDC but some using same clock name,"
        puts "       which is not supported."
        puts "       Recommandation is to use a single analysis view for setup and hold."
        puts ""
      }
    }
#    set all_edges [lsort -integer -unique $all_edges]
    set all_edges [lsort -real -unique $all_edges]
    
    ### Repeat all clock edges along "simulation time"
    set time_stop [expr int(2.2*[lindex $all_edges end])]
    set new_all_clocks {}
    foreach clk $all_clocks {
      foreach [list c edge_list p start] $clk {}
      set k 0
      set new_edge_list {}
      set last_c_high_or_low -1
      while {[expr [lindex $edge_list 0]+$k*$p]<$time_stop} {
        if {$start==1} {
          set c_high_or_low 1
        } else {
          set c_high_or_low 0
        }
        if {[lindex $edge_list 0]>0} { 
          set new_edge_list [concat $new_edge_list [list [expr 0+$k*$p] $c_high_or_low]]
        }
        if {$start==1} {
          set c_high_or_low 0
        } else {
          set c_high_or_low 1
        }
        foreach e $edge_list {
          if {[expr $e+$k*$p] >= $time_stop } { break }
          set new_edge_list [concat $new_edge_list [list [expr $e+$k*$p] $c_high_or_low]]
          set last_c_high_or_low $c_high_or_low
          if {$c_high_or_low==1} { set c_high_or_low 0
          } else {set c_high_or_low 1 }
        }
        incr k
      }
      if { $last_c_high_or_low != -1 } { set new_edge_list [concat $new_edge_list [list $time_stop $last_c_high_or_low]] }
      lappend new_all_clocks [list $c $new_edge_list]
    }
    
    ### Plot creation
    set plot [list] 
    for {set i 0} {$i<=$time_stop} {incr i} {
        set toplot [expr $i.0/${::user_clock_waveform::resolution}]
        set j 0
        foreach clk $new_all_clocks {
          foreach [list c edge_list] $clk {}
          set previous_edge -1
          set y [expr 0.5-$j*2]
          foreach [list e HL] $edge_list {
            if {$e==$previous_edge} { 
              set e [expr $e+0.1]
            }
            if {$i>=$e} { 
              if { $HL == 0 } {
                set y [expr -$j*2]
              } else {
                set y [expr 1-$j*2]
              }
            }
            set previous_edge $e
          }
          lappend toplot $y
          incr j
        }
        lappend plot $toplot
    }
    ::user_clock_waveform::plot $plot $names
}



 # |-------------------------------------------------------------|
 # |                                                             |
 # | PROPRIETARY INFORMATION, PROPERTY OF CADENCE DESIGN SYSTEMS |
 # |                                                             |
 # |-------------------------------------------------------------|


