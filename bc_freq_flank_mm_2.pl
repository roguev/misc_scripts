#!/usr/bin/perl

use strict;

# some initial variables we need later
my @sample_arr;
my %hash;
my @chunks;
my @valid_counts;
my @total_counts;

# input parameters
my $bc_len_range = pop(@ARGV);	# barcode length range (barcodes +/- bc_length_range will be considered).
my $bc_len = pop(@ARGV);	# barcode length
my $min_q = pop(@ARGV);		# minimum q-score
my $rt = pop(@ARGV);		# do revese complement? 1 = yes, 0 = no
my $samples = pop(@ARGV);	# number of samples in the sequencing run

# regex used to match sequences conating the barcode. hard-coded here but can be moved to command line arguments
my $bc_min = $bc_len - $bc_len_range;
my $bc_max = $bc_len + $bc_len_range;

my $pat_left = 'AGTACTCGAG';
my $pat_middle = '([ATCGatcg]'."{$bc_min,$bc_max})";
my $pat_right = 'GCGTCGACCC';

my @regex = &make_regex($pat_left, $pat_middle, $pat_right);

print "Number of samples: ".$samples."\n";
print "Reverse complement: ".$rt."\n";
print "Min Quality: ".$min_q."\n";
print "Barcode length range: ";
print $bc_len - $bc_len_range;
print "\t";
print $bc_len + $bc_len_range;
print "\n";
print "Pattern space:\n";
print join("\n",@regex);
print "\n";

# generates patterns with 1 mismatch in the flanking regions
sub make_regex($$$) {
	my $left = $_[0];
	my $middle =$_[1];
	my $right = $_[2];
	my @result = ();
	my $tmp_l;
	my $tmp_r;
	
	# original sequence, no mismatches
	push(@result, '('.$left.')'.$middle.'('.$right.')');
	
	# one mismatch on the left side
	for (my $i = 0; $i < length($left); $i++) {
		$tmp_l = $left;
		substr($tmp_l, $i,1) = '[ATGCatgc]';
#		print '('.$tmp_l.')'.$middle.'('.$right.')'."\n";	# debug
		push(@result, '('.$tmp_l.')'.$middle.'('.$right.')');
	}
	
	# one mismatch on the right side
	for (my $i = 0; $i < length($right); $i++) {
		$tmp_r = $right;
		substr($tmp_r, $i,1) = '[ATGCatgc]';
		push(@result, '('.$left.')'.$middle.'('.$tmp_r.')');
	}
	
	# one mismatch on the left and one on the right
	for (my $i = 0; $i < length($left); $i++) {
		$tmp_l = $left;
		substr($tmp_l, $i,1) = '[ATGCatgc]';
		for (my $j = 0; $j < length($right); $j++) {
			$tmp_r = $right;
			substr($tmp_r, $j,1) = '[ATGCatgc]';
			push(@result, '('.$tmp_l.')'.$middle.'('.$tmp_r.')');
		}
	}		
	return(@result);
}
	
# creates reverse complement
sub revcom($) {
	my $seq = reverse($_[0]);
	$seq =~ tr/ACGTactg/TGCAtgca/;
	return $seq;
}

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

# read the fastq file and turn records into lines 
sub read_fastq($) {
	my $counter = 1;
	my @tmp;
	
	# open file and read all lines into the buffer array. then close file. this is memory efficient
	print "Processing: ".$_[0]."\n";
	open(IN, $_[0]);
	my @lines = <IN>;
	my @data = ();
	close(IN);

	# turn record into a single line. skip line 3 of each record
	for (my $i = 0; $i < scalar(@lines); $i++) {
		my $line = $lines[$i];
		chomp($line);

		# skip line 3
		if ($counter == 3) { $counter++; next; }
		push(@tmp,$line);
		$counter++;

		if ($counter > 4) {
			push(@data, join("\t",@tmp));
			@tmp = ();
			$counter = 1;
			next;
		}
	}
	return(@data);
}

# main loop ######################################
# process files 1 by 1
foreach my $infile (@ARGV) {
	my @records = &read_fastq($infile);
	my @line_arr = ();
	
	# process each sequence
	foreach my $line (@records) {
		my $sample;
		my $bc = '';
		my $qual_str = '';
		my $bc_qual = 0;
		
		my @sample_arr = ();
		"a" =~ /a/;  # Reset captures to undef.
#		print $1."\t".$2."\t".$3."\n";	# debug

		# get chunks of data
		# extract sample number will be the 10th element in a ':' separated string
		@line_arr = split(/\t/, $line);
		@sample_arr = split(/:/, $line_arr[0]);
		$sample = $sample_arr[9];
		$sample--;
		
		# increment the total sequence counter
		$total_counts[$sample]++;
		
		# check if sequence is correct
		my $tmp;
		for (my $i = 0; $i < scalar(@regex); $i++) {
#			print $regex[$i]."\n";	# debug
			($tmp) = $line_arr[1] =~ /$regex[$i]/;
			if ( ($1 eq '') || ($2 eq '') || ($3 eq '') ) { next; }
#			print $regex[$i]."\t".$1."\t".$2."\t".$3."\n";	# debug
			$bc = $2;
			push(@chunks, $1."\t".$2."\t".$3);
#			print "$bc\n";	# debug
			$qual_str = substr($line_arr[1], $-[2], $+[2] - $-[2]);
			$bc_qual = &calc_qual($qual_str);
			last;
		}
		
		# move to next one if poor quality
		if (($bc eq '') || ($bc_qual < $min_q)) { next; }
		
		# increment the valid sequence counter
		$valid_counts[$sample]++;
		
		# reverse complement if needed
		if ($rt > 0) {
			$bc = &revcom($bc);
		}
		
		# add to the big table
		# if we don't have this one initialize an array to hold the counts
		if (!exists($hash{$bc})) {
			@{$hash{$bc}} = (0) x $samples;
		}
		# add to table
		@{$hash{$bc}}[$sample]++;
	}
}

# print some stats
for (my $i = 0; $i < $samples; $i++) {
	my $s = $i+1;
	if ($total_counts[$i] > 0) {
		print "Sample ".$s.": \t".$valid_counts[$i]."/".$total_counts[$i]." = ".$valid_counts[$i]/$total_counts[$i]."\n";
	} else {
		print "Sample ".$s.": \t0\n";
	}
}

# save data
open(OUT,'>bc_freq.txt');
open(FOUT,'>bc_seq.fasta');
foreach my $seq (sort keys %hash) {
	print OUT $seq;
	print FOUT '>'.$seq."\n".$seq."\n";
	for (my $i = 0; $i < $samples; $i++) {
		if ($valid_counts[$i] > 0) {
			print OUT "\t".@{$hash{$seq}}[$i]/$valid_counts[$i];
		} else {
			print OUT "\t".@{$hash{$seq}}[$i];
		}
	}
	print OUT "\n";
}
close(FOUT);
close(OUT);

open(COUT,'>bc_seq.chunks');
print COUT join("\n",@chunks);
close(COUT);
############################################################################
