#!/usr/bin/perl
# call like this:
# ./undefined_sorter.pl <fastq file wit undetermined sequences> <index mapping file> <reverse complement 0 (no) or 1 (yes)> <max number ofmismatches>

use strict;

my $i_file = shift;			# fastq file wit undetermined sequences
my $index_mapping = shift;	# index mapping file, simply a list of index sequences in the order of samples in the experiment
my $rt = shift;				# do reverse complement?
my $max_mm = shift;			# max number of mismathces

my @indeces = ();
my %mm_hash = {};
my @tmp = ();

# finds the (higest) index of the minimum in an array
sub findMinValueIndex(@) {
	my @arr = @_;
	my $index = 0;
	my $min = $arr[0];;
	for (my $i = 0; $i < scalar(@arr); $i++) {
		if ($arr[$i] <= $min) {
			$min = $arr[$i];
			$index = $i;
			}
		}
		return ($min,$index);
	}

# check an array for more than one minimum
sub checkMultipleMins($@) {
	my $min = shift(@_);
	my @arr = @_;
	my $counter = 0;
	for (my $i = 0; $i < scalar(@arr); $i++) {
		if ($arr[$i] == $min) {
			$counter++;
		}
	}
	return $counter;
}

# finds differences between strings
use Inline C => << 'EOC';
    void find_diff(char* x, char* y) {
        int i;
        Inline_Stack_Vars;
        Inline_Stack_Reset;
        for(i=0; x[i] && y[i]; ++i) {
            if(x[i] != y[i]) {
                Inline_Stack_Push(sv_2mortal(newSViv(i)));
            }
        }
        Inline_Stack_Done;
    }
EOC

# creates reverse complement
sub revcom($) {
	my $seq = reverse($_[0]);
	$seq =~ tr/ACGTactg/TGCAtgca/;
	return $seq;
}
	
# read the fastq file and turn records into lines 
sub read_fastq($) {
	my $counter = 1;
	my @tmp;
	
	# open file and read all lines into the buffer array. then close file. this is memory efficient
#	print "Processing: ".$_[0]."\n";
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

open(IM,$index_mapping);
my @im = <IM>;
close(IM);

@tmp = ();
foreach my $ind (@im) {
	chomp($ind);
	push(@indeces, $ind)
}

@tmp = ();
my @mm_arr = ();

# read the sequences
my @seqs = &read_fastq($i_file);
foreach my $seq_rec (@seqs) {
	@tmp = split(/\t/,$seq_rec);
	my $seq = $tmp[1];
	
	# reverse complement?
	if ($rt == 1) {
		$seq = &revcom($seq);
	}
	
	# find number of mismatches between the sequence and the set of indeces
	foreach my $ind (@indeces) {
		my @diff = &find_diff($ind, $seq);
		push(@mm_arr, scalar(@diff));
	}
	
	# find the position minimum and its index
	my ($min, $min_index) = &findMinValueIndex(@mm_arr);
	
	# check number of mismatches, if above threshold move on
	if ($min > $max_mm) {
		print $tmp[0]."\t0\n";
		@mm_arr = ();
		next;
	}
	
	# only one minimum, if more move on
	my $n_mins = &checkMultipleMins($min,@mm_arr);
	if ($n_mins > 1) {
		print $tmp[0]."\t0\n";
		@mm_arr = ();
		next;
	}
	
	# report results
	print $tmp[0]."\t".++$min_index."\n";
	@mm_arr = ();
}
