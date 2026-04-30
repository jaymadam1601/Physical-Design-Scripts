#!/usr/bin/perl
use strict;
use warnings;

my $dont_check_list = shift @ARGV;
my @verilog_files = @ARGV;

open(my $dl, "<", $dont_check_list) or die "Could not open $dont_check_list: $!";

while (my $dl_line = <$dl>) {
	chomp $dl_line;
	print "$dl_line\n";

}
