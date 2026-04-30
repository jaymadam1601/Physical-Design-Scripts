#!/usr/bin/env actperl
use strict;

### Usage: convert_icc_to_enc.pl  $icc_eco_file_name

my $insert_buffer_count = 0;
my $size_cell_count = 0;

my $input_file = $ARGV[0];
my $output_file = $input_file;
if ($output_file =~ m/icc/) {
  $output_file =~ s/icc/enc/g;
} else {
  $output_file =~ m/(.*)\.tcl/;
  $output_file = "$1.enc.tcl";
}
print "Output file is $output_file\n";

open (INPUT_FILE, "$input_file") || die "Error: Cannot open $input_file.\n";
open (OUTPUT_FILE, ">$output_file");

my $root_cell = "";
my $target_cell = "";
my $target_lib_ref = "";
my $target_ref = "";
my $target_pin = "";
my $new_net_name = "";
my $new_cell_name = "";

while(<INPUT_FILE>) {
  if (m/^current_instance$/) {
    $root_cell = ""
  } elsif (m/^current_instance\s+{(.*)}/) {
    $root_cell = "${1}/";
  } elsif (m/^size_cell\s+{(\S+)}\s+{(\S+)}/) {
    $target_cell = "${root_cell}${1}";
    $target_lib_ref = $2;
    $target_ref = $target_lib_ref;
    $target_ref =~ s/(\S+)\///;
    print OUTPUT_FILE "dbChangeInstCell $target_cell $target_ref\n";
    if ($target_cell =~ /^agPORTISO/ ) {
      print OUTPUT_FILE "setInstancePlacementStatus -name $target_cell -status softFixed\n";
    }
    $size_cell_count = $size_cell_count + 1;
  } elsif (m/^insert_buffer\s+\[get_pins {(\S+)}\]\s+(\S+)\s+-new_net_names {(\S+)}\s+-new_cell_names {(\S+)}/) {
    $target_pin = "${root_cell}${1}";
    $target_lib_ref = $2;
    $new_net_name = $3;
    $new_cell_name = $4;
    $target_ref = $target_lib_ref;
    $target_ref =~ s/(\S+)\///;
    if ($target_pin =~ m/\/Q[0-9]?$/ || $target_pin =~ m/\/q[0-9]?$/ || $target_pin =~ m/\/o$/) {
      print OUTPUT_FILE "ecoAddRepeater -term $target_pin -cell $target_ref -newNetName $new_net_name -name $new_cell_name\n";
    } else {
      print OUTPUT_FILE "ecoAddRepeater -relativeDistToSink 0.0 -term $target_pin -cell $target_ref -newNetName $new_net_name -name $new_cell_name\n";
    }
    $insert_buffer_count = $insert_buffer_count + 1;
	} elsif (m/^insert_buffer\s+\[get_pins {(\S+)}\]\s+(.*)\s+-inverter_pair\s+-new_net_names {(.*)}\s+-new_cell_names {(.*)}/) {
		my @new_net_names = ();
		my @new_cell_names = ();
		$target_pin = "${root_cell}${1}";
		$target_lib_ref = $2;
    $target_ref = $target_lib_ref;
    $target_ref =~ s/(\S+)\///;
		$new_net_name = $3;
		$new_cell_name = $4;
		@new_net_names = split(/\s+/,$new_net_name);
		@new_cell_names = split(/\s+/,$new_cell_name);
		
    	if ($target_pin =~ m/\/Q[0-9]?$/ || $target_pin =~ m/\/q[0-9]?$/ || $target_pin =~ m/\/o$/) {
      	print OUTPUT_FILE "ecoAddRepeater -term $target_pin -cell $target_ref -newNetName {{$new_net_names[0] $new_net_names[1]}}-name {{$new_cell_names[0] $new_cell_names[1]}}\n";
    	} else {
      	print OUTPUT_FILE "ecoAddRepeater -relativeDistToSink 0.0 -term $target_pin -cell $target_ref -newNetName {{$new_net_names[0] $new_net_names[1]}} -name {{$new_cell_names[0] $new_cell_names[1]}}\n";
    	}
    	$insert_buffer_count = $insert_buffer_count + 2;
	}  elsif (/^create_cell/) {
    	    s/{//g ;
    	    s/}//g ;
    	    my @temp_array=split'\s+' ;
    	    my $inst_name=$temp_array[1] ;
    	    my $cell_name=$temp_array[2] ;
    	    my @temp_array=split'/',$cell_name ;
    	    my $cell_name=$temp_array[1] ;
    	    print OUTPUT_FILE "addInst $cell_name $inst_name -loc {0 0}\n"
  	}
}
close (INPUT_FILE);
close (OUTPUT_FILE);
print "Total $insert_buffer_count insert_buffer commands and $size_cell_count size_cell commands.\n";
