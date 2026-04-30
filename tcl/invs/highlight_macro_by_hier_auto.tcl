proc common_prefix {a b} {
	set maxlen [expr {
		[string length $a] < [string length $b] ?
		[string length $a] : [string length $b]
	}]
	set i 0
	while {$i < $maxlen} {
		if {[string index $a $i] ne [string index $b $i]} {
			break
		}
		incr i
	}
	return [string range $a 0 [expr {$i - 1}]]
}
proc common_suffix {a b} {
	set lena [string length $a]
	set lenb [string length $b]
	set i 0
	while {$i < $lena && $i < $lenb} {
		if {[string index $a [expr {$lena - $i - 1}]] ne \
			[string index $b [expr {$lenb - $i - 1}]]} {
			break
		}
		incr i
	}
	if {$i == 0} {
		return ""
	}
	return [string range $a [expr {$lena - $i}] end]
}
proc get_signature {a b} {
	set pre [common_prefix $a $b]
	set suf [common_suffix $a $b]
	# Trim incomplete token from end of prefix
	regsub {[_./-]?[^_./-]*$} $pre "" pre
	# Trim incomplete token from start of suffix
	regsub {^[^_./-]*[_./-]?} $suf "" suf
	return "$pre|$suf"
}
proc process_macro_groups {{output_file macro_groups.txt}} {
	# Get all block macro instance names
	set insts [dbGet [dbGet top.insts.cell.baseClass block -p2].name]
	if {[llength $insts] == 0} {
		puts "ERROR: No macro instances found"
		return
	}
	# Sort so similar names stay together
	set insts [lsort $insts]
	set out [open $output_file w]
	set current_group [list [lindex $insts 0]]
	set current_sig ""
	for {set i 1} {$i < [llength $insts]} {incr i} {
		set prev [lindex $insts [expr {$i - 1}]]
		set curr [lindex $insts $i]
		set sig [get_signature $prev $curr]
		if {$current_sig eq ""} {
			set current_sig $sig
		}
		if {$sig eq $current_sig} {
			lappend current_group $curr
		} else {
			# Write group to file
			puts $out "# Group Signature: $current_sig"
			foreach inst $current_group {
				puts $out $inst
			}
			puts $out ""
			# Highlight group
			deselectAll
			foreach inst $current_group {
				catch {selectInst $inst}
			}
			if {[llength [dbGet selected.name]] > 0} {
				highlight -auto_color
			}
			puts "Highlighted group: $current_sig"
			# Start new group
			set current_group [list $curr]
			set current_sig ""
		}
	}
	# Process last group
	puts $out "# Group Signature: $current_sig"
	foreach inst $current_group {
		puts $out $inst
	}
	puts $out ""
	deselectAll
	foreach inst $current_group {
		catch {selectInst $inst}
	}
	if {[llength [dbGet selected.name]] > 0} {
		highlight -auto_color
	}
	puts "Highlighted group: $current_sig"
	deselectAll
	close $out
	puts "Macro grouping written to: $output_file"
}
