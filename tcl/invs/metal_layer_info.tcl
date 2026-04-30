set via_layers [dbget [dbget head.layers.type cut -p ].name]
set metal_layers [dbget [dbget head.layers.type routing -p ].name]

set format "| %-5s | %-10s | %-7s | %-7s | %-7s | %-7s |\n"
set separator "+-------+------------+---------+---------+---------+---------+"

puts $separator
puts -nonewline [format $format "Layer" "Direction" "Width" "PitchX" "PitchY" "NumMask"]
puts $separator

foreach one $metal_layers {
    set point       [dbget head.layers.name $one -p]
    set direction   [dbget $point.direction]
    set width       [dbget $point.width]
    set pitchX      [dbget $point.pitchX]
    set pitchY      [dbget $point.pitchY]
    set numMasks    [dbget $point.numMasks]
    puts -nonewline [format $format $one $direction $width $pitchX $pitchY $numMasks]
}
puts $separator
