######################################################################
# check_clock_tree_topology  (IMPROVED — WITH GLOBAL SUMMARY)
######################################################################

#Creators: 
#  CTSG      Unnamed - this should not be used any more.
#  cuk       Cts: Unknown creator, will not appear in the netlist.
#  ccl_a     Cts: Created during clustering by the agglom clustering algorithm.
#  cbi       Cts: Created by the swapping buffers and inverters for power.
#  cex       Cts: Existing cells in the clock tree which cannot be removed.
#  coi       Cts: Cells created as a result of cancelling out inversions
#  lbl       Cts: Created by the clustering process to meet the slew target
#  ccl       Cts: Created by the clustering process to meet the slew target
#  ccd       Cts: Created by clustering for balancing the tree - these cells are not necessary to meet the slew target.
#  cci       Cts: Created by the clustering process to fix inversion.
#  csf       Cts: Created by the CTS slew fixing step in cases where clustering did not meet the slew target.
#  cms       Cts: Created during the process of physically moving clock gates to improve their enable timing.
#  cid       Cts: Created by CTS on the outputs of weak driving cells to reduce insertion delay.
#  cdb       Cts: Created by CTS to balance the delays in the clock tree.
#  cdbw      Cts: Created by CTS to balance the delays in the clock tree.
#  cwb       Cts: Created by CTS to balance the wire delays in the clock tree.
#  cfo       Cts: Created by CTS to reduce fanout skew.
#  csk       Cts: Created by the CTS skew fixing step to finely balance the clock tree.
#  cmf       Cts: Created by CTS to buffer long nets.
#  cbc       Cts: Created by the clock tree conditioning step to clone off sub trees that cannot optimized by gated synthesis, such as those parts above RAMs, black boxes, and lockup latches.
#  css       Cts: Created by the early cloning of simple sink allocations.
#  cdc       Cts: A clock driver created by adding driver cell process for property add_driver_cell.
#  cpd       Cts: A clock driver created below an input port or above an output port specified by property add_port_driver.
#  ccg       Cts: A clock gate created by one of the gated synthesis algorithms.
#  cse       Cts: A clock driver created above exclude pins to remove them from the clock tree.
#  cfh       Cts: A clock driver created as part of a flexible H-tree.
#  cat       Cts: Created by the add_clock_tree_source_group_roots command
#  cpc_drv   Cts: A clock driver created by post conditioning.
#  cpc_sk    Cts: A clock driver created by post conditioning.
#  PRO       Post-route optimization.
#  PRO_drv   Post-route optimization.
#  PRO_sk    Post-route optimization.
#  sfc       Cloned by slew fixing.
#  ccc       Cts: Created by the clone_clock_cells command.
#  grb       Cts: A clock driver created by global route buffering.
#  sgb       Cts: A clock driver created by source group balancing.
#  idc       Cloned to reduce insertion delay
#  vgb       Cts: A clock driver created by VG buffering.
#  USK       skewClock
#  cff       Cts: A clock driver created by fanout fixing.
#  cng       Cts: Inverter to fix the polarity on a converted discrete gate.
#  incr      Created by incremental CTS
#  cgp       Cts: A clock driver created by clock gate push up
#  usf_dcls_sn  Cts: A clock driver created by USF optimization for dcls split net
#  usf_dcls_snw  Cts: A clock driver created by USF optimization for dcls split network
#  usf_tmr_sn  Cts: A clock driver created by USF optimization for tmr split net
#  usf_tmr_snw  Cts: A clock driver created by USF optimization for tmr split network
#  usf_pc    Cts: A clock driver created by USF optimization for polarity correction



