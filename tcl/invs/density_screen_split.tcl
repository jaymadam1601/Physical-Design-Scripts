
proc density_screen {x1 y1 x2 y2 x y density} {

set a1 $x1
set b1 $y1
set a2 [expr $a1 + $x]
set b2 [expr $b1 + $y]

createPlaceBlockage -type partial -name pblkg_${x}by${y}_$density -density $density -box "$a1 $b1 $a2 $b2" -excludeFlops

set j $x1
set i $y1

while {$i <= $y2} {

         while {$j < $x2} {
                 set a1 [expr $a1 + $x]
                 set a2 [expr $a1 + $x]
                 set j $a2

         if {$a2 <= $x2} {
                         createPlaceBlockage -type partial  -name pblkg_${x}by${y}_$density -density $density -box "$a1 $b1 $a2 $b2" -excludeFlops
                 }
         }

         set b1 [expr $b1 + $y]
         set b2 [expr $b1 + $y]
         set i $b2
         set j $x1

         set a1 $x1
         set a2 [expr $a1 + $x]

         if {$b2 <= $y2} {
                         createPlaceBlockage -type partial  -name pblkg_${x}by${y}_$density -density $density -box "$a1 $b1 $a2 $b2" -excludeFlops
         }
}
}

