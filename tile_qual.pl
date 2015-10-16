#!/usr/bin/perl

use strict;
use Statistics::Basic qw(:all);
use List::Util qw( min max );

my $in = shift;
my %hash;
my %x;
my %y;

# computes sequence quality of a sequence
sub calc_qual($) {
	my $sum = 0;
	# break quality string into letters
	my @q = split(//,$_[0]);
	
	# generate a sum of qulity values
	for (my $i = 0; $i < scalar(@q); $i++) {
		 $sum += ord($q[$i]) - 32;		# for illumina 1.8
	 }
	 
	 # return average quality
	 return($sum/scalar(@q));
 }
 
#sub calc_stats(@) {
	 #my @data = @_;
	 #my $sum = 0;
	 #my $mean = 0;
	 #for (my $i = 0; $i < scalar(@data); $i++) {
		 #$sum += $data[$i];
	 #}
	 #if (scalar(@data) > 0) {
		#$mean = $sum/scalar(@data);
	#}
	 #return($mean);
 #}
 
my $counter = 0;
my @tmp;
	
open(IN, $in);
my $tile_id;
my $x_pos;
my $y_pos;
my $read;

while (my $line = <IN>) {
	my $qual;
	chomp($line);
	$counter++;
		
	if ($counter == 1) {
		@tmp = split(/:/,$line);
		$tile_id = $tmp[3].'_'.$tmp[4];
		$x_pos = $tmp[5];
		($y_pos,$read) = split(/ /,$tmp[6]);

		if (!exists($hash{$tile_id})) {
			$hash{$tile_id} = ();
			$x{$tile_id} = ();
			$y{$tile_id} = ();
		}
		push(@{$x{$tile_id}},$x_pos);
		push(@{$y{$tile_id}},$y_pos);	
	}

#	print "$line\t$counter\n";

	if ($counter == 4) {
		$qual = &calc_qual($line);
		push(@{$hash{$tile_id}},$qual);
		$counter = 0;
#		print @{$hash{$tile_id}};
	}
}

foreach my $tile (sort keys %hash) {
#	print "$tile\t".&calc_stats(@{$hash{$tile}})."\n";
	print "$tile\t".mean(@{$hash{$tile}})."\t".stddev(@{$hash{$tile}})."\t".min(@{$x{$tile}})."\t".min(@{$y{$tile}})."\t".max(@{$x{$tile}})."\t".max(@{$y{$tile}})."\n";
}