array set ::CTT_CREATOR_DESC {
	CTSG	"Unnamed - should not be used anymore"
	cuk		"Unkown creator, will no apeear in netlist"
	ccl_a	"In Clusturing by agglom clustering"
	cbi		"Swapping buff and inv. for power"
	cex		"Existing cell in clk tree which can not be removed"
	coi		"Cancelling out inversions"
	lbl		"Clustering - To meet slew target"
	ccl		"Clustering - To meet slew target"
	ccd		"Clustering - Balancing tree"
	cci		"Clustering - fix inversion"
	csf		"CTS slew fixing step if not fixed in Clustering"
	cms		"Improve clk gate enable timing"
	cid		"CTS - Reduse ID on weak driving cells"
	cdb		"CTS - To balance delay"
	cdbw	"CTS - To balance delay"
	cwb		"CTS - To balance wire delays"
	cfo		"CTS - to reduse fanout skew"
	csk		"CTS - skew fixing step to Balance clk tree"
	cmf		"CTS - Buffer long nets"
	cbc		"CTS - clones clk subtree where gating can’t be optimized."
	css		"Early cloning of simple sink allocations"
	cdc		"clk driver for add_driver_cell property"
	cpd		"clk driver below an in or out port for add_power_driver"
	ccg		"clk gate in gated synthesis algo."
	cse		"Above exclude pins to remove them from the clk tree"
	cfh		"Created as part of flexi H-tree"
	cat		"Created by add_clock_tree_source_group_roots"
	cpc_drv	"Post Conditioning"
	cpc_sk	"Post Conditioning"
	PRO		"Post-route optimization"
    PRO_drv	"Post-route optimization"
    PRO_sk	"Post-route optimization"
	sfc		"Cloned by slew fix"
	ccc		"Created clone_clock_cells"
	grb		"Created global route buffering"
	sgb		"Created source group balancing"
	idc		"Cloned to reduse ID"
	vgb		"Created by VG buffering"
	USK		"skewClock"
	cff		"Created by fanout fixing"
	cng		"Inverter to fix polarity"
	incr	"Created by incremental CTS"
	cgp		"Created by clk gate push up"
	usf_dcls_sn "clk driver - USF optimi. for dcls split net"
	usf_dcls_snw	"clk driver - USF optimi. for slit network"
	usf_tmr_sn	"clk driver - USF optimi. for tmr split net"
	usf_tmr_snw	"clk driver - USF optimi. for tmr split network"
	usf_pc	"clk driver - USF optimi. for polarity correction"
}


proc _ctt_detect_creator {cell} {
    set keys [lsort -decreasing [array names ::CTT_CREATOR_DESC]]
    foreach k $keys {
        if {[string match "*_${k}_*" $cell] || [string match "*_${k}" $cell]} {
            return $k
        }
    }
    return ""
}

proc _ctt_cells_by_creator {cells} {
    set out {}
    foreach c $cells {
        set cr [_ctt_detect_creator $c]
        if {$cr eq ""} { continue }
        dict lappend out $cr $c
    }
    return $out
}


