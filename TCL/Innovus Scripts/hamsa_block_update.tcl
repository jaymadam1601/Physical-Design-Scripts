proc add_obs_top_pin_macro {} {
set macro_box [dbget [dbget top.insts.cell.baseClass block -p2 ].box]
set sizex "5"
set sizey "4.8945"
set sizexy_box [dbShape $macro_box SIZEX $sizex SIZEY $sizey]
createPlaceBlockage -box $sizexy_box -name all_around_macro_obs

set all_macro_obs [lindex [dbget [dbget top.fplan.pBlkgs.name all_around_macro_obs -p ].boxes] 0]
set left_side_box "\{[lindex [dbShape $all_macro_obs XOR $macro_box ] 0]\}"
set left_side_top_box "\{[lindex [dbShape $left_side_box SIZEY 31.174 XOR $left_side_box ] 1]\}"
set left_side_top_box_big "\{[lindex [dbShape $left_side_top_box SIZEX 3 XOR $left_side_top_box] 1]\}"
createPlaceBlockage -box $left_side_top_box -name left_side_top_box
createPlaceBlockage -box $left_side_top_box_big -name left_side_top_box_big

set right_side_box "\{[lindex [dbShape $all_macro_obs XOR $macro_box ] 3]\}"
set right_side_top_box "\{[lindex [dbShape $right_side_box SIZEY 31.174 XOR $right_side_box ] 1]\}"
set right_side_top_box_big "\{[lindex [dbShape $right_side_top_box SIZEX 3 XOR $right_side_top_box] 0]\}"
createPlaceBlockage -box $right_side_top_box -name right_side_top_box
createPlaceBlockage -box $right_side_top_box_big -name right_side_top_box_big

set top_box_left_x  "[lindex [lindex [lindex [dbget [dbget top.fplan.pBlkgs.name left_side_top_box -p ].boxes ] 0] 0] 0]"
set top_box_left_y  "[lindex [lindex [lindex [dbget [dbget top.fplan.pBlkgs.name left_side_top_box -p ].boxes ] 0] 0] 1]"
set top_box_right_x  "[lindex [lindex [lindex [dbget [dbget top.fplan.pBlkgs.name right_side_top_box -p ].boxes ] 0] 0] 2]"
set top_box_right_y  "[lindex [lindex [lindex [dbget [dbget top.fplan.pBlkgs.name right_side_top_box -p ].boxes ] 0] 0] 3]"

set top_box "$top_box_left_x $top_box_left_y $top_box_right_x $top_box_right_y"
set top_box_top_obs "\{[lindex [dbShape $top_box SIZEY -6.1750 XOR $top_box] 1]\}"
createPlaceBlockage -box $top_box_top_obs -name top_box_top_obs
}


proc add_obs_bottom_pin_macro {} {
set macro_box [dbget [dbget top.insts.cell.baseClass block -p2 ].box]
set sizex "5"
set sizey "4.8945"
set sizexy_box [dbShape $macro_box SIZEX $sizex SIZEY $sizey]
createPlaceBlockage -box $sizexy_box -name all_around_macro_obs

set all_macro_obs [lindex [dbget [dbget top.fplan.pBlkgs.name all_around_macro_obs -p ].boxes] 0]
set left_side_box "\{[lindex [dbShape $all_macro_obs XOR $macro_box ] 0]\}"
set left_side_bottom_box "\{[lindex [dbShape $left_side_box SIZEY 31.174 XOR $left_side_box ] 0]\}"
set left_side_bottom_box_big "\{[lindex [dbShape $left_side_bottom_box SIZEX 3 XOR $left_side_bottom_box] 1]\}"
createPlaceBlockage -box $left_side_bottom_box -name left_side_bottom_box
createPlaceBlockage -box $left_side_bottom_box_big -name left_side_bottom_box_big

set right_side_box "\{[lindex [dbShape $all_macro_obs XOR $macro_box ] 3]\}"
set right_side_bottom_box "\{[lindex [dbShape $right_side_box SIZEY 31.174 XOR $right_side_box ] 0]\}"
set right_side_bottom_box_big "\{[lindex [dbShape $right_side_bottom_box SIZEX 3 XOR $right_side_bottom_box] 0]\}"
createPlaceBlockage -box $right_side_bottom_box -name right_side_bottom_box
createPlaceBlockage -box $right_side_bottom_box_big -name right_side_bottom_box_big

set bottom_box_left_x  "[lindex [lindex [lindex [dbget [dbget top.fplan.pBlkgs.name left_side_bottom_box -p ].boxes ] 0] 0] 0]"
set bottom_box_left_y  "[lindex [lindex [lindex [dbget [dbget top.fplan.pBlkgs.name left_side_bottom_box -p ].boxes ] 0] 0] 1]"
set bottom_box_right_x  "[lindex [lindex [lindex [dbget [dbget top.fplan.pBlkgs.name right_side_bottom_box -p ].boxes ] 0] 0] 2]"
set bottom_box_right_y  "[lindex [lindex [lindex [dbget [dbget top.fplan.pBlkgs.name right_side_bottom_box -p ].boxes ] 0] 0] 3]"

set bottom_box "$bottom_box_left_x $bottom_box_left_y $bottom_box_right_x $bottom_box_right_y"
set bottom_box_bottom_obs "\{[lindex [dbShape $bottom_box SIZEY -6.1750 XOR $bottom_box] 0]\}"
createPlaceBlockage -box $bottom_box_bottom_obs -name bottom_box_bottom_obs
}
