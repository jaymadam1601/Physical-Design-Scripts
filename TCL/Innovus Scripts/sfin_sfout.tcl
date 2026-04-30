source /home/scripts/tcl/invs/enc.pref.tcl
source /home/scripts/tcl/invs/enc.proc.tcl

set ::parent_cells {}

proc sfin_new {} {
	global parent_cells
	set parent_cells [dbget selected.name]
	sfin
}
proc sfout_new {} {
	global parent_cells 
	set parent_cells [dbget selected.name]
	sfout
}

proc go_to_parent_object {} {
	global parent_cells
	deselectAll
	selectInst $parent_cells
}
set ICON_DIR "/home/Pictures/"
if {[uiFind main -label "Jay's Sfin Sfout Toolbar"] != ""} {
    uiDelete "Jay's Sfin Sfout Toolbar"
}
uiAdd "Jay's Sfin Sfout Toolbar" -type toolbar -in main -label "Jay's Sfin Sfout Toolbar"
uiAdd LeftToolButton -type toolbutton -in "Jay's Sfin Sfout Toolbar" -label "LeftToolButton_for_sfin_sfout" -tooltip "Selected Fanin" -icon [file join $ICON_DIR LeftArrow_150.svg] -command sfin_new
uiAdd MiddleToolButton -type toolbutton -in "Jay's Sfin Sfout Toolbar" -label "MiddleToolButton_for_sfin_sfout" -tooltip "Select Parent" -icon [file join $ICON_DIR MiddleRadio.svg] -command go_to_parent_object
uiAdd RightToolButton -type toolbutton -in "Jay's Sfin Sfout Toolbar" -label "RigthToolButton_for_sfin_sfout" -tooltip "Selected Fanout" -icon [file join $ICON_DIR RightArrow_150.svg] -command sfout_new