proc _ctt_print_cts_action_summary {clkPins paths commonCells} {

# =========================
# COMMON TRUNK (unchanged)
# =========================
set commonCreators [_ctt_cells_by_creator $commonCells]

if {[dict size $commonCreators]} {
    puts "Common path (all endpoints)"

    foreach cr [lsort [dict keys $commonCreators]] {
        set cells [lsort -unique [dict get $commonCreators $cr]]

        set desc $cr
        if {[info exists ::CTT_CREATOR_DESC($cr)]} {
            set desc $::CTT_CREATOR_DESC($cr)
        }

        puts "  $desc ($cr) : [llength $cells] , [join $cells { }]"
    }
}

# =========================================================
# NEW LOGIC — per-path branch creator extraction ⭐
# =========================================================

set sinkCreatorMap {}

for {set i 0} {$i < [llength $paths]} {incr i} {

    set p [lindex $paths $i]
    set sink [lindex $clkPins $i]
    if {$sink eq ""} { continue }

    set cells [_ctt_unique_cells_from_path $p]

    # branch cells = after common prefix
    set branchCells [lrange $cells [llength $commonCells] end]

    set creatorMap {}

    foreach c $branchCells {

        set cr [_ctt_detect_creator $c]
        if {$cr eq ""} { continue }

        dict lappend creatorMap $cr $c
    }

    dict set sinkCreatorMap $sink $creatorMap
}

# =========================================================
# MERGE sinks with identical creator maps
# =========================================================

set branchMap {}

foreach sink [dict keys $sinkCreatorMap] {

    set creatorMap [dict get $sinkCreatorMap $sink]

    # canonical key
    set key ""
    foreach cr [lsort [dict keys $creatorMap]] {
        append key "$cr:"
        append key [join [lsort -unique [dict get $creatorMap $cr]] ","]
        append key "|"
    }

    dict lappend branchMap $key $sink
    dict set branchMap "${key}__creators" $creatorMap
}

# =========================================================
# PRINT
# =========================================================

foreach key [lsort [dict keys $branchMap]] {

    if {[string match "*__creators" $key]} { continue }

    set sinks [dict get $branchMap $key]
    set creatorMap [dict get $branchMap "${key}__creators"]

    puts ""

    # header
    set firstSink [lindex $sinks 0]
    set label "Branch only —  "
    puts "$label$firstSink"

    set indent [string repeat " " [string length "Branch only "]]

    for {set i 1} {$i < [llength $sinks]} {incr i} {
        puts "${indent}└─ [lindex $sinks $i]"
    }

    # reasons
    foreach cr [lsort [dict keys $creatorMap]] {

        set cells [lsort -unique [dict get $creatorMap $cr]]

        set desc $cr
        if {[info exists ::CTT_CREATOR_DESC($cr)]} {
            set desc $::CTT_CREATOR_DESC($cr)
        }

        puts "  $desc ($cr) : [llength $cells] , [join $cells { }]"
    }
}

}



# ---------- robust object → cell ----------
proc _ctt_obj_to_cell {obj} {

	set p [get_pins $obj -quiet]
	if {[sizeof_collection $p]} {
		set c [get_cells -of_objects $p -quiet]
		if {[sizeof_collection $c]} {
			return [get_object_name $c]
		}
	}

	set c [get_cells $obj -quiet]
	if {[sizeof_collection $c]} {
		return [get_object_name $c]
	}

	return $obj
}

# ---------- collapse path to unique cells ----------
proc _ctt_unique_cells_from_path {path} {
	set out {}
	set prev ""
	foreach obj $path {

		if {[sizeof_collection [get_ports $obj -quiet]]} {
			continue
		}

		set cell [_ctt_obj_to_cell $obj]

		if {$cell ne $prev && $cell ne ""} {
			lappend out $cell
			set prev $cell
		}
	}
	return $out
}

# ---------- common prefix ----------
proc _ctt_common_prefix {paths} {
	if {![llength $paths]} { return {} }

	set common [lindex $paths 0]

	foreach p [lrange $paths 1 end] {

		set tmp {}
		set minLen [expr {min([llength $common],[llength $p])}]

		for {set i 0} {$i < $minLen} {incr i} {
			if {[lindex $common $i] eq [lindex $p $i]} {
				lappend tmp [lindex $common $i]
			} else { break }
		}

		set common $tmp
		if {![llength $common]} { break }
	}
	return $common
}

# ---------- insert ----------
proc _ctt_insert_node {node path endpoint} {

	if {![llength $path]} {
		dict lappend node endpoints $endpoint
		return $node
	}

	set cell [lindex $path 0]
	set rest [lrange $path 1 end]

	if {![dict exists $node children]} {
		dict set node children {}
	}

	set children [dict get $node children]

	if {[dict exists $children $cell]} {
		set child [dict get $children $cell]
	} else {
		set child [dict create name $cell children {} endpoints {}]
	}

	set child [_ctt_insert_node $child $rest $endpoint]
	dict set node children $cell $child

	return $node
}

# ---------- propagate endpoints ----------
proc _ctt_propagate_endpoints {node} {

	set total {}

	if {[dict exists $node endpoints]} {
		set total [dict get $node endpoints]
	}

	if {[dict exists $node children]} {
		set children [dict get $node children]

		foreach k [dict keys $children] {
			set child [_ctt_propagate_endpoints [dict get $children $k]]
			dict set node children $k $child

			if {[dict exists $child endpoints]} {
				set total [concat $total [dict get $child endpoints]]
			}
		}
	}

	dict set node endpoints [lsort -unique $total]
	return $node
}

