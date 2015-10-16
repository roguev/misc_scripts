#!/usr/bin/perl
# calculates sequence quality per base as well as average sequence quality per cluster
use strict;
my $in = shift;


# computes sequence quality of a sequence
sub calc_qual($) {
	my $sum = 0;
	my $base_qual = 0;
	my @quals = ();
	# break quality string into letters
	my @q = split(//,$_[0]);
	
	# generate a sum of qulity values
	for (my $i = 0; $i < scalar(@q); $i++) {
		 $base_qual = ord($q[$i]) - 32;		# for illumina 1.8
		 push(@quals, $base_qual);
		 $sum += $base_qual;
	 }
	 
	 # return average quality
	 push(@quals, $sum/scalar(@q)); 
	 return(@quals);
 }
 
my $counter = 0;
my @tmp;
	
open(IN, $in);
my $tile_id;
my $fn;
my $x_pos;
my $y_pos;
my $read;

while (my $line = <IN>) {
	my @qual = ();
	chomp($line);
	$counter++;
		
	if ($counter == 1) {
		@tmp = split(/:/,$line);
		$tile_id = $tmp[3].'_'.$tmp[4];
		$x_pos = $tmp[5];
		($y_pos,$read) = split(/ /,$tmp[6]);
		
		$fn = $tile_id.'.txt';
		if (-e $fn) {
			open(OUT,'>>',$fn);
		} else {
			open(OUT,'>',$fn);
		}	
	}

	if ($counter == 4) {
		@qual = &calc_qual($line);
		print OUT $x_pos."\t".$y_pos."\t".join("\t",@qual)."\n";
		close(OUT);
		$counter = 0;
	}
}
close(IN);
