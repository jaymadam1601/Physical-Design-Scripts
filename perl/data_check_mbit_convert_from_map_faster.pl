#!/usr/bin/perl
use strict;
use warnings;

my $sdc      = $ARGV[0];
my $map      = $ARGV[1];
my $MY_BLOCK = $ARGV[2];

my %map_hash;
open(my $map_fh, "<", $map) or die "Could not open $map: $!";
while (my $line = <$map_fh>) {
    chomp $line;
    my @f = split(/\s+/, $line);
    next unless @f >= 5;
    my $key = $f[3];
    my $val = $f[4];
    $map_hash{$key} = $val;
}
close $map_fh;

open(my $fp_sdc, "<", $sdc) or die "Could not open $sdc: $!";
open(my $op_sdc, ">", "set_data_check_MBIGenerated.${MY_BLOCK}.tcl") or die $!;

while (my $sdc_line = <$fp_sdc>) {
    chomp $sdc_line;
    my @line = split(/\s+/, $sdc_line);
    my $newline;
    if ($sdc_line =~ /set_data_check/) {
        if ($sdc_line =~ /-hold/) {
            $newline = join(" ", @line[0..2]);
            my $found_first = map_lookup($line[3], \%map_hash);
            $newline .= " $found_first";
            $newline .= " $line[4] $line[5]";
            my $found_second = map_lookup($line[6], \%map_hash);
            $newline .= " $found_second " . join(" ", @line[7..11]);
            print $op_sdc "$newline\n";
        }
        elsif ($sdc_line =~ /-setup/) {
            $newline = join(" ", @line[0..2]);
            my $found_first  = map_lookup($line[3], \%map_hash);
            $newline .= " $found_first $line[4] $line[5]";
            my $found_second = map_lookup($line[6], \%map_hash);
            $newline .= " $found_second " . join(" ", @line[7..8]);
            print $op_sdc "$newline\n";
        }
    }
    elsif ($sdc_line =~ /set_multicycle_path/) {
        $newline = join(" ", @line[0..5]);
        my $found_first = map_lookup($line[6], \%map_hash);
        $newline .= " $found_first " . join(" ", @line[7..9]);
        print $op_sdc "$newline\n";
    }
}

close $fp_sdc;
close $op_sdc;

sub map_lookup {
    my ($token, $map_ref) = @_;
    (my $clean = $token) =~ s/[{}\]]//g;  
    $clean =~ s/\/d/\/q/g;             

    my $mapped = $map_ref->{$clean} // "";
    if ($mapped eq "") {
        return $token; 
    } else {
        $mapped =~ s/\/q/\/d/g;
        return "{$mapped}]";
    }
}