# ---------- deterministic print ----------
proc _ctt_print_names {node prefix isLast branchActive parentBranched} {

	set isLeaf 1
	if {[dict exists $node children] && [llength [dict get $node children]]} {
		set isLeaf 0
	}

	set showConnector 0
	if {$parentBranched} {
		set showConnector 1
	} elseif {$branchActive && $isLeaf} {
		set showConnector 1
	}

	if {[dict exists $node name]} {
		if {$showConnector} {
			if {$isLast} {
				puts "${prefix}└─ [dict get $node name]"
			} else {
				puts "${prefix}├─ [dict get $node name]"
			}
		} else {
			puts "${prefix}[dict get $node name]"
		}
	}

	if {$isLeaf} { return }

	set children [dict get $node children]
	set keys [lsort [dict keys $children]]

	set n [llength $keys]
	set currentBranched [expr {$n > 1}]
	set childBranchActive [expr {$branchActive || $currentBranched}]

	if {$showConnector} {
		if {$isLast} {
			set nextPrefix "${prefix}   "
		} else {
			set nextPrefix "${prefix}│  "
		}
	} else {
		set nextPrefix $prefix
	}

	for {set i 0} {$i < $n} {incr i} {
		_ctt_print_names \
			[dict get $children [lindex $keys $i]] \
			$nextPrefix \
			[expr {$i==$n-1}] \
			$childBranchActive \
			$currentBranched
	}
}

######################################################################
# PATH COLLECTORS
######################################################################

proc _ctt_collect_paths_all_fanin {clkPins} {
	set paths {}
	foreach p $clkPins {
		set f [all_fanin -to $p]
		if {[sizeof_collection $f]} {
			lappend paths [lreverse [get_object_name $f]]
		} else {
			lappend paths {}
		}
	}
	return $paths
}

proc _ctt_collect_paths_longest {clkPins} {
	set paths {}
	foreach p $clkPins {
		lappend paths [user_get_longest_path $p]
	}
	return $paths
}

# ---------- longest path with fallback ----------
proc user_get_longest_path {sink} {

	set longestGrp ""
	set maxDelay -1

	set sinkgrps [user_sinks_in_which_skew_groups_return $sink]

	if {![llength $sinkgrps]} {
		puts "INFO: $sink not part of any skew group → using fanin path"
		set f [all_fanin -to $sink]
		if {[sizeof_collection $f]} {
			return [lreverse [get_object_name $f]]
		}
		return {}
	}

	foreach one $sinkgrps {
		set d [get_ccopt_skew_group_delay -skew_group $one -to $sink]
		if {$d > $maxDelay} {
			set maxDelay $d
			set longestGrp $one
		}
	}

	if {$longestGrp eq ""} {
		set f [all_fanin -to $sink]
		if {[sizeof_collection $f]} {
			return [lreverse [get_object_name $f]]
		}
		return {}
	}

	set p [get_ccopt_skew_group_path -sink $sink -skew_group $longestGrp]

	if {![llength $p]} {
		set f [all_fanin -to $sink]
		if {[sizeof_collection $f]} {
			return [lreverse [get_object_name $f]]
		}
		return {}
	}

	return $p
}

proc user_sinks_in_which_skew_groups_return {sink} {
	return [get_ccopt_property skew_groups_sink -pin $sink]
}

######################################################################
# GROUPING
######################################################################
proc _ctt_group_paths {paths} {

	set cellPaths {}
	foreach p $paths {
		lappend cellPaths [_ctt_unique_cells_from_path $p]
	}

	set groups {}

	for {set i 0} {$i < [llength $paths]} {incr i} {

		set base [lindex $cellPaths $i]
		set grp [list $i]

		for {set j 0} {$j < [llength $paths]} {incr j} {
			if {$i == $j} {continue}

			set other [lindex $cellPaths $j]

			if {[llength [_ctt_common_prefix [list $base $other]]]} {
				lappend grp $j
			}
		}

		set grp [lsort -unique $grp]

		if {[lsearch -exact $groups $grp] < 0} {
			lappend groups $grp
		}
	}

	return $groups
}

