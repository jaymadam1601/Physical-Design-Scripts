setLayerPreference allLayers -isSelectable 0
setLayerPreference node_blockage -isVisible 0

set metal_layers [dbget [dbget head.layers.type routing -p ].name]
set via_layers   [dbget [dbget head.layers.type cut -p ].name]
set total_layers {}
for {set i 0} {$i < [llength $metal_layers]} {incr i} {
	if {[lindex $metal_layers $i] ne ""} {lappend total_layers [lindex $metal_layers $i]}
	if {[lindex $via_layers $i] ne ""} {lappend total_layers [lindex $via_layers $i]}
}
set howmuchlayer 3
set curr_idx 0
proc apply_layer_visibility {total_layers start_idx} {
	global howmuchlayer
	set turnedon_layers {}
	foreach layer $total_layers {
		setLayerPreference $layer -isVisible 0
	}
	set end_idx [expr {$start_idx + $howmuchlayer - 1}]
	for {set i $start_idx} {$i <= $end_idx} {incr i} {
		if {$i >= 0 && $i < [llength $total_layers]} {
			setLayerPreference [lindex $total_layers $i] -isVisible 1
			lappend turnedon_layers [lindex $total_layers $i]
		}
	}
	clear
	puts "Layers Visible \n[join $turnedon_layers \n]"
}
proc moveup {} {
	global total_layers curr_idx howmuchlayer
	set max_idx [expr {[llength $total_layers] - $howmuchlayer}]
	if {$curr_idx < $max_idx} {
		incr curr_idx 1
		apply_layer_visibility $total_layers $curr_idx
	} else {
		puts "Already at topmost visible layer range"
	}
}
proc movedown {} {
	global total_layers curr_idx
	if {$curr_idx > 0} {
		incr curr_idx -1
		apply_layer_visibility $total_layers $curr_idx
	} else {
		puts "Already at bottommost visible layer range"
	}
}
proc start_from_bottom {} {
	global total_layers curr_idx howmuchlayer
	set curr_idx 0
	apply_layer_visibility $total_layers $curr_idx
}
bindkey Shift-Up {moveup}
bindkey Shift-Down {movedown}
set ICON_DIR "/home/Pictures/"
if {[uiFind main -label "Jay's Layer Parser Toolbar"] != ""} {
    uiDelete "Jay's Layer Parser Toolbar"
}
uiAdd "Jay's Layer Parser Toolbar" -type toolbar -in main -label "Jay's Layer Parser Toolbar"
uiAdd DownToolButton -type toolbutton -in "Jay's Layer Parser Toolbar" -label "DownToolButton_for_layers" -tooltip "Lower Layer Visible" -icon [file join $ICON_DIR DownArrow_150.png] -command movedown
uiAdd MiddleToolButton -type toolbutton -in "Jay's Layer Parser Toolbar" -label "MiddleToolButton_for_layers" -tooltip "First Bottom Layers" -icon [file join $ICON_DIR MiddleRadio.svg] -command start_from_bottom
uiAdd UpToolButton -type toolbutton -in "Jay's Layer Parser Toolbar" -label "UpToolButton_for_layers" -tooltip "Upper Layer Visible" -icon [file join $ICON_DIR UpArrow_150.png] -command moveup

puts ""
puts "Usage:"
puts "Use variable \$howmuchlayer to set number of layer to parse if not set by default 3 will be taken"
puts "Then execute command: start_from_bottom"
puts "Shift + Up / Down arrow keys to parse visibility of layers."
puts ""
puts ""

bindKey l {verify_drc -limit 0 -view_window}
puts "Usage: Press l to check verify_drc on visible gui window"
puts "       Press p to check connectivity of selected nets"
bindKey p {verifyConnectivity -selected -type all -noAntenna -geomConnect -error 1000 -warning 50}
