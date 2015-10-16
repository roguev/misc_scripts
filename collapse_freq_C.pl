#!/usr/bin/perl

use strict;

my $bc_space = shift;
my $freq_table = shift;
my $max_mm = shift;

my %final_hash;
my %freq_hash;
my %bc_space_hash;
my @tmp;
my @r_array;
my $samples;

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

#print "Reading frequencies\n";
open(IN,$freq_table);
@tmp = <IN>;
close(IN);

foreach my $record (@tmp) {
	chomp($record);
	@r_array = split(/\t/, $record);
	my $seq = shift(@r_array);
	$samples = scalar(@r_array);
	@{$freq_hash{$seq}} = @r_array;
}

#print "Reading barcodess space\n";
open(IN,$bc_space);
@tmp = <IN>;
close(IN);

foreach my $record (@tmp) {
	chomp($record);
	@r_array = split(/\t/, $record);
	my $name = shift(@r_array);
	my $seq = shift(@r_array);
	@{$final_hash{$seq}} = (0) x $samples;
	$bc_space_hash{$seq} = $name;
}

foreach my $bc1 (keys %final_hash) {
#	print "$bc1\n";
	foreach my $bc2 (keys %freq_hash) {
#		print "$bc1\t$bc2\n";
		if (length($bc1) == length($bc2)) {
			my @diff = &find_diff($bc1, $bc2);
#			print "$diff\n";
			if (scalar(@diff) <= $max_mm) {
#				print "$bc1\t$bc2\t@diff\t".scalar(@diff)."\n";
				for (my $i = 0; $i < $samples; $i++) {
					@{$final_hash{$bc1}}[$i] += @{$freq_hash{$bc2}}[$i];
				}
			}
		}
	}
}

foreach my $seq (keys %final_hash) {
	print $bc_space_hash{$seq}."_$seq\t".join("\t",@{$final_hash{$seq}})."\n";
}