######################################################################
# GLOBAL SUMMARY (NEW)
######################################################################
proc _ctt_global_summary {clkPins groups} {

	puts ""
	puts "================ Global Sink Summary ============="
	puts "  Total sinks : [llength $clkPins]"
	puts "  Groups      : [llength $groups]"
	puts ""

	set gid 1
	foreach g $groups {

		set sinks {}
		foreach idx $g {
			lappend sinks [lindex $clkPins $idx]
		}

		if {[llength $g] > 1} {
			puts "  Group $gid (COMMON PATH) :"
		} else {
			puts "  Group $gid (ISOLATED)    :"
		}

		foreach s $sinks {
			puts "      $s"
		}

		puts ""
		incr gid
	}
}

######################################################################
# CORE ENGINE
######################################################################
proc _ctt_run_topology {clkPins paths} {

	set tree [dict create children {}]

	set idx 1
	foreach path $paths {
		set tree [_ctt_insert_node $tree $path "R$idx"]
		incr idx
	}

	set tree [_ctt_propagate_endpoints $tree]

	set cellPaths {}
	foreach p $paths {
		lappend cellPaths [_ctt_unique_cells_from_path $p]
	}

	set common [_ctt_common_prefix $cellPaths]
	set anchor [lindex $common end]

	puts ""
	puts "================ Topology (Names) ================"

	set children [dict get $tree children]
	set keys [lsort [dict keys $children]]

	set n [llength $keys]
	set rootBranching [expr {$n > 1}]

	for {set i 0} {$i < $n} {incr i} {
		_ctt_print_names \
			[dict get $children [lindex $keys $i]] \
			"" \
			[expr {$i==$n-1}] \
			$rootBranching \
			$rootBranching
	}

	puts ""
	puts "================ Summary ========================="
	puts "  Endpoints    : [llength $clkPins]"
	puts "  Common cells : [llength $common]"
	puts "  Branch cell  : $anchor"
	puts ""
	_ctt_print_cts_action_summary $clkPins $paths $common
}

######################################################################
# USER APIS
######################################################################
proc check_clock_tree_topology {clkPins} {

	set paths [_ctt_collect_paths_all_fanin $clkPins]
	set groups [_ctt_group_paths $paths]

	foreach g $groups {
		set subPaths {}
		set subPins {}
		foreach idx $g {
			lappend subPaths [lindex $paths $idx]
			lappend subPins [lindex $clkPins $idx]
		}
		_ctt_run_topology $subPins $subPaths
	}

	_ctt_global_summary $clkPins $groups
}

proc check_clock_tree_topology_longest {clkPins} {

	set paths [_ctt_collect_paths_longest $clkPins]
	set groups [_ctt_group_paths $paths]

	foreach g $groups {
		set subPaths {}
		set subPins {}
		foreach idx $g {
			lappend subPaths [lindex $paths $idx]
			lappend subPins [lindex $clkPins $idx]
		}
		_ctt_run_topology $subPins $subPaths
	}

	_ctt_global_summary $clkPins $groups
}

proc check_clock_tree_topology_report_timing {path_collection} {
	set paths {}
	set clkPins {}
	foreach_in_collection path $path_collection {
		foreach one {capture_clock_path launch_clock_path} {
			set tmp_path [get_object_name [get_property [get_property  [get_property $path $one] timing_points] pin]]
			lappend paths $tmp_path
			lappend clkPins [lindex $tmp_path end]

		}
	}
	set groups [_ctt_group_paths $paths]
    foreach g $groups {
        set subPaths {}
        set subPins {}
        foreach idx $g {
            lappend subPaths [lindex $paths $idx]
            lappend subPins [lindex $clkPins $idx]
        }
        _ctt_run_topology $subPins $subPaths
    }
    _ctt_global_summary $clkPins $groups
}
