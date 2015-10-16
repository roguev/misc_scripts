#!/usr/bin/perl
# sorts a set of fastq sequences into different sample files using the remapping infor provided by the undefined_sorter.pl script
# calllike this:
# ./sequence_sorter.pl <output of undefined_sorter.pl> <fastq sequence set to be processed> <base filename for outputs>

use strict;

my $remap = shift;			# output of undefined_sorter.pl
my $seq = shift;			# fastq sequence set to be processed
my $base_path = shift;		# base filename for outputs

my @tmp = ();
my @tmp1 = ();

my %rm = {};

# open the remapping file and load it into a temporary array
open(RM, $remap);
@tmp = <RM>;
close(RM);

# populate the remapping table
foreach my $record (@tmp) {
	chomp($record);
	@tmp1 = split(/\t/,$record);
	$rm{$tmp1[0]} = $tmp1[1];
}

# debug
#foreach my $k (keys %rm) {
	#print $k."\t".$rm{$k}."\n";
#} 

# re-initialize for a peace of mind
@tmp = ();
@tmp1 = ();

# used to keep trackj of which line in the fastq record we are on
my $counter = 0;

# read sequences one by one and send them to different outputs accordingly
open(IN, $seq);
while (my $line = <IN>) {
	my $sample = 0;
	$counter++;
	
	# header line
	if ($counter == 1) {
		chomp($line);
		
		# is this sequence re-mapped
		if (exists($rm{$line})) {
			$sample = $rm{$line};

			# obtain sample number and re-assign it to the one from the re-mapping
			@tmp1 = split(/:/,$line);
			$tmp1[9] = $sample;
			
			# re-create header line
			$line = join(':',@tmp1);
			$line = $line."\n";

			# output file name
			my $fn = $base_path.'_s'.$sample.'.txt';
#			print "$fn\n";
			
			# check if file exists, if yes open for appending, if no, create one
			if (-e $fn) {
				open(OUT,'>>',$fn);
			} else {
				open(OUT, '>',$fn);
			}
		}
	}
	
	# send lines to file
	print OUT $line;
	
	# the end of the fastq record so output file close file
	if ($counter == 4) {
		close(OUT);
		$counter = 0;
	}
}
close(IN);
