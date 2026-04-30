#!/usr/bin/perl
use strict;
use warnings;

my $sdc  = $ARGV[0];
my $dotv = $ARGV[1];
my $MY_BLOCK = $ARGV[2];

system("cat $sdc | awk '/set_data_check/ {print}' > mbit_data_check.sdc");
system("cat $sdc | awk '/set_data_check/ {print \$4, \$7}' | sed 's/[{}]//g' > mbit_check.tcl");
system("awk '{print \$1}' mbit_check.tcl > mbit_first_column");
system("awk '{print \$2}' mbit_check.tcl > mbit_second_column");
system("sed -i 's/\\/.*\$//' mbit_first_column");
system("sed -i 's/\\/.*\$//' mbit_second_column");
system("cp -prf $dotv .");
system("gunzip ${MY_BLOCK}.v.gz");

$dotv = "${MY_BLOCK}.v";

system("grep -F -f mbit_first_column $dotv | awk '{print \$2}' > dotv_first");
system("grep -F -f mbit_second_column $dotv | awk '{print \$2}' > dotv_second");

my $first_col    = "mbit_first_column";
my $second_col   = "mbit_second_column";
my $dotv_first   = "dotv_first";
my $dotv_second  = "dotv_second";
my $endfile_first = "endfile_first";
my $endfile_second = "endfile_second";

open(my $fh, "<", $first_col) or die "Could not open file '$first_col' $!";
open(my $fd, "<", $dotv_first) or die "Could not open file '$dotv_first' $!";
open(my $ef, ">", $endfile_first) or die "Could not open file '$endfile_first' $!";

while (my $line = <$fh>) {
    chomp $line;
    seek $fd, 0, 0;   # rewind second file
    while (my $line1 = <$fd>) {
        chomp $line1;
        if ($line1 =~ /\Q$line\E/) {
            print $ef "$line $line1\n";
        }
    }
}
close($ef);
close($fh);
close($fd);

open(my $sc, "<", $second_col) or die "Could not open file '$second_col' $!";
open(my $sd, "<", $dotv_second) or die "Could not open file '$dotv_second' $!";
open(my $es, ">", $endfile_second) or die "Could not open file '$endfile_second' $!";

while (my $line = <$sc>) {
    chomp $line;
    seek $sd, 0, 0;   # rewind second file
    while (my $line1 = <$sd>) {
        chomp $line1;
        if ($line1 =~ /\Q$line\E/) {
            print $es "$line $line1\n";
        }
    }
}
close($es);
close($sc);
close($sd);

system("cat endfile_first  | sed -e 's/CDN_MBIT_//' -e 's/_MB_/ /g' | awk 'NF > 2 {for (i = 2; i <= NF; i++){ if (\$1 == \$i) {a=i-2;print \"*\"\$1\"*/d\"a }  }} NF <=2 {print \$1\"/d\"}' > final_first");
system("cat endfile_second | sed -e 's/CDN_MBIT_//' -e 's/_MB_/ /g' | awk 'NF > 2 {for (i = 2; i <= NF; i++){ if (\$1 == \$i) {a=i-2;print \"*\"\$1\"*/d\"a }  }} NF <=2 {print \$1\"/d\"}' > final_second");
system("paste mbit_data_check.sdc final_first final_second | awk '{print \$1,\$2,\$3,\$(NF-1)\"]\",\$5,\$6,\$NF\"]\",\$8,\$9,\$10,\$11,\$12}' > mbit_data_check.tcl");

system("rm -rf final_first final_second mbit_check.tcl mbit_first_column mbit_second_column ${MY_BLOCK}.v dotv_first dotv_second endfile_first endfile_second mbit_data_check.sdc")


